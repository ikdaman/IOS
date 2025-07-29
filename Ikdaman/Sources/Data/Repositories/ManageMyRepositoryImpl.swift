//
//  ManageMyRepositoryImpl.swift
//  Ikdaman
//
//  Created by Soo on 5/19/25.
//

import RxSwift
import Moya

final class ManageMyRepositoryImpl: ManageMyRepository {
    private let networkProvider = NetworkProvider.shared

    func fetchCurrentUser() -> RxSwift.Observable<User> {
        return networkProvider
            .request(BookAPI.getProfile, type: User.self)
            .asObservable()
    }
    
    func updateUser(_ user: User) -> RxSwift.Observable<User> {
        return networkProvider
            .request(BookAPI.modifyProfile(user: user), type: User.self)
            .asObservable()
    }

    func logout() -> Single<Response> {
        return networkProvider.requestRaw(BookAPI.logout)
    }

    func withdraw() -> Single<Response> {
        return networkProvider.requestRaw(BookAPI.withDrawal)
    }
    
    func checkNicknameDuplication(nickname: String) -> RxSwift.Single<Bool> {
        return networkProvider
            .request(BookAPI.checkNickname(nickName: nickname), type: Available.self)
            .map { $0.available }
    }
}
