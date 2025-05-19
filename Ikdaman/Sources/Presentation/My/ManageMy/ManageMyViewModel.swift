//
//  ManageMyViewModel.swift
//  Ikdaman
//
//  Created by Soo on 5/19/25.
//

import RxSwift
import RxCocoa

struct ManageMyViewModelInput {
    let viewWillAppear: Observable<Void>
    let nicknameChanged: Observable<String>
    let birthdateChanged: Observable<String>
    let genderSelected: Observable<String>
    let saveTapped: Observable<Void>
    let logoutTapped: Observable<Void>
    let withdrawTapped: Observable<Void>
}

struct ManageMyViewModelOutput {
    let user: Driver<User>
    let saveCompleted: Signal<Void>
    let logoutCompleted: Signal<Void>
    let withdrawCompleted: Signal<Void>
    let error: Signal<String>
}

protocol ManageMyViewModel {
    func transform(input: SignUpViewModelInput)
}

final class DefaultManageMyViewModel {
    private let manageMyUseCase: ManageMyUseCase
    private let disposeBag = DisposeBag()
    
    private let userRelay = BehaviorRelay<User?>(value: nil)
    private let errorRelay = PublishRelay<String>()
    private let saveCompleteRelay = PublishRelay<Void>()
    private let logoutCompleteRelay = PublishRelay<Void>()
    private let withdrawCompleteRelay = PublishRelay<Void>()
    
    // MARK: - Init
    init(manageMyUseCase: ManageMyUseCase = DefaultManageMyUseCase(manageMyRepository: ManageMyUseCaseImpl())) {
        self.manageMyUseCase = manageMyUseCase
    }


    func transform(input: ManageMyViewModelInput) -> ManageMyViewModelOutput {
        input.viewWillAppear
            .flatMapLatest { [weak self] in
                self?.manageMyUseCase.getUserInfo().asObservable() ?? .empty()
            }
            .bind(to: userRelay)
            .disposed(by: disposeBag)

        input.nicknameChanged
            .subscribe(onNext: { [weak self] nickname in
                guard var user = self?.userRelay.value else { return }
                user.nickName = nickname
                self?.userRelay.accept(user)
            })
            .disposed(by: disposeBag)

        input.birthdateChanged
            .subscribe(onNext: { [weak self] birthdate in
                guard var user = self?.userRelay.value else { return }
                user.birthDate = birthdate
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
                case .completed:
                    self?.saveCompleteRelay.accept(())
                case .error(let error):
                    self?.errorRelay.accept(error.localizedDescription)
                default: break
                }
            })
            .disposed(by: disposeBag)

        input.logoutTapped
            .flatMapLatest { [weak self] in
                self?.manageMyUseCase.logout().asObservable().materialize() ?? .empty()
            }
            .subscribe(onNext: { [weak self] event in
                switch event {
                case .completed:
                    self?.logoutCompleteRelay.accept(())
                case .error(let error):
                    self?.errorRelay.accept(error.localizedDescription)
                default: break
                }
            })
            .disposed(by: disposeBag)

        input.withdrawTapped
            .flatMapLatest { [weak self] in
                self?.manageMyUseCase.withdraw().asObservable().materialize() ?? .empty()
            }
            .subscribe(onNext: { [weak self] event in
                switch event {
                case .completed:
                    self?.withdrawCompleteRelay.accept(())
                case .error(let error):
                    self?.errorRelay.accept(error.localizedDescription)
                default: break
                }
            })
            .disposed(by: disposeBag)

        return ManageMyViewModelOutput(
            user: userRelay.compactMap { $0 }.asDriver(onErrorDriveWith: .empty()),
            saveCompleted: saveCompleteRelay.asSignal(),
            logoutCompleted: logoutCompleteRelay.asSignal(),
            withdrawCompleted: withdrawCompleteRelay.asSignal(),
            error: errorRelay.asSignal()
        )
    }
}
