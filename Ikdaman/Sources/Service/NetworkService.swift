//
//  NetworkService.swift
//  Ikdaman
//
//  Created by Soo on 4/21/25.
//

import Moya
import RxMoya
import RxSwift
import Foundation

final class NetworkService {
    private let provider: MoyaProvider<MultiTarget>
    
    init(provider: MoyaProvider<MultiTarget> = MoyaProvider<MultiTarget>(plugins: [NetworkLoggerPlugin()])) {
        self.provider = provider
    }
    
    func request<T: TargetType>(_ target: T) -> Single<Response> {
        return provider.rx
            .request(MultiTarget(target))
            .do(onSuccess: { response in
                print("✅ [\(target.path)] \(response.statusCode)")
            }, onError: { error in
                print("❌ [\(target.path)] \(error)")
            })
            .filterSuccessfulStatusCodes()
    }
}

final class NetworkProvider {
    static let shared = NetworkProvider()

    let provider: MoyaProvider<MultiTarget>
    let disposeBag = DisposeBag()

    private init() {
        self.provider = MoyaProvider<MultiTarget>(plugins: [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        ])
    }
}

extension NetworkProvider {
    func requestRaw(_ target: TargetType) -> Single<Response> {
        return provider.rx.request(MultiTarget(target))
            .do(onSuccess: { response in
                print("✅ [\(target.path)] \(response.statusCode)")
            }, onError: { error in
                print("❌ [\(target.path)] \(error)")
            })
            .filterSuccessfulStatusCodes()
    }
}

extension NetworkProvider {
    func request<T: Decodable>(_ target: TargetType, type: T.Type) -> Single<T> {
        return provider.rx.request(MultiTarget(target))
            .flatMap { [weak self] response -> Single<T> in
                guard let self = self else { return .never() }
                
                if let token = response.response?.allHeaderFields.first(where: {
                    "\($0.key)".lowercased() == "Authorization" ||
                    "\($0.key)".lowercased() == "refresh-token"
                })?.value as? String {
                    let _ = KeychainService.shared.delete(forKey: .accessToken)
                    let _ = KeychainService.shared.delete(forKey: .refreshToken)
                    let _ = KeychainService.shared.save(token, forKey: .accessToken)
                    let _ = KeychainService.shared.save(token, forKey: .refreshToken)
                    print("🔐 토큰 저장됨: \(token)")
                }


                // ✅ 정상 응답
                if (200...299).contains(response.statusCode) {
                    return self.decodeResponse(response, type: T.self)
                }

                // ✅ 토큰 만료 처리
                if response.statusCode == 401 {
                    return self.refreshTokenIfNeeded()
                        .flatMap { success -> Single<T> in
                            if success {
                                print("🔄 재발급 성공 → 원 요청 재시도")
                                return self.request(target, type: T.self)
                            } else {
                                print("🚫 토큰 재발급 실패 → 로그아웃 처리")
                                AuthService.shared.logout()
                                return .error(NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "인증이 만료되었습니다."]))
                            }
                        }
                }

                // ❌ 기타 에러
                return .error(NSError(domain: "Network", code: response.statusCode, userInfo: [
                    NSLocalizedDescriptionKey: "네트워크 오류 (\(response.statusCode))"
                ]))
            }
    }

    /// 🔍 응답 디코딩 공용 함수
    private func decodeResponse<T: Decodable>(_ response: Response, type: T.Type) -> Single<T> {
        do {
            let decoded = try response.map(T.self)
            return .just(decoded)
        } catch {
            return .error(error)
        }
    }

    /// ♻️ 토큰 재발급 함수
    private func refreshTokenIfNeeded() -> Single<Bool> {
        guard let refreshToken = KeychainService.shared.load(forKey: .refreshToken),
              !refreshToken.isEmpty else {
            return .just(false)
        }

        print("🔄 Refresh token으로 재발급 시도...")

        return provider.rx.request(MultiTarget(BookAPI.reissueToken))
            .filterSuccessfulStatusCodes()
            .map { response in
                // 새 토큰 추출 및 저장
                if let accessToken = response.response?.allHeaderFields["Authorization"] as? String,
                   let newRefreshToken = response.response?.allHeaderFields["refresh-token"] as? String {
                    let _ = KeychainService.shared.save(accessToken, forKey: .accessToken)
                    let _ = KeychainService.shared.save(newRefreshToken, forKey: .refreshToken)
                    print("✅ 토큰 재발급 완료")
                    return true
                }
                return false
            }
            .catchAndReturn(false)
    }
}
