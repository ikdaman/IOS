//
//  ManageMyUseCaseImpl.swift
//  Ikdaman
//
//  Created by Soo on 5/19/25.
//

import RxSwift
import Moya

final class ManageMyUseCaseImpl: ManageMyRepository {
    private let networkProvider = NetworkProvider.shared

    func fetchCurrentUser() -> RxSwift.Observable<User> {
        return networkProvider
            .request(BookAPI.getProfile, type: User.self)
            .asObservable()
    }
    
    func updateUser(_ user: User) -> RxSwift.Completable {
        return networkProvider
            .request(BookAPI.modifyProfile, type: Profile.self)
            .asCompletable()
    }

    func logout() -> Single<Response> {
        return networkProvider.requestRaw(BookAPI.logout)
    }

    func withdraw() -> Completable {
        return networkProvider
            .request(BookAPI.withDrawal, type: String.self)
            .asCompletable()
    }
}
