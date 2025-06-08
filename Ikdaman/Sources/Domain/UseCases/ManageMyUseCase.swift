//
//  ManageMyUseCase.swift
//  Ikdaman
//
//  Created by Soo on 5/19/25.
//

import RxSwift
import Moya

protocol ManageMyUseCase {
    func getUserInfo() -> Observable<User>
    func saveUser(user: User) -> Completable
    func logout() -> Single<Response>
    func withdraw() -> Completable
}

final class DefaultManageMyUseCase: ManageMyUseCase {
    private let manageMyRepository: ManageMyRepository
    
    init(manageMyRepository: ManageMyRepository) {
        self.manageMyRepository = manageMyRepository
    }
    
    func getUserInfo() -> RxSwift.Observable<User> {
        manageMyRepository.fetchCurrentUser()
    }
    
    func saveUser(user: User) -> RxSwift.Completable {
        manageMyRepository.updateUser(user)
    }
    
    func logout() -> Single<Response> {
        manageMyRepository.logout()
    }
    
    func withdraw() -> RxSwift.Completable {
        manageMyRepository.withdraw()
    }

}
