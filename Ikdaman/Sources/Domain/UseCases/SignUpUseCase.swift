//
//  SignUpUseCase.swift
//  Ikdaman
//
//  Created by Soo on 4/22/25.
//

import RxSwift
import UIKit

protocol SignUpUseCase {
    func login(type: LoginType) -> Observable<Profile>
}

final class DefaultSignUpUseCase :SignUpUseCase {
    private let signUpRepository: SignUpRepository
    
    init(signUpRepository: SignUpRepository) {
        self.signUpRepository = signUpRepository
    }
    
    func login(type: LoginType) -> Observable<Profile> {
        signUpRepository.login(type: type)
            .catch { error in
                // 에러 로그 출력
                print("Login error: \(error.localizedDescription)")
                // 에러 발생 시, 빈 Observable 리턴 (또는 다른 처리)
                return Observable.empty()
            }
    }
    
}
