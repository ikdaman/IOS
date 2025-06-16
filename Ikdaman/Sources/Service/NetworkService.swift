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

    func request<T: Decodable>(_ target: TargetType, type: T.Type) -> Single<T> {
        return provider.rx.request(MultiTarget(target))
            .do(onSuccess: { response in
                print("✅ [\(target.path)] \(response.statusCode)")

                // ✅ 헤더에서 토큰 추출
                if let token = response.response?.allHeaderFields.first(where: {
                    "\($0.key)".lowercased() == "Authorization" ||
                    "\($0.key)".lowercased() == "refresh-token"
                })?.value as? String {
                    KeychainService.shared.save(token, forKey: .accessToken)
                    KeychainService.shared.save(token, forKey: .refreshToken)
                    print("🔐 토큰 저장됨: \(token)")
                }
                
            }, onError: { error in
                print("❌ [\(target.path)] \(error)")
            })
            .filterSuccessfulStatusCodes()
            .flatMap { response in
                guard !response.data.isEmpty else {
                    return .error(NSError(domain: "EmptyData", code: -1000, userInfo: [NSLocalizedDescriptionKey: "응답 데이터가 비어 있습니다."]))
                }
                
                do {
                    let result = try response.map(T.self)
                    return .just(result)
                } catch {
                    print("❌ 디코딩 실패: \(error)")
                    return .error(error)
                }
            }
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
