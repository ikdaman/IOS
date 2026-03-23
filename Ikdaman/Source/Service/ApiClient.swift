//
//  ApiClient.swift
//  Ikdaman
//
//  Created by Soo on 3/16/26.
//

import Foundation

// MARK: - API Endpoint Protocol
protocol APIEndpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var queryParameters: [String: String]? { get }
    var body: Data? { get }
}

// MARK: - HTTP Method
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

// MARK: - Network Error
enum NetworkError: Error, LocalizedError, Equatable {
    case invalidURL
    case noData
    case decodingError(String)
    case httpError(statusCode: Int)
    case unauthorized
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "유효하지 않은 URL입니다."
        case .noData:
            return "데이터가 없습니다."
        case .decodingError(let message):
            return "디코딩 실패: \(message)"
        case .httpError(let statusCode):
            return "HTTP 오류: \(statusCode)"
        case .unauthorized:
            return "인증이 만료되었습니다."
        case .serverError(let message):
            return "서버 오류: \(message)"
        }
    }
    
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL):
            return true
        case (.noData, .noData):
            return true
        case (.decodingError(let l), .decodingError(let r)):
            return l == r
        case (.httpError(let l), .httpError(let r)):
            return l == r
        case (.unauthorized, .unauthorized):
            return true
        case (.serverError(let l), .serverError(let r)):
            return l == r
        default:
            return false
        }
    }
}

// MARK: - API Client
@MainActor
final class APIClient: ObservableObject {
    static let shared = APIClient()
    
    private let session: URLSession
    private var isRefreshing = false
    private var refreshTask: Task<Bool, Never>?
    
    // AuthService는 외부에서 주입받음
    weak var authService: AuthService?
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: configuration)
    }
    
    // MARK: - Request Methods
    
    /// 기본 요청 (디코딩 포함)
    func request<T: Decodable>(_ endpoint: APIEndpoint, responseType: T.Type) async throws -> T {
        let urlRequest = try buildURLRequest(from: endpoint)
        
        logRequest(urlRequest)
        
        do {
            let (data, response) = try await session.data(for: urlRequest)
            
            try handleResponse(response)
            logResponse(response, data: data)
            
            // 헤더에서 토큰 추출 및 저장
            if let httpResponse = response as? HTTPURLResponse {
                saveTokensFromHeaders(httpResponse)
            }
            
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                return decoded
            } catch {
                throw NetworkError.decodingError(error.localizedDescription)
            }
        } catch let error as NetworkError where error == .unauthorized {
            // 401 에러 시 토큰 재발급 시도
            let success = await refreshTokenIfNeeded()
            if success {
                print("🔄 토큰 재발급 성공 → 재시도")
                return try await request(endpoint, responseType: T.self)
            } else {
                print("🚫 토큰 재발급 실패 → 로그아웃")
                await authService?.logout()
                throw NetworkError.unauthorized
            }
        }
    }
    
    /// Raw Data 요청 (응답 본문이 없는 경우)
    func requestRaw(_ endpoint: APIEndpoint) async throws {
        let urlRequest = try buildURLRequest(from: endpoint)
        
        logRequest(urlRequest)
        
        do {
            let (data, response) = try await session.data(for: urlRequest)
            
            try handleResponse(response)
            logResponse(response, data: data)
            
            // 헤더에서 토큰 추출 및 저장
            if let httpResponse = response as? HTTPURLResponse {
                saveTokensFromHeaders(httpResponse)
            }
        } catch let error as NetworkError where error == .unauthorized {
            // 401 에러 시 토큰 재발급 시도
            let success = await refreshTokenIfNeeded()
            if success {
                print("🔄 토큰 재발급 성공 → 재시도")
                try await requestRaw(endpoint)
            } else {
                print("🚫 토큰 재발급 실패 → 로그아웃")
                await authService?.logout()
                throw NetworkError.unauthorized
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func buildURLRequest(from endpoint: APIEndpoint) throws -> URLRequest {
        var urlString = endpoint.baseURL + endpoint.path
        
        // Query parameters 추가
        if let queryParameters = endpoint.queryParameters, !queryParameters.isEmpty {
            var components = URLComponents(string: urlString)
            components?.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
            urlString = components?.url?.absoluteString ?? urlString
        }
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        
        // Headers 설정
        if var headers = endpoint.headers {
            // login 엔드포인트의 경우 social-token 추가
            if let bookEndpoint = endpoint as? BookEndpoint {
                if let socialToken = AuthService.shared.loginType?.token {
                    switch bookEndpoint {
                    case .login:
                        headers["social-token"] = socialToken
                    case .login2:
                        headers["social-id-token"] = socialToken
                    default: break
                    }
                }
            }
            
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        return request
    }
    
    private func handleResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return
        case 401:
            throw NetworkError.unauthorized
        default:
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
    }
    
    private func saveTokensFromHeaders(_ response: HTTPURLResponse) {
        if let accessToken = response.value(forHTTPHeaderField: "Authorization") {
            let _ = KeychainService.shared.save(accessToken, forKey: .accessToken)
            print("🔐 Access Token 저장됨")
        }
        
        if let refreshToken = response.value(forHTTPHeaderField: "refresh-token") {
            let _ = KeychainService.shared.save(refreshToken, forKey: .refreshToken)
            print("🔐 Refresh Token 저장됨")
        }
    }
    
    private func refreshTokenIfNeeded() async -> Bool {
        // 이미 재발급 중이면 기다림
        if let existingTask = refreshTask {
            return await existingTask.value
        }
        
        guard !isRefreshing else { return false }
        
        isRefreshing = true
        
        let task = Task { () -> Bool in
            defer {
                isRefreshing = false
                refreshTask = nil
            }
            
            guard let refreshToken = KeychainService.shared.load(forKey: .refreshToken),
                  !refreshToken.isEmpty else {
                return false
            }
            
            print("🔄 Refresh token으로 재발급 시도...")
            
            do {
                let endpoint = BookEndpoint.reissueToken
                let urlRequest = try buildURLRequest(from: endpoint)
                let (_, response) = try await session.data(for: urlRequest)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    return false
                }
                
                if (200...299).contains(httpResponse.statusCode) {
                    saveTokensFromHeaders(httpResponse)
                    print("✅ 토큰 재발급 완료")
                    return true
                }
                
                return false
            } catch {
                print("❌ 토큰 재발급 실패: \(error)")
                return false
            }
        }
        
        refreshTask = task
        return await task.value
    }
    
    // MARK: - Logging
    
    private func logRequest(_ request: URLRequest) {
        print("📤 [\(request.httpMethod ?? "")] \(request.url?.absoluteString ?? "")")
        if let headers = request.allHTTPHeaderFields {
            print("📋 Headers: \(headers)")
        }
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("📦 Body: \(bodyString)")
        }
    }
    
    private func logResponse(_ response: URLResponse, data: Data) {
        if let httpResponse = response as? HTTPURLResponse {
            print("📥 [\(httpResponse.statusCode)] \(httpResponse.url?.absoluteString ?? "")")
        }
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📦 Response: \(jsonString)")
        }
    }
}
