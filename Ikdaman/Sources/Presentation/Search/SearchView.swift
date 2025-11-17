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
    let topBarView = CustomTopBarView(centerTitle: "책 제목으로 검색하기", isHiddenBackBtn: true)
    
    private lazy var searchContainerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 5
        $0.clipsToBounds = true
        
        $0.addSubviews([searchTextField, cameraBtn, searchBtn])
        
        searchTextField.snp.makeConstraints {
            $0.verticalEdges.left.equalToSuperview().inset(15)
            $0.right.equalTo(cameraBtn.snp.left).offset(-10)
        }
        
        cameraBtn.snp.makeConstraints {
            $0.right.equalTo(searchBtn.snp.left).offset(-9)
            $0.centerY.equalTo(searchBtn)
            $0.size.equalTo(24)
        }
        
        searchBtn.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(12)
            $0.right.equalToSuperview().inset(15)
            $0.size.equalTo(24)
        }
    }
    
    private let searchTextField = UITextField().then {
        $0.placeholder = "책 제목을 검색해주세요."
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.borderStyle = .none
    }
    
    private let cameraBtn = UIButton().then {
        $0.setImage(UIImage(named: "ic_camera"), for: .normal)
    }
    
    private let searchBtn = UIButton().then {
        $0.setImage(UIImage(named: "ic_magnifier"), for: .normal)
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
        $0.separatorStyle = .none
        $0.delegate = self
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
        addSubviews([topBarView, searchContainerView, noResultBookView, tableView])
        
        topBarView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(10)
            $0.horizontalEdges.equalToSuperview()
        }
        
        searchContainerView.snp.makeConstraints {
            $0.top.equalTo(topBarView.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        noResultBookView.snp.makeConstraints {
            $0.center.equalTo(tableView)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(searchContainerView.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-MainTabBarSize.height)
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
        
        searchTextField.rx.controlEvent(.editingDidEndOnExit)
            .withLatestFrom(searchTextField.rx.text.orEmpty)
            .map { .searchReturnKeyTapped($0) }
            .bind(to: actionTriggers)
            .disposed(by: disposeBag)
        
        cameraBtn.rx.tap
            .map { .cameraBtnTapped }
            .bind(to: actionTriggers)
            .disposed(by: disposeBag)
        
        searchBtn.rx.tap
            .do(onNext: { [weak self] in
                self?.endEditing(true)
            })
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
        
        var searchResultsCount = 0
        
        searchBookResults
            .do(onNext: { results in
                searchResultsCount = results.count
            })
            .bind(to: tableView.rx.items(cellIdentifier: SearchResultsCell.identifier, cellType: SearchResultsCell.self)) { row, book, cell in
                let isLast = row == searchResultsCount - 1
                cell.backgroundColor = .clear
                cell.configure(image: book.cover, title: book.title, subtitle: book.author, isLast: isLast)
                
                cell.addBookContainerView.rx.tap
                    .subscribe(onNext: { [weak self] in
                        print("추가한 책 > \(book.title)")
                    })
                    .disposed(by: cell.disposeBag)
            }.disposed(by: disposeBag)
        
        tableView.rx.contentOffset
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { `self`, offset in
                let contentHeight = self.tableView.contentSize.height
                let tableHeight = self.tableView.frame.height
                let scrollOffset = offset.y
                
                // 스크롤이 끝에서 100pt 정도 남았을 때 추가 로딩
                if scrollOffset + tableHeight >= contentHeight - 100 {
                    self.actionTriggers.accept(.loadMoreBooks)
                }
            })
            .disposed(by: disposeBag)
        
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
