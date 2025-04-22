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

// [START] Interface
//struct SignUpViewModelActions {
//    let signUpAction: Observable<SignUpActionType>
//    let setNickname: Observable<Void>
//}

struct SignUpViewModelInput {
    let signUpAction: Observable<SnsType>
//    let isVaildNickname: Observable<String>
//    let completeSignUp: Observable<Void>
}

struct SignUpViewModelOutput {
    var passSnsLogin: PublishSubject<Bool>
//    var isValidNickName: PublishSubject<Bool>
//    var completeSignUp: PublishSubject<Void>
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
    }

    // MARK: - Methods
    func transform(input: SignUpViewModelInput) -> SignUpViewModelOutput {
        input.signUpAction
            .subscribe(onNext: { [weak self] type in
                self?.handleSnsSignUp(type: type)
//                self?.test()
            }).disposed(by: disposeBag)
        
//        input.isVaildNickname
//            .subscribe(onNext: { [weak self] nickname in
//                self?.isValidNickname(nickname: nickname)
//            }).disposed(by: disposeBag)
//
//        input.completeSignUp
//            .subscribe(onNext: { [weak self] _ in
//                self?.completedSignUp()
//            }).disposed(by: disposeBag)

        return SignUpViewModelOutput(passSnsLogin: passSnsLogin.asObserver())
//                                     ,
//                                     isValidNickName: isValidNickName.asObserver(), completeSignUp: completeSignUp.asObserver())
    }
    

    // MARK: - Private Methods
    
    private func handleSnsSignUp(type: SnsType) {
        switch type {
        case .google(let viewController):
            AuthService.shared.googleLoginPase(viewcontroller: viewController)
        case .naver:
            AuthService.shared.getInstance()
        case .kakao:
            AuthService.shared.kakaoLogin()
        case .apple:
            AuthService.shared.requestAppleIdProvider()
        }
    }
    
    private func test() {
        signUpUseCase.test()
            .subscribe { event in
                switch event {
                case .success(let loginInfo):
                    print(loginInfo)
                case .failure(let error):
                    print(error)
                }
            }.disposed(by: disposeBag)
            
    }
    
    private func isValidNickname(nickname: String) {
        
    }
    
    private func completedSignUp() {
        
    }
}
