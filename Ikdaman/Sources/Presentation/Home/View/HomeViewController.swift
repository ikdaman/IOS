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
    //MARK: - Properties
    var disposeBag = DisposeBag()
    private let viewModel: HomeViewModel
    
    //MARK: - UI
    
    //MARK: - Init
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
    }
    
    private func bind() {
        let input = HomeViewModelInput(
            fetchBooks: Observable.just(0) // userId
        )
        let output = viewModel.transform(input: input)
        
        output.books
            .bind { [weak self] books in
                // tableView 업데이트
            }.disposed(by: disposeBag)
    }
}

//MARK: - Layout
extension HomeViewController {
    private func setupViews() {
        
    }
    
    private func initialLayout() {
        
    }
}

