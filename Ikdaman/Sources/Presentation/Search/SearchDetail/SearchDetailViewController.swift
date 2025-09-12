//
//  SearchDetailViewController.swift
//  Ikdaman
//
//  Created by 이재혁 on 5/11/25.
//

import UIKit
import RxSwift
import RxCocoa

class SearchDetailViewController: UIViewController {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let subView = SearchDetailView()
    
    // MARK: - ViewModelProtocol
    typealias ViewModel = SearchDetailViewModel
    var viewModel: SearchDetailViewModel!
    
    /// viewDidLoad 트리거
    private var requestTrigger: PublishRelay<Void> = PublishRelay<Void>()
    /// 사용자 액션 트리거
    private let actionTriggers = PublishRelay<SearchDetailTriggerType>()
    
    private func bindingViewModel() {
        let response = viewModel.transform(req: ViewModel.Input(viewDidLoad: requestTrigger.asObservable(),
                                                                action: actionTriggers))
        
        subView
            .setupDI(book: response.bookRelay)
            .setupDI(action: actionTriggers)
        
        response.outputRequest
            .withUnretained(self)
            .subscribe(onNext: { `self`, output in
                switch output {
                case .back:
                    self.navigationController?.popViewController(animated: true)
                case .home:
                    self.navigationController?.popToRootViewController(animated: true) {
                        TabBarNavigator.shared.navigateToHome()
                        NotificationCenter.default.post(name: .reloadBookList, object: nil)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        attribute()
        bind()
        bindingViewModel()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.navigationController?.setNavigationBarHidden(true, animated: animated)
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        self.navigationController?.setNavigationBarHidden(false, animated: animated)
//    }
    
    deinit {
        print("검색 상세 deinit")
    }
    
    // MARK: - Methods
    private func setupLayout() {
        view.addSubview(subView)
        
        subView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func attribute() {
        
    }
    
    private func bind() {
        
    }
}
