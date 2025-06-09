//
//  ManageMyRepository.swift
//  Ikdaman
//
//  Created by Soo on 5/19/25.
//

import RxSwift
import Moya

protocol ManageMyRepository {
    func fetchCurrentUser() -> Observable<User>
    func updateUser(_ user: User) -> Completable
    func logout() -> Single<Response>
    func withdraw() -> Completable
    func checkNicknameDuplication(nickname: String) -> Single<Bool>
}
