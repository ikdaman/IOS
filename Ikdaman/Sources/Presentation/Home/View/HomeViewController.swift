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
    private let viewModel: HomeViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializer
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func loadView() {
        self.view = homeView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        bindActions()
    }
    
    // MARK: - Binding
    private func bindViewModel() {
        let input = HomeViewModelInput(
            fetchBooks: Observable.just(0),
            selectColor: homeView.topBarView.colorPickerView.colorSelected.asObservable(),
            toggleColorPicker: homeView.topBarView.colorButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        // 컬러 버튼 배경 변경
        output.selectedColorType
            .map { $0.buttonColor }
            .bind(to: homeView.topBarView.colorButton.rx.backgroundColor)
            .disposed(by: disposeBag)
        
        // 그라데이션 배경 변경
        output.selectedColorType
            .subscribe(onNext: { [weak self] colorType in
                self?.homeView.updateBackgroundGradient(colors: colorType.gradientColors)
            })
            .disposed(by: disposeBag)
        
        // ColorPicker 열기/닫기 애니메이션
        output.isColorPickerVisible
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] isVisible in
                UIView.animate(withDuration: 0.2) {
                    self?.homeView.topBarView.colorPickerView.alpha = isVisible ? 1 : 0
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func bindActions() {
        homeView.topBarView.colorButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.toggleColorPicker()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    private func toggleColorPicker() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            let isHidden = self.homeView.topBarView.colorPickerView.alpha == 0
            self.homeView.topBarView.colorPickerView.alpha = isHidden ? 1 : 0
        }
    }
}
