//
//  SearchViewController.swift
//  Ikdaman
//
//  Created by 이재혁 on 4/20/25.
//

import UIKit
import RxSwift
import RxCocoa

class SearchViewController: BaseViewController {
    // MARK: - Properties
    private let subView = SearchView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        navigationItem.title = "책 제목으로 검색하기"
    }
    
    // MARK: - Methods
    private func setupLayout() {
        
    }
    
    private func bind() {
        
    }
}
