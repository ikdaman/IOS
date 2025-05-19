//
//  ManageMyUseCase.swift
//  Ikdaman
//
//  Created by Soo on 5/19/25.
//

import RxSwift

protocol ManageMyUseCase {
    func getUserInfo() -> Observable<User>
    func saveUser(user: User) -> Completable
    func logout() -> Completable
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
    
    func logout() -> RxSwift.Completable {
        manageMyRepository.logout()
    }
    
    func withdraw() -> RxSwift.Completable {
        manageMyRepository.withdraw()
    }

}
