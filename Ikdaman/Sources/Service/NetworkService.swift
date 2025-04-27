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
    
    init(provider: MoyaProvider<MultiTarget> = MoyaProvider<MultiTarget>()) {
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
        self.provider = MoyaProvider<MultiTarget>(plugins: [NetworkLoggerPlugin()])
    }

    func request<T: Decodable>(_ target: TargetType, type: T.Type) -> Single<T> {
        return provider.rx.request(MultiTarget(target))
            .filterSuccessfulStatusCodes()
            .map(T.self)
    }
}
