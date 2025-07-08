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
    func transform(input: SignUpViewModelInput)
    
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
    func transform(input: SignUpViewModelInput) {
        input.signUpAction
            .subscribe(onNext: { [weak self] type in
                self?.handleSnsSignUp(type: type)
            }).disposed(by: disposeBag)
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
        AuthService.shared.loginType
            .compactMap { $0 } // nil 거르고
            .flatMapLatest { [weak self] loginType -> Observable<Profile> in
                guard let self else { return .empty() }
                return self.signUpUseCase.login(type: LoginType(provider: loginType.provider, providerId: loginType.providerId)).asObservable()
            }
            .subscribe(
                onNext: { [weak self] loginInfo in
                    print("로그인 성공: \(loginInfo)")
                    UserDefaults.standard.nickName = loginInfo.nickname
                    self?.loginSuccess()
                },
                onError: { error in
                    print("로그인 실패: \(error)")
                }
            )
            .disposed(by: disposeBag)
    }
    
    func loginSuccess() {
            // 메인 화면으로 이동
            guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
                  let window = sceneDelegate.window else { return }

            window.rootViewController = MainTabBarViewController(viewModel: DefaultMainTabBarViewModel())

            // 전환 애니메이션 추가 (optional)
            UIView.transition(with: window,
                              duration: 0.5,
                              options: .transitionFlipFromRight,
                              animations: nil)
        }

}
