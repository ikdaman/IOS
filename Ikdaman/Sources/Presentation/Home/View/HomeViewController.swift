//
//  HomeViewController.swift
//  Ikdaman
//
//  Created by 김창규 on 2/11/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class HomeViewController: BaseViewController {
    
    // MARK: - Properties
    private let homeView = HomeView()
    typealias ViewModel = HomeViewModel
    private let viewModel = HomeViewModel()
    private let disposeBag = DisposeBag()
    
    /// viewDidLoad 트리거
    private var requestTrigger: PublishRelay<Void> = PublishRelay<Void>()
    /// 사용자 액션 트리거
    private let actionTriggers = PublishRelay<HomeTriggerType>()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        bindViewModel()
        
        requestTrigger.accept(())
    }
    
    private func setupLayout() {
        view.addSubview(homeView)
        homeView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    // MARK: - Binding
    private func bindViewModel() {
        let response = viewModel.transform(req: ViewModel.Input(viewDidLoad: requestTrigger.asObservable(),
                                                                action: actionTriggers))
        
        homeView
            .setupDI(colorType: response.selectedColorType)
            .setupDI(readingBooks: response.readingBooks)
            .setupDI(action: actionTriggers)
        
//        // ColorPicker 열기/닫기 애니메이션
//        output.isColorPickerVisible
//            .distinctUntilChanged()
//            .subscribe(onNext: { [weak self] isVisible in
//                UIView.animate(withDuration: 0.2) {
//                    self?.homeView.topBarView.colorPickerView.alpha = isVisible ? 1 : 0
//                }
//            })
//            .disposed(by: disposeBag)
    }
}
