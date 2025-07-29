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
    func saveUser(user: User) -> Observable<User>
    func logout() -> Single<Response>
    func withdraw() -> Single<Response>
    func checkNicknameDuplication(nickname: String) -> Single<Bool>
}

final class DefaultManageMyUseCase: ManageMyUseCase {
    private let manageMyRepository: ManageMyRepository
    
    init(manageMyRepository: ManageMyRepository) {
        self.manageMyRepository = manageMyRepository
    }
    
    func getUserInfo() -> RxSwift.Observable<User> {
        manageMyRepository.fetchCurrentUser()
    }
    
    func saveUser(user: User) -> RxSwift.Observable<User> {
        manageMyRepository.updateUser(user)
    }
    
    func logout() -> Single<Response> {
        manageMyRepository.logout()
    }
    
    func withdraw() -> Single<Response> {
        manageMyRepository.withdraw()
    }

    func checkNicknameDuplication(nickname: String) -> Single<Bool> {
        return manageMyRepository.checkNicknameDuplication(nickname: nickname)
    }
}
