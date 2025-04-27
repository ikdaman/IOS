//
//  NetworkService.swift
//  Ikdaman
//
//  Created by Soo on 4/21/25.
//

import Moya
import RxMoya
import RxSwift

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

    private init() {
        self.provider = MoyaProvider<MultiTarget>(plugins: [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        ])
    }

    func request<T: Decodable>(_ target: TargetType, type: T.Type) -> Single<T> {
        return provider.rx.request(MultiTarget(target))
            .do(onSuccess: { response in
                // 요청이 성공했을 때 응답 상태 코드와 정보를 출력합니다.
                print("✅ [\(target.path)] \(response.statusCode)")
            }, onError: { error in
                // 오류가 발생했을 때 오류를 출력합니다.
                print("❌ [\(target.path)] \(error)")
            })
            .filterSuccessfulStatusCodes()
            .map(T.self)
    }
}
