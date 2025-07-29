//
//  BookDetailViewController.swift
//  Ikdaman
//
//  Created by Soo on 7/10/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class BookDetailViewController: BaseViewController {
    
    // MARK: - Properties
    private let bookDetailView = BookDetailView()
//    private let viewModel: BookCaseViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializer
//    init(viewModel: BookCaseViewModel) {
//        self.viewModel = viewModel
//        super.init()
//    }
    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func loadView() {
        self.view = bookDetailView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomBackButton()
        bindViewModel()
        bindActions()
    }
    
    // MARK: - Binding
    private func bindViewModel() {
//        let input = BookCaseViewModelInput(fetchBooks: Observable.just(()),
//                                           filterTapped: bookCaseView.filterView.filterTapped.asObservable())
//        
//        let output = viewModel.transform(input: input)
//        
//        output.books
//            .bind(to: bookCaseView.bookListView.rx.items(
//                cellIdentifier: BookCaseCell.identifier,
//                cellType: BookCaseCell.self
//            )) { row, book, cell in
//                cell.configure(book: book)
//            }
//            .disposed(by: disposeBag)
        
    }
    
    private func bindActions() {
        
    }
    
}

class BookDetailView: UIView {
    let backgroundView = GradientBackgroundView()
    
    let topBarView = CustomTopBarView(
        centerTitle: "상세 정보",
        customButton: UIButton().then {
            $0.setImage(UIImage(named: "bin"), for: .normal)
        }
    )
    
    let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.bouncesZoom = true
        $0.bounces = true
        $0.isScrollEnabled = true
        $0.alwaysBounceVertical = true
        $0.backgroundColor = .clear
    }
    
    let bookInfoView = MyBookInfoView()
    
    let progressLabel = UILabel().then {
        $0.text = "📖\n7일째, 155p, 42%\n독서중인 책이에요."
        $0.font = .systemFont(ofSize: 31, weight: .bold)
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    let readCompleteButton = UIButton().then {
        $0.setTitle("다 읽었어요!", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        $0.backgroundColor = .white
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 14
    }
    
    let progressView = ProgressIndicatorView().then {
        $0.backgroundColor = .clear
    }
    
    let firstImpressionLabel = UILabel().then {
        $0.text = "책의 첫인상"
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
    }
    
    let firstImpressionView = UIView().then {
        $0.backgroundColor = .white
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
    }
    
    var firstImpressionText = UILabel().then {
        $0.text = "처음 책을 보고 들었던 생각을 짧게 적어보세요.\n독서가 마음처럼 잘되지 않을 때, 나에게 힘을 줄 거에요!"
        $0.font = .systemFont(ofSize: 13, weight: .regular)
        $0.numberOfLines = 0
    }
    
    let writeButton = UIButton().then {
        $0.setImage(UIImage(named: "pencil"), for: .normal)
    }
    
    let bookRecordLabel = UILabel().then {
        $0.text = "이 책의 기록"
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
    }
    
    let addBookButton = UIButton().then {
        $0.setTitle("책 기록 추가하기", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .black
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
    }
    
    let bookRecordView = UIView().then {
        $0.backgroundColor = .blue
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupLayout()
        setBackgroundColor()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubviews([backgroundView, topBarView, scrollView])
        scrollView.addSubviews([bookInfoView, progressLabel, readCompleteButton, progressView, firstImpressionLabel, firstImpressionView, bookRecordLabel, addBookButton, bookRecordView])
        firstImpressionView.addSubviews([firstImpressionText, writeButton])
    }
    
    private func setupLayout() {
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        topBarView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(10)
            $0.leading.trailing.equalToSuperview()
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(topBarView.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
        }
        
        bookInfoView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.width.equalToSuperview()
        }
        
        progressLabel.snp.makeConstraints {
            $0.top.equalTo(bookInfoView.snp.bottom).offset(35)
            $0.centerX.equalToSuperview()
        }
        
        readCompleteButton.snp.makeConstraints {
            $0.top.equalTo(progressLabel.snp.bottom).offset(15)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(87)
            $0.height.equalTo(28)
        }
        
        progressView.snp.makeConstraints {
            $0.top.equalTo(readCompleteButton.snp.bottom).offset(52)
            $0.width.equalToSuperview()
        }
        
        firstImpressionLabel.snp.makeConstraints {
            $0.top.equalTo(progressView.snp.bottom).offset(42)
            $0.leading.equalToSuperview()
        }
        
        firstImpressionView.snp.makeConstraints {
            $0.top.equalTo(firstImpressionLabel.snp.bottom).offset(15)
            $0.width.equalToSuperview()
        }
        
        firstImpressionText.snp.makeConstraints {
            $0.top.equalToSuperview().offset(17)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        writeButton.snp.makeConstraints {
            $0.top.equalTo(firstImpressionText.snp.bottom).offset(15)
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(17)
            $0.size.equalTo(24)
        }
        
        bookRecordLabel.snp.makeConstraints {
            $0.top.equalTo(firstImpressionView.snp.bottom).offset(35)
            $0.leading.equalToSuperview()
        }
        
        addBookButton.snp.makeConstraints {
            $0.top.equalTo(bookRecordLabel.snp.bottom).offset(20)
            $0.width.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        bookRecordView.snp.makeConstraints {
            $0.top.equalTo(addBookButton.snp.bottom).offset(15)
            $0.width.equalToSuperview()
            $0.bottom.equalToSuperview().offset(58)
            $0.height.equalTo(300)
        }
    }
    
    func setBackgroundColor() {
        if let rawValue = UserDefaults.standard.string(forKey: "backgroundColor"),
           let colorType = ColorType(rawValue: rawValue) {
            backgroundView.updateGradient(colors: colorType.gradientColors)
        }
    }
}

class CustomTopBarView: UIView {
    let backButton = UIButton().then {
        $0.setImage(UIImage(named: "backButton"), for: .normal)
    }
    var centerTitle: String? = nil
    var customButton: UIButton? = nil
    
    init(centerTitle: String? = nil, customButton: UIButton? = nil) {
        self.centerTitle = centerTitle
        self.customButton = customButton
        super.init(frame: .zero)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupLayout() {
        self.backgroundColor = .clear
        self.snp.makeConstraints {
            $0.height.equalTo(50)
        }
        addSubview(backButton)
        
        backButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(13)
            $0.size.equalTo(26)
        }
        
        if let centerTitle = centerTitle {
            let centerTitleLabel = UILabel().then {
                $0.text = centerTitle
                $0.font = .systemFont(ofSize: 18, weight: .bold)
                $0.textColor = .black
            }
            addSubview(centerTitleLabel)
            centerTitleLabel.snp.makeConstraints {
                $0.center.equalToSuperview()
            }
        }
        
        if let customButton = customButton {
            addSubview(customButton)
            customButton.snp.makeConstraints {
                $0.trailing.equalToSuperview().inset(14)
                $0.centerY.equalToSuperview()
            }
        }
    }
}

class MyBookInfoView: UIView {
    var myBookInfo: MyBookInfo?
    
    let containerView = UIView().then {
        $0.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.7)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
    }
    
    let bookImage = UIImageView()
    
    let bookTitle = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .bold)
        $0.textAlignment = .left
        $0.numberOfLines = 0
        $0.text = "테스트"
    }
    
    let bookAuthor = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.textAlignment = .left
    }
    
    let bookPulbisher = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.textAlignment = .left
    }
    
    let bookTotalPage = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.textAlignment = .left
    }
    
    let showAladinButton = UIButton().then {
        let title = "알라딘에서 보기"
        let attributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .font: UIFont.systemFont(ofSize: 12, weight: .bold)
        ]
        let attributedTitle = NSAttributedString(string: title, attributes: attributes)
        $0.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupLayout() {
        addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }
        
        let authorLabel = UILabel().then {
            $0.text = "작가"
            $0.font = .systemFont(ofSize: 14, weight: .bold)
            $0.textAlignment = .left
        }
        
        let publisherLabel = UILabel().then {
            $0.text = "출판사"
            $0.font = .systemFont(ofSize: 14, weight: .bold)
            $0.textAlignment = .left
        }
        
        let totalPageLabel = UILabel().then {
            $0.text = "총 페이지"
            $0.font = .systemFont(ofSize: 14, weight: .bold)
            $0.textAlignment = .left
        }
        
        let aladinInfoLabel = UILabel().then {
            $0.text = "도서정보 알라딘 제공"
            $0.font = .systemFont(ofSize: 12, weight: .regular)
            $0.textAlignment = .left
        }
        
        containerView.addSubviews([bookImage, bookTitle, authorLabel, bookAuthor, publisherLabel, bookPulbisher,
                                   totalPageLabel, bookTotalPage, aladinInfoLabel, showAladinButton])
        
        bookImage.snp.makeConstraints {
            $0.top.equalToSuperview().offset(17)
            $0.leading.equalToSuperview().offset(17)
            $0.width.equalTo(91)
            $0.height.equalTo(130)
        }
        
        bookTitle.snp.makeConstraints {
            $0.top.equalToSuperview().offset(17)
            $0.leading.equalTo(bookImage.snp.trailing).offset(15)
            $0.trailing.equalToSuperview().inset(17)
        }
        
        authorLabel.snp.makeConstraints {
            $0.top.equalTo(bookTitle.snp.bottom).offset(22)
            $0.leading.equalTo(bookTitle.snp.leading)
            $0.width.equalTo(50)
        }
        
        bookAuthor.snp.makeConstraints {
            $0.top.equalTo(bookTitle.snp.bottom).offset(22)
            $0.leading.equalTo(authorLabel.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().inset(17)
        }
        
        publisherLabel.snp.makeConstraints {
            $0.top.equalTo(authorLabel.snp.bottom).offset(22)
            $0.leading.equalTo(bookTitle.snp.leading)
            $0.width.equalTo(50)
        }
        
        bookPulbisher.snp.makeConstraints {
            $0.top.equalTo(authorLabel.snp.bottom).offset(22)
            $0.leading.equalTo(publisherLabel.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().inset(17)
        }
        
        totalPageLabel.snp.makeConstraints {
            $0.top.equalTo(publisherLabel.snp.bottom).offset(22)
            $0.leading.equalTo(bookTitle.snp.leading)
            $0.width.equalTo(50)
        }
        
        bookTotalPage.snp.makeConstraints {
            $0.top.equalTo(publisherLabel.snp.bottom).offset(22)
            $0.leading.equalTo(totalPageLabel.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().inset(17)
        }
        
        aladinInfoLabel.snp.makeConstraints {
            $0.top.equalTo(totalPageLabel.snp.bottom).offset(18)
            $0.leading.equalTo(bookTitle.snp.leading)
            $0.bottom.equalToSuperview().inset(20)
        }
        
        showAladinButton.snp.makeConstraints {
            $0.centerY.equalTo(aladinInfoLabel)
            $0.leading.equalTo(aladinInfoLabel.snp.trailing).offset(9)
        }
    }
}

class ProgressIndicatorView: UIView {

    private let trackView = UIView()
    private let fillView = UIView()
    private let centerLabelContainer = UIView()
    private let iconImageView = UIImageView()
    private let percentageLabel = UILabel()

    var progress: CGFloat = 0.42 {
        didSet {
            updateProgress()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        layoutViews()
        updateProgress()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        trackView.backgroundColor = UIColor.purple.withAlphaComponent(0.3)
        trackView.layer.cornerRadius = 2
        addSubview(trackView)

        fillView.backgroundColor = .black
        fillView.layer.cornerRadius = 2
        addSubview(fillView)

        centerLabelContainer.backgroundColor = .black
        centerLabelContainer.layer.cornerRadius = 14
        centerLabelContainer.clipsToBounds = true
        addSubview(centerLabelContainer)

        iconImageView.image = UIImage(systemName: "book.fill")
        iconImageView.tintColor = .white
        centerLabelContainer.addSubview(iconImageView)

        percentageLabel.textColor = .white
        percentageLabel.font = .boldSystemFont(ofSize: 14)
        centerLabelContainer.addSubview(percentageLabel)
    }

    private func layoutViews() {
        trackView.snp.makeConstraints {
            $0.height.equalTo(3)
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }

        fillView.snp.makeConstraints {
            $0.left.top.bottom.equalTo(trackView)
            $0.width.equalTo(0) // Will update
        }

        centerLabelContainer.snp.makeConstraints {
            $0.centerY.equalTo(trackView)
            $0.centerX.equalTo(fillView.snp.right)
            $0.height.equalTo(28)
        }

        iconImageView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(8)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(16)
        }

        percentageLabel.snp.makeConstraints {
            $0.left.equalTo(iconImageView.snp.right).offset(4)
            $0.right.equalToSuperview().inset(8)
            $0.centerY.equalToSuperview()
        }
    }

    private func updateProgress() {
        percentageLabel.text = "\(Int(progress * 100))%"

        let totalWidth = self.bounds.width
        let fillWidth = totalWidth * progress

        fillView.snp.updateConstraints {
            $0.width.equalTo(fillWidth)
        }

        layoutIfNeeded()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateProgress()
    }
}

struct MyBookInfo: Codable {
    let bookInfo: [BookInfo]
    let mybookId: Int
    let startDate: String
    let nowPage: Int
    let progress: Int
    let impression: String?
}

struct BookInfo: Codable {
    let title: String
    let author: String
    let coverImage: String
    let publisher: String
    let totalPage: Int
    let category: String
}
