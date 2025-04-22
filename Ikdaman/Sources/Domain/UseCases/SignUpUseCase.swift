//
//  SignUpUseCase.swift
//  Ikdaman
//
//  Created by Soo on 4/22/25.
//

import RxSwift
import UIKit

protocol SignUpUseCase {
    func login() -> Single<LoginInfo>
    func test() -> Single<User>
}

final class DefaultSignUpUseCase :SignUpUseCase {
    private let signUpRepository: SignUpRepository
    
    init(signUpRepository: SignUpRepository) {
        self.signUpRepository = signUpRepository
    }
    
    func login() -> Single<LoginInfo> {
        signUpRepository.login()
    }
    
    func test() -> Single<User> {
        signUpRepository.test()
    }
}
