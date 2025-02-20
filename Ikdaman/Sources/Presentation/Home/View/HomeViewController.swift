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
    private let bannerView = UIView().then {
        /// #5B4746
        $0.backgroundColor = UIColor(red: 91/255, green: 71/255, blue: 70/255, alpha: 1)
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "지금 읽고 있는 책을 추가해보세요."
    }
    
    private let addButton = UIButton().then {
        $0.layer.cornerRadius = 5
        $0.backgroundColor = .white
        $0.layer.shadowOpacity = 0.10
        $0.layer.shadowRadius = 10
        $0.layer.shadowOffset = .zero
        $0.setTitle("새 책 추가하기", for: .normal)
        $0.setTitleColor(.black, for: .normal)
    }
    
    private lazy var bookTableView: UITableView = {
        var tableView = UITableView(frame: .zero, style: .plain)
//        tableView.register(ComentCell.self, forCellReuseIdentifier: ComentCell.id)
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 184 // 기본 높이 설정 추가
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
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
    }
}

// MARK: - Layout
extension HomeViewController {
    private func setupViews() {
        view.addSubview(bannerView)
        view.addSubview(titleLabel)
        view.addSubview(addButton)
        view.addSubview(bookTableView)
    }
    
    private func initialLayout() {
        bannerView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(231)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(bannerView.snp.bottom).offset(36)
            $0.left.equalToSuperview().inset(20)
        }
        
        addButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.left.right.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }
        bookTableView.backgroundColor = .orange
        bookTableView.snp.makeConstraints {
            $0.top.equalTo(addButton.snp.bottom).offset(32)
            $0.left.bottom.right.equalToSuperview()
        }
    }
}
