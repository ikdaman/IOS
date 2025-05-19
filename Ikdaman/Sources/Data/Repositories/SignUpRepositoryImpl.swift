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

    func login() -> Observable<Profile> {
        return networkProvider
            .request(BookAPI.login, type: Profile.self)
            .asObservable()
    }
    
}
