//
//  SearchView.swift
//  Ikdaman
//
//  Created by 이재혁 on 4/20/25.
//

import UIKit
import RxSwift
import RxCocoa

class SearchView: UIView {
    private let disposeBag = DisposeBag()
    private let actionTriggers = PublishRelay<SearchTriggerType>()
    
    // MARK: - Properties
    private lazy var searchContainerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 30
        $0.clipsToBounds = true
        
        $0.addSubviews([searchTextField, searchButton])
        
        searchTextField.snp.makeConstraints {
            $0.left.equalToSuperview().inset(22)
            $0.right.equalTo(searchButton.snp.left).offset(-10)
            $0.verticalEdges.equalToSuperview()
        }
        
        searchButton.snp.makeConstraints {
            $0.verticalEdges.right.equalToSuperview().inset(5)
            $0.size.equalTo(45)
        }
    }
    
    private let searchTextField = UITextField().then {
        $0.placeholder = "책 제목을 검색해주세요."
        $0.backgroundColor = .clear
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.borderStyle = .none
    }
    
    private let searchButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_magnifier"), for: .normal)
        $0.backgroundColor = UIColor(hex: "36271D")
        $0.layer.cornerRadius = 45 / 2
    }
    
    private lazy var noResultBookView = UIView().then {
        $0.addSubviews([searchedBookLabel, noBookLabel])
        
        searchedBookLabel.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
        }
        
        noBookLabel.snp.makeConstraints {
            $0.top.equalTo(searchedBookLabel.snp.bottom)
            $0.horizontalEdges.bottom.equalToSuperview()
            $0.centerX.equalTo(searchedBookLabel)
        }
        
        $0.isHidden = true
    }
    
    private let searchedBookLabel = UILabel().then {
        $0.textColor = .black
        $0.font = .systemFont(ofSize: 15, weight: .bold)
        $0.textAlignment = .center
    }
    
    private let noBookLabel = UILabel().then {
        $0.text = "에 대한 검색결과가 없어요.\n\n검색 결과를 다시한번 확인해 주세요."
        $0.textColor = .black
        $0.font = .systemFont(ofSize: 15, weight: .regular)
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    private let enterDirectlyBtn = UIButton().then {
        let attributedString = NSAttributedString(
            string: "직접 입력하기",
            attributes: [
                .font: UIFont.systemFont(ofSize: 12, weight: .bold),
                .foregroundColor: UIColor.black,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
        )
        $0.setAttributedTitle(attributedString, for: .normal)
    }
    
    private lazy var tableView = UITableView().then {
        $0.backgroundColor = .clear
        $0.estimatedRowHeight = 144
        $0.delegate = self
//        $0.dataSource = self
        $0.register(SearchResultsCell.self, forCellReuseIdentifier: SearchResultsCell.identifier)
    }


    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        attribute()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        applyGradient(to: self)
    }
    
    // MARK: - Methods
    private func setupLayout() {
        addSubviews([searchContainerView, noResultBookView, tableView])
        
        // SnapKit을 사용한 레이아웃 설정
        searchContainerView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(55)
        }
        
        noResultBookView.snp.makeConstraints {
            $0.center.equalTo(tableView)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(searchContainerView.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(safeAreaInsets.bottom + 60)
        }
    }
    
    private func attribute() {
        applyGradient(to: self)
    }
    
    private func bind() {
        searchTextField.rx.text
            .orEmpty
            .distinctUntilChanged()
            .map { .searchQuery($0) }
            .bind(to: actionTriggers)
            .disposed(by: disposeBag)
        
        searchButton.rx.tap
            .map { .searchBtnTapped }
            .bind(to: actionTriggers)
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(AladinBook.self)
            .map { .selectBook($0) }
            .bind(to: actionTriggers)
            .disposed(by: disposeBag)
    }
    
    func applyGradient(to view: UIView) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor(hex: "BE9FD9", alpha: 1).cgColor,
            UIColor.white.cgColor
        ]
        
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        view.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // MARK: - Data Binding
    @discardableResult
    func setupDI(searchBookResults: Observable<[AladinBook]>, searchQuery: BehaviorRelay<String>) -> Self {
        searchBookResults
            .skip(1)
            .withUnretained(self)
            .subscribe(onNext: { `self`, books in
                self.noResultBookView.isHidden = !books.isEmpty
                guard books.isEmpty else { return }
                self.searchedBookLabel.text = searchQuery.value
//                self.tableView.isHidden = books.isEmpty
            })
            .disposed(by: disposeBag)
        
        searchBookResults.bind(to: tableView.rx.items(cellIdentifier: SearchResultsCell.identifier, cellType: SearchResultsCell.self)) { row, book, cell in
            cell.backgroundColor = .clear
            cell.configure(image: book.cover, title: book.title, subtitle: book.author)
        }.disposed(by: disposeBag)
        
        return self
    }
    
    /// 유저 액션
    @discardableResult
    func setupDI(action: PublishRelay<SearchTriggerType>) -> Self {
        actionTriggers
            .bind(to: action)
            .disposed(by: disposeBag)
        
        return self
    }
}

extension SearchView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultsCell.identifier, for: indexPath) as? SearchResultsCell else { return UITableViewCell() }
        cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 144
    }
}

extension UIColor {
    
}
