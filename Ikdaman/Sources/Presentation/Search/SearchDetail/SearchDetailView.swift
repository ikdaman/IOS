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
    
    /// 도서정보 알라딘 제공 컨테이너
    private lazy var aladinBookInfoContainerView = UIView().then {
        $0.addSubviews([bookInfoAladinLabel, moveToAladinBtn])
        
        bookInfoAladinLabel.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.centerY.equalTo(moveToAladinBtn)
        }
        
        moveToAladinBtn.snp.makeConstraints {
            $0.verticalEdges.right.equalToSuperview()
            $0.left.equalTo(bookInfoAladinLabel.snp.right).offset(9)
            $0.height.equalTo(20)
        }
    }
    private let bookInfoAladinLabel = UILabel().then {
        $0.text = "도서정보 알라딘 제공"
        $0.textColor = .black
        $0.font = .systemFont(ofSize: 12, weight: .regular)
    }
    
    private let moveToAladinBtn = UIButton().then {
        let title = "알라딘에서 보기"
        let attributedTitle = NSAttributedString(
            string: title,
            attributes: [
                .foregroundColor: UIColor.black,
                .font: UIFont.systemFont(ofSize: 12, weight: .bold),
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
        )
        $0.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    /// 책의 첫인상 컨테이너
    private lazy var firstImpressionContainerView = UIView().then {
        $0.addSubviews([impressionLabel, textView])
        
        impressionLabel.snp.makeConstraints {
            $0.top.left.equalToSuperview()
        }
        
        textView.snp.makeConstraints {
            $0.top.equalTo(impressionLabel.snp.bottom).offset(10)
            $0.horizontalEdges.bottom.equalToSuperview()
            $0.height.equalTo(105)
        }
    }
    
    private let impressionLabel = UILabel().then {
        $0.text = "책의 첫인상"
        $0.textColor = .black
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
    }
    
    private let textView = PlaceholderTextView().then {
        $0.placeholder = "처음 책을 보고 들었던 생각을 짧게 적어보세요.\n독서가 마음처럼 잘되지 않을 때, 나에게 힘을 줄 거예요!"
        $0.placeholderFont = .systemFont(ofSize: 13, weight: .regular)
        $0.placeholderColor = .init(hex: "#626262")
        $0.backgroundColor = .white
        $0.font = .systemFont(ofSize: 13, weight: .regular)
        $0.textColor = .black
        $0.layer.cornerRadius = 10
    }
    
    private let addBookBtn = UIButton().then {
        $0.backgroundColor = .black
        $0.setTitle("이 책 추가하기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        $0.layer.cornerRadius = 10
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
        applyGradient()
    }
    
    // MARK: - Methods
    private func setupLayout() {
        addSubviews([naviBarView, bookImageView, containerStackView, aladinBookInfoContainerView, firstImpressionContainerView, addBookBtn])
        
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
        
        containerStackView.snp.makeConstraints {
            $0.top.equalTo(bookImageView.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        aladinBookInfoContainerView.snp.makeConstraints {
            $0.top.equalTo(containerStackView.snp.bottom).offset(30)
            $0.left.equalToSuperview().inset(20)
        }
        
        firstImpressionContainerView.snp.makeConstraints {
            $0.top.equalTo(aladinBookInfoContainerView.snp.bottom).offset(30)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        addBookBtn.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(78)
            $0.height.equalTo(50)
        }
    }
    
    private func attribute() {
        applyGradient()
    }
    
    private func bind() {
        backBtn.rx.tap
            .map { .backBtnTapped }
            .bind(to: actionTriggers)
            .disposed(by: disposeBag)
        
        self.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                self.endEditing(true)
            })
            .disposed(by: disposeBag)
        
        textView.rx.text
            .orEmpty
            .map { .impressionText($0) }
            .bind(to: actionTriggers)
            .disposed(by: disposeBag)
        
        addBookBtn.rx.tap
            .map { .addBookBtnTapped }
            .bind(to: actionTriggers)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Data Binding
    @discardableResult
    func setupDI(book: Observable<AladinBook>) -> Self {
        book
            .withUnretained(self)
            .subscribe(onNext: { `self`, book in
                self.bookImageView.loadImage(from: book.cover)
                self.titleInfoView.configure(title: "책 제목", content: book.title)
                self.authorInfoView.configure(title: "작가", content: book.author)
                self.publisherInfoView.configure(title: "출판사", content: book.publisher)
                self.priceInfoView.configure(title: "총 페이지", content: "\(book.subInfo?.itemPage ?? 0)")
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
        $0.font = .pretendard(.semiBold, size: 14)
        $0.textColor = .black
    }
    
    private let contentLabel = UILabel().then {
        $0.font = .pretendard(.regular, size: 14)
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
            $0.width.equalTo(60)
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
