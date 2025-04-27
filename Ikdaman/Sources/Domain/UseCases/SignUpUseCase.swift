//
//  SignUpUseCase.swift
//  Ikdaman
//
//  Created by Soo on 4/22/25.
//

import RxSwift
import UIKit

protocol SignUpUseCase {
    func login() -> Observable<LoginInfo>
}

final class DefaultSignUpUseCase :SignUpUseCase {
    private let signUpRepository: SignUpRepository
    
    init(signUpRepository: SignUpRepository) {
        self.signUpRepository = signUpRepository
    }
    
    func login() -> Observable<LoginInfo> {
        signUpRepository.login()
    }
    
}
