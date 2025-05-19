//
//  ManageMyRepository.swift
//  Ikdaman
//
//  Created by Soo on 5/19/25.
//

import RxSwift

protocol ManageMyRepository {
    func fetchCurrentUser() -> Observable<User>
    func updateUser(_ user: User) -> Completable
    func logout() -> Completable
    func withdraw() -> Completable
}
