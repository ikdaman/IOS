//
//  SearchDetailView.swift
//  Ikdaman
//
//  Created by 이재혁 on 5/11/25.
//

import UIKit
import RxSwift
import RxCocoa

class SearchDetailView: UIView {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let actionTriggers = PublishRelay<SearchDetailTriggerType>()
    
    private lazy var naviBarView = UIView().then {
        $0.addSubviews([backBtn, naviTitleLabel])
        
        backBtn.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(12)
            $0.left.equalToSuperview().inset(13)
            $0.size.equalTo(26)
        }
        
        naviTitleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backBtn)
        }
    }
    
    private let backBtn = UIButton().then {
        $0.setImage(UIImage(named: "arrow_left"), for: .normal)
        $0.contentMode = .scaleAspectFit
    }
    
    private let naviTitleLabel = UILabel().then {
        $0.text = "나의 새로운 책"
        $0.textColor = .black
        $0.font = .systemFont(ofSize: 18, weight: .semibold)
    }
    
    private let bookImageView = UIImageView().then {
        $0.backgroundColor = .red
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var containerStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 30
        
        $0.addArrangedSubviews([bookInfoStackView])
    }
    
    private lazy var bookInfoStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 10
        
        $0.addArrangedSubviews([titleInfoView, authorInfoView, publisherInfoView, priceInfoView])
    }
    
    private let titleInfoView = BookInfoLabelView(title: "", content: "")
    private let authorInfoView = BookInfoLabelView(title: "", content: "")
    private let publisherInfoView = BookInfoLabelView(title: "", content: "")
    private let priceInfoView = BookInfoLabelView(title: "", content: "") // 총 페이지 정보 없음
    
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
        applyGradient()
    }
    
    // MARK: - Methods
    private func setupLayout() {
        addSubviews([naviBarView, bookImageView/*, containerStackView*/])
        
        naviBarView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top)
            $0.horizontalEdges.equalToSuperview()
        }
        
        bookImageView.snp.makeConstraints {
            $0.top.equalTo(naviBarView.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(80)
            $0.height.equalTo(114)
        }
        
//        containerStackView.snp.makeConstraints {
//            $0.top.equalTo(bookImageView.snp.bottom).offset(24)
//            $0.horizontalEdges.equalToSuperview().inset(20)
//        }
    }
    
    private func attribute() {
        applyGradient()
    }
    
    private func bind() {
        
    }
    
    // MARK: - Data Binding
    @discardableResult
    func setupDI(selectedBook: Observable<AladinBook>) -> Self {
        selectedBook
            .withUnretained(self)
            .subscribe(onNext: { `self`, book in
                print("asdf > \(book)")
                self.bookImageView.loadImage(from: book.cover)
                self.titleInfoView.configure(title: "책 제목", content: book.title)
                
                self.authorInfoView.configure(title: "작가", content: book.author)
                
                self.publisherInfoView.configure(title: "출판사", content: book.publisher)
                
                let formattedPrice = NumberFormatter().then {
                    $0.numberStyle = .decimal
                }.string(from: NSNumber(value: book.priceStandard)) ?? "0"
                
                self.priceInfoView.configure(title: "가격", content: "\(formattedPrice)원")
            })
            .disposed(by: disposeBag)
        
        return self
    }
    
    /// 유저 액션
    @discardableResult
    func setupDI(action: PublishRelay<SearchDetailTriggerType>) -> Self {
        actionTriggers
            .bind(to: action)
            .disposed(by: disposeBag)
        
        return self
    }
}

fileprivate class BookInfoLabelView: UIView {
    // MARK: - Properties
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
        $0.textColor = .black
    }
    
    private let contentLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.textColor = .init(hex: "777777")
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    convenience init(title: String, content: String) {
        self.init(frame: .zero)
        configure(title: title, content: content)
    }
    
    // MARK: - Methods
    private func setupUI() {
        addSubviews([titleLabel, contentLabel])
        
        titleLabel.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
            $0.left.equalToSuperview()
        }
        
        contentLabel.snp.makeConstraints {
            $0.left.equalTo(titleLabel.snp.right).offset(30)
            $0.right.equalToSuperview()
            $0.centerY.equalTo(titleLabel)
        }
    }
    
    // MARK: - Public Methods
    func configure(title: String, content: String) {
        titleLabel.text = title
        contentLabel.text = content
    }
}
