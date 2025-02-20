//
//  MainTabBarViewController.swift
//  Ikdaman
//
//  Created by 김창규 on 2/20/25.
//

import UIKit
import RxSwift

extension UIStackView {
    static func make(
        with subviews: [UIView],
        axis: NSLayoutConstraint.Axis = .horizontal,
        alignment: UIStackView.Alignment = .fill,
        distribution: Distribution = .fill,
        spacing: CGFloat = 0
    ) -> UIStackView {
        let view = UIStackView(arrangedSubviews: subviews)
        view.axis = axis
        view.alignment = alignment
        view.distribution = distribution
        view.spacing = spacing
        return view
    }
}

final class MainTabBarViewController: BaseViewController {
    // MARK: - Properties
    private let viewModel: MainTabBarViewModel
    private let disposeBag = DisposeBag()
    private var animator: UIViewPropertyAnimator?
    private var viewControllers: [UIViewController] = []
    private var currentViewController: UIViewController?
    
    // MARK: - UI
    private let containterView = UIView()
    
    private let bookcaseButton = UIButton().then {
        $0.layer.cornerRadius = 25
        $0.setImage(UIImage(named: "Book"), for: .normal)
        $0.setImage(UIImage(named: "Book_selected"), for: .selected)
    }
    
    private let homeButton = UIButton().then {
        $0.layer.cornerRadius = 25
        $0.setImage(UIImage(named: "Home"), for: .normal)
        $0.setImage(UIImage(named: "Home_selected"), for: .selected)
        
        $0.isSelected = true
    }
    
    private let myButton = UIButton().then {
        $0.layer.cornerRadius = 25
        $0.setImage(UIImage(named: "User"), for: .normal)
        $0.setImage(UIImage(named: "User"), for: .selected)
    }
    
    private let buttonBackground = UIView().then {
        $0.layer.cornerRadius = 25
        /// #36271D
        $0.backgroundColor = UIColor(red: 54/255, green: 39/255, blue: 29/255, alpha: 1)
    }
    
    private let tabbarView = UIView().then {
        $0.layer.cornerRadius = 30
        $0.backgroundColor = .white
        $0.layer.shadowOpacity = 0.15
        $0.layer.shadowRadius = 10
        $0.layer.shadowOffset = .zero
    }
    
    // MARK: - Init
    init(viewModel: MainTabBarViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        initialLayout()
        
        bind()
        
        // 앱 실행 시 homeButton을 선택된 상태로 설정
        tabSelected(at: 1)  // homeButton이 두 번째 버튼이므로 index 1로 설정
        showViewController(at: 1)  // homeViewController를 첫 화면으로 설정
    }

    // MARK: - Binding
    func bind() {
        let input = MainTabBarViewModelInput(
            bookcaseSelected: bookcaseButton.rx.tap.asObservable(),
            homeSelected: homeButton.rx.tap.asObservable(),
            mySelected: myButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.selectedScene
            .bind { [weak self] index in
                self?.tabSelected(at: index)
                self?.showViewController(at: index)
            }.disposed(by: disposeBag)
        
    }
    
    // MARK: - Method
    // Private
    private func tabSelected(at index: Int) {
        guard index < 3 else { return }
        
        let buttons = [bookcaseButton, homeButton, myButton]

        // 모든 버튼 초기화
        buttons.forEach { button in
            button.isSelected = false
            button.backgroundColor = .clear
        }
        
        // 선택된 버튼 업데이트
        let selectedButton = buttons[index]
        
        animator?.stopAnimation(true) // 이전 애니메이션을 중지합니다.
        
        animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
            self.buttonBackground.snp.remakeConstraints {
                $0.center.equalTo(selectedButton)
                $0.size.equalTo(50)
            }
            
            self.tabbarView.layoutIfNeeded()
        }
        
        animator?.addCompletion { _ in
            selectedButton.isSelected = true
        }
        
        animator?.startAnimation()
    }
    
    private func showViewController(at index: Int) {
        guard index < viewControllers.count else { return }
        
        let selectedVC = viewControllers[index]
        
        // 이전 뷰 컨트롤러 제거
        if let currentVC = currentViewController {
            currentVC.willMove(toParent: nil)
            currentVC.view.removeFromSuperview()
            currentVC.removeFromParent()
        }
        
        // 새로운 뷰 컨트롤러 추가
        addChild(selectedVC)
        selectedVC.view.frame = containterView.bounds
        containterView.addSubview(selectedVC.view)
        selectedVC.didMove(toParent: self)
        
        // 현재 뷰 컨트롤러 업데이트
        currentViewController = selectedVC
    }
}

// MARK: - Layout
extension MainTabBarViewController {
    private func setupViews() {
        view.addSubview(containterView)
        view.addSubview(tabbarView)
        
        tabbarView.addSubview(buttonBackground)
        tabbarView.addSubview(bookcaseButton)
        tabbarView.addSubview(homeButton)
        tabbarView.addSubview(myButton)
    }
    
    private func initialLayout() {
        containterView.snp.makeConstraints {
            $0.top.left.bottom.right.equalToSuperview()
        }
        
        tabbarView.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(40)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(60)
            $0.width.equalTo(176)
        }
        
        bookcaseButton.snp.makeConstraints {
            $0.top.left.bottom.equalToSuperview().inset(5)
            $0.size.equalTo(50)
        }
        
        homeButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(5)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(50)
        }
        
        myButton.snp.makeConstraints {
            $0.top.bottom.right.equalToSuperview().inset(5)
            $0.size.equalTo(50)
        }
        
        buttonBackground.snp.makeConstraints {
            $0.center.equalTo(homeButton)
            $0.size.equalTo(50)
        }
        
        // ViewControllers 초기화
        let bookcaseVC = UIViewController().then { $0.view.backgroundColor = .red }
        let homeVC =  HomeViewController(viewModel: DefaultHomeViewModel()).then { $0.view.backgroundColor = .orange }
        let myVC =  UIViewController().then { $0.view.backgroundColor = .blue }
        viewControllers = [bookcaseVC, homeVC, myVC]
    }
}
