//
//  MainTabBarViewModel.swift
//  Ikdaman
//
//  Created by 김창규 on 2/20/25.
//

import UIKit
import RxSwift

struct MainTabBarViewModelInput {
    var bookcaseSelected: Observable<Void>
    var homeSelected: Observable<Void>
    var mySelected: Observable<Void>
}

struct MainTabBarViewModelOutput {
    var selectedScene = PublishSubject<Int>()
}

struct MainTabBarViewModelRoute {
    var backward = PublishSubject<Void>()
}

struct MainTabBarViewModelRouteInputs {
    
}

protocol MainTabBarViewModel {
    // MARK: - Binding
    func transform(input: MainTabBarViewModelInput) -> MainTabBarViewModelOutput
}

final class DefaultMainTabBarViewModel: MainTabBarViewModel {
    
    // MARK: - Properties
    private var disposeBag = DisposeBag()

    // MARK: - Init
    init() {
    }
    
    // MARK: - Output
    var selectedScene = PublishSubject<Int>()
    
    // MARK: - Methods
    func transform(input: MainTabBarViewModelInput) -> MainTabBarViewModelOutput {
        input.bookcaseSelected
            .map { _ in 0 }
            .bind(to: selectedScene)
            .disposed(by: disposeBag)
        
        input.homeSelected
            .map { _ in 1 }
            .bind(to: selectedScene)
            .disposed(by: disposeBag)
        
        input.mySelected
            .map { _ in 2 }
            .bind(to: selectedScene)
            .disposed(by: disposeBag)
        
        return MainTabBarViewModelOutput(selectedScene: selectedScene.asObserver())
    }
    
}
