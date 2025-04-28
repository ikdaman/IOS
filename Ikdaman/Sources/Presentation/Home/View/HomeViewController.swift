//
//  HomeViewController.swift
//  Ikdaman
//
//  Created by 김창규 on 2/11/25.
//

import UIKit
import RxSwift
import RxCocoa

final class HomeViewController: BaseViewController {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    private let viewModel: HomeViewModel
    
    // MARK: - UI
    
    private let searchBtn = UIButton().then {
        $0.setTitle("테스트용 검색 버튼", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.backgroundColor = .white
    }
    
    // MARK: - Init
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        initialLayout()
        
        bind()
        view.backgroundColor = .orange
    }
    
    private func bind() {
        let input = HomeViewModelInput(
            fetchBooks: Observable.just(0) // userId
        )
        let output = viewModel.transform(input: input)
        
        output.books
            .bind { [weak self] _ in
                // tableView 업데이트
            }.disposed(by: disposeBag)
        
        searchBtn.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                let vc = SearchViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Layout
extension HomeViewController {
    private func setupViews() {
        view.addSubview(searchBtn)
        searchBtn.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-100)
            $0.width.equalTo(60)
            $0.height.equalTo(30)
        }
    }
    
    private func initialLayout() {
        
    }
}
