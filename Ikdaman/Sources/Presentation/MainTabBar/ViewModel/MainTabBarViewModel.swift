//
//  MainTabBarViewModel.swift
//  Ikdaman
//
//  Created by 김창규 on 2/20/25.
//

import UIKit
import RxSwift

struct MainTabBarViewModelInput {
    var homeSelected: Observable<Void>
    var searchSelected: Observable<Void>
    var bookcaseSelected: Observable<Void>
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
        let buttonSelections = Observable.merge(
            input.homeSelected.map { 0 },
            input.searchSelected.map { 1 },
            input.bookcaseSelected.map { 2 },
            input.mySelected.map { 3 }
        )
        
        Observable.merge(
            buttonSelections,
            TabBarNavigator.shared.tabSelection
        )
        .bind(to: selectedScene)
        .disposed(by: disposeBag)
        
        return MainTabBarViewModelOutput(selectedScene: selectedScene.asObserver())
    }
    
}

final class TabBarNavigator {
    static let shared = TabBarNavigator()
    let tabSelection = PublishSubject<Int>()
    
    private init() {}
    
    func navigateToHome() {
        tabSelection.onNext(0)
    }
    
    func navigateToSearch() {
        tabSelection.onNext(1)
    }
    
    func navigateToBookcase() {
        tabSelection.onNext(2)
    }
    
    func navigateToMy() {
        tabSelection.onNext(3)
    }
    
    func navigateTo(tab: Int) {
        tabSelection.onNext(tab)
    }
}
