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
    private var viewControllers: [UIViewController] = []
    private var currentViewController: UIViewController?
    
    // MARK: - UI
    private var containterView = UIView()
        
    private let homeButton = UIButton().then {
        $0.layer.cornerRadius = 25
        $0.setImage(UIImage(named: "home_disabled"), for: .normal)
        $0.setImage(UIImage(named: "home_enabled"), for: .selected)
        
        $0.isSelected = true
    }
    
    private let searchButton = UIButton().then {
        $0.layer.cornerRadius = 25
        $0.setImage(UIImage(named: "search_disabled"), for: .normal)
        $0.setImage(UIImage(named: "search_enabled"), for: .selected)
    }

    
    private let bookcaseButton = UIButton().then {
        $0.layer.cornerRadius = 25
        $0.setImage(UIImage(named: "bookcase_disabled"), for: .normal)
        $0.setImage(UIImage(named: "bookcase_enabled"), for: .selected)
    }
    
    private let myButton = UIButton().then {
        $0.layer.cornerRadius = 25
        $0.setImage(UIImage(named: "my_disabled"), for: .normal)
        $0.setImage(UIImage(named: "my_enabled"), for: .selected)
    }
    
    private let tabbarView = UIView().then {
        $0.backgroundColor = .white
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
        
        for vc in viewControllers {
            (vc as? UINavigationController)?.delegate = self
        }
        
        // 앱 실행 시 homeButton을 선택된 상태로 설정
        tabSelected(at: 0)  // homeButton이 두 번째 버튼이므로 index 1로 설정
        showViewController(at: 0)  // homeViewController를 첫 화면으로 설정
    }

    // MARK: - Binding
    func bind() {
        let input = MainTabBarViewModelInput(
            homeSelected: homeButton.rx.tap.asObservable(),
            searchSelected: searchButton.rx.tap.asObservable(),
            bookcaseSelected: bookcaseButton.rx.tap.asObservable(),
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
        guard index < 4 else { return }
        
        let buttons = [homeButton, searchButton, bookcaseButton, myButton]

        // 모든 버튼 초기화
        buttons.forEach { button in
            button.isSelected = false
            button.backgroundColor = .clear
        }
        
        buttons[index].isSelected = true
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
    
    func searchTabSelected() {
        tabSelected(at: 1)
    }
}

// MARK: - Layout
extension MainTabBarViewController {
    private func setupViews() {
        view.addSubviews([
            containterView,
            tabbarView
        ])
        
        tabbarView.addSubviews([
            homeButton,
            searchButton,
            bookcaseButton,
            myButton
        ])
    }
    
    private func initialLayout() {
        containterView.snp.makeConstraints {
            $0.top.left.bottom.right.equalToSuperview()
        }
        
        tabbarView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.height.equalTo(MainTabBarSize.height)
            $0.width.equalToSuperview()
        }
        
        homeButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(tabInterval()*2)
            $0.top.equalToSuperview().offset(15)
            $0.size.equalTo(32)
        }
        
        searchButton.snp.makeConstraints {
            $0.leading.equalTo(homeButton.snp.trailing).offset(tabInterval()*3)
            $0.centerY.equalTo(homeButton)
            $0.size.equalTo(32)
        }
        
        bookcaseButton.snp.makeConstraints {
            $0.leading.equalTo(searchButton.snp.trailing).offset(tabInterval()*3)
            $0.centerY.equalTo(homeButton)
            $0.size.equalTo(36)
        }
        
        myButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(tabInterval()*2)
            $0.centerY.equalTo(homeButton)
            $0.size.equalTo(32)
        }
        
        // ViewControllers 초기화
        let homeVC = createNavController(for: HomeViewController(viewModel: DefaultHomeViewModel()))
        let searchVC = createNavController(for: SearchViewController())
        let bookcaseVC = createNavController(for: BookCaseViewController(viewModel: DefaultBookCaseViewModel()))
        let myVC = createNavController(for: MyViewController(viewModel: DefaultMyViewModel()))
        viewControllers = [homeVC, searchVC, bookcaseVC, myVC]
    }
    
    fileprivate func createNavController(for rootViewController: UIViewController) -> UIViewController {
        let navController = UINavigationController(rootViewController:  rootViewController)
        navController.isNavigationBarHidden = true
        navController.interactivePopGestureRecognizer?.delegate = nil
        return navController
    }
}

extension MainTabBarViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController,
                              animated: Bool) {

        let isRoot = viewController === navigationController.viewControllers.first

        // 루트 뷰컨트롤러일 때만 tabbar 보이게
        tabbarView.isHidden = !isRoot
    }
}

extension MainTabBarViewController {
    // 양 옆으로 2x, 탭 간격은 3x
    private func tabInterval() -> Int {
        var width = 0
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let screenWidth = windowScene.screen.bounds.width
            let interval = (screenWidth - 132) / 13
            width = Int(interval)
        }
        return width
    }
}

struct MainTabBarSize {
    static var height: CGFloat {
        return 56 + (UIApplication.shared.visibleWindow?.safeAreaInsets.bottom ?? 0)
    }
}

extension UIApplication {
    var visibleWindow: UIWindow? {
        return connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { !$0.isHidden && $0.windowLevel == .normal })
    }
}
