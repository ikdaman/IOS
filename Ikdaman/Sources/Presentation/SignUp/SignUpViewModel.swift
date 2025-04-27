//
//  SignUpViewModel.swift
//  Ikdaman
//
//  Created by Soo on 4/22/25.
//

import Foundation
import RxSwift
import UIKit

enum SnsType {
    case google(viewController: UIViewController)
    case naver
    case kakao
    case apple
}

struct SignUpViewModelInput {
    let signUpAction: Observable<SnsType>
}

struct SignUpViewModelOutput {
    var passSnsLogin: PublishSubject<Bool>
}

protocol SignUpViewModel {
    //MARK: - Binding
    func transform(input: SignUpViewModelInput) -> SignUpViewModelOutput
    
    // 기능 인터페이스 추가
}

// [END] Interface

final class DefaultSignUpViewModel: SignUpViewModel {
    // MARK: - Properties
    private var disposeBag = DisposeBag()
    private let signUpUseCase: SignUpUseCase

    // MARK: - Output
    let passSnsLogin = PublishSubject<Bool>()
    let isValidNickName = PublishSubject<Bool>()
    let completeSignUp = PublishSubject<Void>()
    
    let profile = PublishSubject<[User]>()

    // MARK: - Init
    init(signUpUseCase: SignUpUseCase = DefaultSignUpUseCase(
        signUpRepository: SignUpRepositoryImpl()
    )) {
        self.signUpUseCase = signUpUseCase
        bindAuthToken()
    }

    // MARK: - Methods
    func transform(input: SignUpViewModelInput) -> SignUpViewModelOutput {
        input.signUpAction
            .subscribe(onNext: { [weak self] type in
                self?.handleSnsSignUp(type: type)
            }).disposed(by: disposeBag)

        return SignUpViewModelOutput(passSnsLogin: passSnsLogin.asObserver())
    }

    // MARK: - Private Methods
    
    private func handleSnsSignUp(type: SnsType) {
        switch type {
        case .google(let viewController):
            AuthService.shared.googleLogin(viewController: viewController) { _,_ in }
        case .naver:
            AuthService.shared.getInstance()
        case .kakao:
            AuthService.shared.kakaoLogin()
        case .apple:
            AuthService.shared.requestAppleIdProvider()
        }
    }
    
    private func bindAuthToken() {
        AuthService.shared.token
            .compactMap { $0 } // nil 거르고
            .flatMapLatest { [weak self] token -> Observable<LoginInfo> in
                guard let self else { return .empty() }
                return self.signUpUseCase.login().asObservable()
            }
            .subscribe(
                onNext: { [weak self] loginInfo in
                    print("로그인 성공: \(loginInfo)")
                    self?.passSnsLogin.onNext(true)
                },
                onError: { error in
                    print("로그인 실패: \(error)")
                }
            )
            .disposed(by: disposeBag)
    }

}
