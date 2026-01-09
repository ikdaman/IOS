//
//  NetworkService.swift
//  Ikdaman
//
//  Created by Soo on 1/7/26.
//

import Foundation

// MARK: - Network Service
@MainActor
final class NetworkService: ObservableObject {
    static let shared = NetworkService()
    
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    // Token refresh 관련
    private var isRefreshing = false
    private var refreshTask: Task<Bool, Never>?
    
    // 인증 관련 (외부 주입)
    weak var authService: AuthService?
    
    init(configuration: URLSessionConfiguration = .default) {
        // URLSession 설정
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        configuration.waitsForConnectivity = true
        
        self.session = URLSession(configuration: configuration)
        
        // JSON Decoder 설정
        self.decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        // JSON Encoder 설정
        self.encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase
    }
    
    // MARK: - Public Request Methods
    
    /// Response를 디코딩하여 반환하는 요청
    func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        responseType: T.Type
    ) async throws -> T {
        let urlRequest = try buildURLRequest(from: endpoint)
        
        return try await performRequest(urlRequest) { data in
            try self.decoder.decode(T.self, from: data)
        }
    }
    
    /// Response Body가 없는 요청 (204 No Content 등)
    func requestWithoutResponse(_ endpoint: APIEndpoint) async throws {
        let urlRequest = try buildURLRequest(from: endpoint)
        
        let _: EmptyResponse = try await performRequest(urlRequest) { _ in
            EmptyResponse()
        }
    }
    
    /// Raw Data를 반환하는 요청
    func requestData(_ endpoint: APIEndpoint) async throws -> Data {
        let urlRequest = try buildURLRequest(from: endpoint)
        
        return try await performRequest(urlRequest) { data in
            data
        }
    }
    
    // MARK: - Private Methods
    
    /// URLRequest 생성
    private func buildURLRequest(from endpoint: APIEndpoint) throws -> URLRequest {
        var urlString = endpoint.baseURL + endpoint.path
        
        // Query Parameters 추가
        if let queryParameters = endpoint.queryParameters, !queryParameters.isEmpty {
            var components = URLComponents(string: urlString)
            components?.queryItems = queryParameters.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
            urlString = components?.url?.absoluteString ?? urlString
        }
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        
        // Default Headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Access Token 추가 (있는 경우)
        if let accessToken = KeychainService.shared.load(forKey: .accessToken) {
            request.setValue(accessToken, forHTTPHeaderField: "Authorization")
        }
        
        // Custom Headers 추가
        if let headers = endpoint.headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        return request
    }
    
    /// 실제 네트워크 요청 수행
    private func performRequest<T>(
        _ request: URLRequest,
        transform: @escaping (Data) throws -> T
    ) async throws -> T {
        logRequest(request)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            logResponse(response, data: data)
            
            // HTTP Response 처리
            try handleResponse(response, data: data)
            
            // 헤더에서 토큰 추출 및 저장
            if let httpResponse = response as? HTTPURLResponse {
                saveTokensFromHeaders(httpResponse)
            }
            
            // 응답 데이터 변환
            do {
                return try transform(data)
            } catch {
                throw NetworkError.decodingError(error.localizedDescription)
            }
            
        } catch let error as NetworkError where error == .unauthorized {
            // 401 Unauthorized - Token Refresh 시도
            let success = await refreshTokenIfNeeded()
            
            if success {
                print("토큰 재발급 성공 → 요청 재시도")
                return try await performRequest(request, transform: transform)
            } else {
                print("토큰 재발급 실패 → 로그아웃 처리")
                await authService?.logout()
                throw NetworkError.unauthorized
            }
            
        } catch let error as NetworkError {
            throw error
            
        } catch {
            throw NetworkError.networkFailure(error)
        }
    }
    
    /// HTTP Response 상태 코드 처리
    private func handleResponse(_ response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            // Success
            return
            
        case 401:
            throw NetworkError.unauthorized
            
        case 400...499:
            // Client Error
            let message = try? decoder.decode(ErrorResponse.self, from: data)
            throw NetworkError.httpError(
                statusCode: httpResponse.statusCode,
                message: message?.message
            )
            
        case 500...599:
            // Server Error
            let message = try? decoder.decode(ErrorResponse.self, from: data)
            throw NetworkError.serverError(
                message?.message ?? "서버 오류가 발생했습니다."
            )
            
        default:
            throw NetworkError.httpError(
                statusCode: httpResponse.statusCode,
                message: nil
            )
        }
    }
    
    /// 응답 헤더에서 토큰 추출 및 저장
    private func saveTokensFromHeaders(_ response: HTTPURLResponse) {
        if let accessToken = response.value(forHTTPHeaderField: "Authorization") {
            _ = KeychainService.shared.save(accessToken, forKey: .accessToken)
            print("Access Token 저장")
        }
        
        if let refreshToken = response.value(forHTTPHeaderField: "refresh-token") {
            _ = KeychainService.shared.save(refreshToken, forKey: .refreshToken)
            print("Refresh Token 저장")
        }
    }
    
    /// Token Refresh
    private func refreshTokenIfNeeded() async -> Bool {
        // 이미 재발급 중이면 기존 Task 결과 대기
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
                print("❌ Refresh Token이 없습니다.")
                return false
            }
            
            print("🔄 Token 재발급 시도...")
            
            do {
                // Refresh Token Endpoint 호출
                let endpoint = BookEndpoint.reissueToken
                let urlRequest = try buildURLRequest(from: endpoint)
                let (_, response) = try await session.data(for: urlRequest)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    return false
                }
                
                if (200...299).contains(httpResponse.statusCode) {
                    saveTokensFromHeaders(httpResponse)
                    print("✅ Token 재발급 성공")
                    return true
                }
                
                print("❌ Token 재발급 실패: \(httpResponse.statusCode)")
                return false
                
            } catch {
                print("❌ Token 재발급 중 오류: \(error)")
                return false
            }
        }
        
        refreshTask = task
        return await task.value
    }
    
    // MARK: - Logging
    
    private func logRequest(_ request: URLRequest) {
        #if DEBUG
        print("📤 [\(request.httpMethod ?? "")] \(request.url?.absoluteString ?? "")")
        
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            print("📋 Headers: \(headers)")
        }
        
        if let body = request.httpBody,
           let bodyString = String(data: body, encoding: .utf8) {
            print("📦 Body: \(bodyString)")
        }
        #endif
    }
    
    private func logResponse(_ response: URLResponse, data: Data) {
        #if DEBUG
        if let httpResponse = response as? HTTPURLResponse {
            print("📥 [\(httpResponse.statusCode)] \(httpResponse.url?.absoluteString ?? "")")
        }
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📦 Response: \(jsonString)")
        }
        #endif
    }
}

// MARK: - Helper Models

/// 빈 응답용 구조체
struct EmptyResponse: Codable {
    init() {}
}

/// 에러 응답 구조체
struct ErrorResponse: Codable {
    let message: String?
    let code: String?
    let status: Int?
}

// MARK: - Encodable Extension

extension Encodable {
    /// Encodable을 JSON Data로 변환
    func toJSONData() throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return try encoder.encode(self)
    }
    
    /// Encodable을 Dictionary로 변환
    func toDictionary() throws -> [String: Any] {
        let data = try toJSONData()
        guard let dictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NetworkError.encodingError
        }
        return dictionary
    }
}
