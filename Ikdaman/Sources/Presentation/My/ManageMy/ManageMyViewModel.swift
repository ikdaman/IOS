//
//  ManageMyViewModel.swift
//  Ikdaman
//
//  Created by Soo on 5/19/25.
//

import RxSwift
import RxCocoa
import Foundation

struct ManageMyViewModelInput {
    let viewWillAppear: Observable<Void>
    let nicknameChanged: Observable<String>
    let birthdateChanged: Observable<String>
    let genderSelected: Observable<String>
    let saveTapped: Observable<Void>
    let logoutTapped: Observable<Void>
    let withdrawTapped: Observable<Void>
    let checkNicknameTapped: Observable<Void>
}

struct ManageMyViewModelOutput {
    let user: Observable<User>
    let saveCompleted: Signal<Void>
    let logoutCompleted: Signal<Void>
    let withdrawCompleted: Signal<Void>
    let error: Signal<String>
    let nicknameCheckResult: Signal<Bool>
}

protocol ManageMyViewModel {
    func transform(input: ManageMyViewModelInput) -> ManageMyViewModelOutput
}

final class DefaultManageMyViewModel: ManageMyViewModel {
    private let manageMyUseCase: ManageMyUseCase
    private let disposeBag = DisposeBag()
    
    private let userRelay = BehaviorRelay<User?>(value: nil)
    private let errorRelay = PublishRelay<String>()
    private let saveCompleteRelay = PublishRelay<Void>()
    private let logoutCompleteRelay = PublishRelay<Void>()
    private let withdrawCompleteRelay = PublishRelay<Void>()
    private let nicknameCheckRelay = PublishRelay<Bool>()
    
    // MARK: - Init
    init(manageMyUseCase: ManageMyUseCase = DefaultManageMyUseCase(manageMyRepository: ManageMyRepositoryImpl())) {
        self.manageMyUseCase = manageMyUseCase
    }


    func transform(input: ManageMyViewModelInput) -> ManageMyViewModelOutput {
        input.viewWillAppear
            .flatMapLatest { [weak self] in
                self?.manageMyUseCase.getUserInfo()
                    .asObservable()
                    .catchError { error in
                        print("❌ getUserInfo() 에러:", error.localizedDescription)
                        return .empty() // 또는 .just(User.default)
                    } ?? .empty()
            }
            .do(onNext: { user in
                print("👤 getUserInfo():", user)
            })
            .bind(to: userRelay)
            .disposed(by: disposeBag)

        input.nicknameChanged
            .subscribe(onNext: { [weak self] nickname in
                guard var user = self?.userRelay.value else { return }
                user.nickname = nickname
                self?.userRelay.accept(user)
            })
            .disposed(by: disposeBag)

        input.birthdateChanged
            .subscribe(onNext: { [weak self] birthdate in
                guard var user = self?.userRelay.value else { return }
                user.birthdate = birthdate
                self?.userRelay.accept(user)
            })
            .disposed(by: disposeBag)

        input.genderSelected
            .subscribe(onNext: { [weak self] gender in
                guard var user = self?.userRelay.value else { return }
                user.gender = gender
                self?.userRelay.accept(user)
            })
            .disposed(by: disposeBag)

        input.saveTapped
            .withLatestFrom(userRelay.compactMap { $0 })
            .flatMapLatest { [weak self] user in
                self?.manageMyUseCase.saveUser(user: user)
                    .asObservable()
                    .materialize() ?? .empty()
            }
            .subscribe(onNext: { [weak self] event in
                switch event {
                case .next:
                    if let nickname = self?.userRelay.value?.nickname {
                        UserDefaults.standard.nickName = nickname
                        self?.saveCompleteRelay.accept(())
                    }
                case .error(let error):
                    self?.errorRelay.accept(error.localizedDescription)
                default: break
                }
            })
            .disposed(by: disposeBag)
        
        input.logoutTapped
            .flatMapLatest { [weak self] _ -> Observable<Event<Void>> in
                guard let self = self else { return .empty() }
                return self.manageMyUseCase.logout()
                    .flatMap { response -> Single<Void> in
                        if response.statusCode == 205 {
                            return .just(())
                        } else {
                            // 실패: 에러 반환
                            return .error(NSError(domain: "", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: "Logout failed with status: \(response.statusCode)"]))
                        }
                    }
                    .asObservable()
                    .materialize()
            }
            .subscribe(onNext: { [weak self] event in
                switch event {
                case .completed:
                    AuthService.shared.logout()
                    self?.logoutCompleteRelay.accept(())
                case .error(let error):
                    AuthService.shared.logout()
                    self?.errorRelay.accept(error.localizedDescription)
                default: break
                }
            })
            .disposed(by: disposeBag)

        input.withdrawTapped
            .flatMapLatest { [weak self] in
                guard let self = self else {
                    return Observable<Event<Void>>.empty()
                }
                
                return self.manageMyUseCase.withdraw()
                    .flatMap { response -> Single<Void> in
                        if response.statusCode == 205 {
                            return .just(())
                        } else {
                            return .error(NSError(domain: "", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: "Logout failed with status: \(response.statusCode)"]))
                        }
                    }
                    .asObservable()
                    .materialize()
            }
            .subscribe(onNext: { [weak self] event in
                switch event {
                case .completed:
                    AuthService.shared.logout()
                    self?.withdrawCompleteRelay.accept(())
                case .error(let error):
                    self?.errorRelay.accept(error.localizedDescription)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)

        
        input.checkNicknameTapped
            .withLatestFrom(userRelay.compactMap { $0 })
            .flatMapLatest { [weak self] user in
                self?.manageMyUseCase.checkNicknameDuplication(nickname: user.nickname ?? "")
                    .asObservable()
                    .materialize() ?? .empty()
            }
            .subscribe(onNext: { [weak self] event in
                switch event {
                case .next(let isDuplicated):
                    self?.nicknameCheckRelay.accept(isDuplicated)
                case .error(let error):
                    self?.errorRelay.accept(error.localizedDescription)
                default: break
                }
            })
            .disposed(by: disposeBag)

        return ManageMyViewModelOutput(
            user: userRelay.compactMap { $0 }.asObservable(),
            saveCompleted: saveCompleteRelay.asSignal(),
            logoutCompleted: logoutCompleteRelay.asSignal(),
            withdrawCompleted: withdrawCompleteRelay.asSignal(),
            error: errorRelay.asSignal(),
            nicknameCheckResult: nicknameCheckRelay.asSignal()
        )
    }
}
