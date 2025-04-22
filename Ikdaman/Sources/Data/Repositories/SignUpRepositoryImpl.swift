//
//  SignUpRepositoryImpl.swift
//  Ikdaman
//
//  Created by Soo on 4/22/25.
//

import Moya
import RxSwift
import RxMoya

class SignUpRepositoryImpl: SignUpRepository {
    private let networkProvider = NetworkProvider.shared

    func login() -> Single<LoginInfo> {
        return networkProvider
            .request(BookAPI.login, type: LoginInfo.self)
    }
    
    func test() -> Single<User> {
        return networkProvider
            .request(BookAPI.getProfile, type: User.self)
    }
}
