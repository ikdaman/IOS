//
//  SearchViewController.swift
//  Ikdaman
//
//  Created by 이재혁 on 4/20/25.
//

import UIKit
import RxSwift
import RxCocoa

class SearchViewController: UIViewController {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    private let subView = SearchView()
    
    // MARK: - ViewModelProtocol
    typealias ViewModel = SearchViewModel
    var viewModel = SearchViewModel()
    
    /// viewDidLoad 트리거
    private var requestTrigger: PublishRelay<Void> = PublishRelay<Void>()
    /// 사용자 액션 트리거
    private let actionTriggers = PublishRelay<SearchTriggerType>()
    
    private func bindingViewModel() {
        let response = viewModel.transform(req: ViewModel.Input(viewDidLoad: requestTrigger.asObservable(),
                                                                action: actionTriggers))
        
        subView
            .setupDI(searchBookResults: response.searchBooks, searchQuery: response.searchQuery)
            .setupDI(action: actionTriggers)
        
        response.outputRequest
            .withUnretained(self)
            .subscribe(onNext: { `self`, output in
                switch output {
                case .detailBook(let book):
                    let vc = SearchDetailViewController()
                    vc.viewModel = SearchDetailViewModel(book: book)
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                case .barcodeScanner:
                    let vc = BarcodeScannerViewController()
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomBackButton()
        setupLayout()
        bindingViewModel()
        
        requestTrigger.accept(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(true, animated: false)
//        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    // MARK: - Methods
    private func setupLayout() {
        view.addSubview(subView)
        
        subView.snp.makeConstraints {
            $0.directionalEdges.equalToSuperview()
        }
    }
    
    private func bind() {
        
    }
}
