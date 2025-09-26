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
    private let viewModel: BookDetailViewModel
    private let disposeBag = DisposeBag()
    
    private var currentBookInfo: MyBookInfo? // bookInfo 보관
    
    // MARK: - Initializer
    init(viewModel: BookDetailViewModel) {
        self.viewModel = viewModel
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
        let input = BookDetailViewModelInput(
            fetchBookInfo: Observable.just(()),
            fetchBookHistory: Observable.just(()),
            tapDeleteBook: bookDetailView.topBarView.customButton?.rx.tap.asObservable() ?? .empty()
        )

        let output = viewModel.transform(input: input)
        
        output.bookInfo
            .subscribe(onNext: { [weak self] myBookInfo in
                guard let myBookInfo else { return }
                self?.currentBookInfo = myBookInfo
                self?.bookDetailView.configure(myBookInfo: myBookInfo)
                self?.bookDetailView.bookInfoView.configure(myBookInfo: myBookInfo)
            }).disposed(by: disposeBag)

//        output.bookHistory
//            .compactMap { $0?.booklogs }
//            .bind(to: bookDetailView.bookRecordView.rx.items(
//                cellIdentifier: BookLogCell.identifier,
//                cellType: BookLogCell.self
//            )) { [weak self] index, log, cell in
//                cell.configure(with: log)
//                self?.bookDetailView.bookRecordView.reloadData()
//            }
//            .disposed(by: disposeBag)
        
//        output.bookHistory
//            .compactMap { $0?.booklogs }
//            .bind(to: bookDetailView.bookRecordView.rx.items(
//                cellIdentifier: BookLogCell.identifier,
//                cellType: BookLogCell.self
//            )) { index, log, cell in
//                cell.configure(with: log)
//            }
//            .disposed(by: disposeBag)
//
//        output.bookHistory
//            .compactMap { $0?.booklogs }
//            .subscribe(onNext: { [weak self] logs in
//                guard let self = self else { return }
//                print("logs: \(logs)")
//                DispatchQueue.main.async {
//                    self.bookDetailView.bookRecordView.snp.updateConstraints {
//                        $0.height.equalTo(self.bookDetailView.bookRecordView.contentSize.height)
//                    }
//                }
//            })
//            .disposed(by: disposeBag)
        
        output.bookHistory
            .compactMap { $0?.booklogs }
            .subscribe(onNext: { [weak self] logs in
                self?.bookDetailView.updateLogs(logs)
            })
            .disposed(by: disposeBag)

        
        output.completeDelete
            .subscribe(onNext: {
                self.navigationController?.popViewController(animated: true)
            }).disposed(by: disposeBag)

        bookDetailView.emptyImpressionView.rx.tap
            .subscribe(onNext: {
                print("tatatatat")
            }).disposed(by: disposeBag)
    }
    
    private func bindActions() {
        let recordRepository: RecordRepository = AddRecordRepositorylmpl() // 서버 호출 구현체
        let addRecordUseCase: AddRecordUseCase = DefaultAddRecordUseCase(recordRepository: recordRepository)
        
        bookDetailView.emptyImpressionView.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self,
                      let bookId = self.currentBookInfo?.mybookId,
                      let bookTitle = self.currentBookInfo?.bookInfo.title,
                      let bookAuthor = self.currentBookInfo?.bookInfo.author else { return }

                let vm = DefaultAddRecordViewModel(
                    addRecordUseCase: addRecordUseCase,
                    type: .firstImpression,
                    bookId: Int(bookId) ?? 0,
                    bookTitle: bookTitle,
                    bookAuthor: bookAuthor
                )

                let vc = AddRecordViewController(viewModel: vm)
                self.navigationController?.pushViewController(vc, animated: true)
            }).disposed(by: disposeBag)
        
        Observable.merge(bookDetailView.progressView.rx.tap.asObservable(),
                         bookDetailView.addBookButton.rx.tap.asObservable())
            .subscribe(onNext: { [weak self] _ in
                guard let self = self,
                      let bookId = self.currentBookInfo?.mybookId,
                      let bookTitle = self.currentBookInfo?.bookInfo.title,
                      let bookAuthor = self.currentBookInfo?.bookInfo.author,
                      let totalPage = self.currentBookInfo?.bookInfo.totalPage,
                      let nowPage = self.currentBookInfo?.nowPage else { return }

                let vm = DefaultAddRecordViewModel(
                    addRecordUseCase: addRecordUseCase,
                    type: .progress,
                    bookId: Int(bookId) ?? 0,
                    bookTitle: bookTitle,
                    bookAuthor: bookAuthor,
                    totalPage: totalPage,
                    nowPage: nowPage
                )

                let vc = AddRecordViewController(viewModel: vm)
                self.navigationController?.pushViewController(vc, animated: true)
            }).disposed(by: disposeBag)
        
        bookDetailView.readCompleteButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self,
                      let bookId = self.currentBookInfo?.mybookId else { return }

                let vm = DefaultAddRecordViewModel(
                    addRecordUseCase: addRecordUseCase,
                    type: .completion,
                    bookId: Int(bookId) ?? 0
                )

                let vc = AddRecordViewController(viewModel: vm)
                self.navigationController?.pushViewController(vc, animated: true)

            }).disposed(by: disposeBag)
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
        $0.font = .pretendard(.bold, size: 31)
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    let readCompleteButton = UIButton().then {
        $0.setTitle("✌다 읽었어요!", for: .normal)
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
    
    let impressionView = UIView().then {
        $0.backgroundColor = .white
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
    }
    
    let impressionLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 13, weight: .regular)
        $0.numberOfLines = 0
        $0.textColor = #colorLiteral(red: 0.3999999762, green: 0.3999999762, blue: 0.3999999762, alpha: 1)
    }
    
    let emptyImpressionView = UIView().then {
        $0.backgroundColor = .white
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
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
    
//    var bookRecordView = UITableView().then {
//        $0.register(BookLogCell.self, forCellReuseIdentifier: BookLogCell.identifier)
//        $0.separatorStyle = .none
//        $0.showsVerticalScrollIndicator = false
//        $0.isScrollEnabled = false
//        $0.estimatedRowHeight = 64
//    }
    
    let bookRecordStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
        $0.alignment = .fill
        $0.distribution = .equalSpacing
    }
    
    let disposeBag = DisposeBag()
    
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
        scrollView.addSubviews([bookInfoView, progressLabel, readCompleteButton, progressView, firstImpressionLabel, impressionView, emptyImpressionView, bookRecordLabel, addBookButton, bookRecordStackView])
        impressionView.addSubview(impressionLabel)
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
        
        impressionView.snp.makeConstraints {
            $0.top.equalTo(firstImpressionLabel.snp.bottom).offset(15)
            $0.width.equalToSuperview()
        }
        
        impressionLabel.snp.makeConstraints {
            $0.directionalHorizontalEdges.equalToSuperview().inset(20)
            $0.directionalVerticalEdges.equalToSuperview().inset(17)
        }
        
        emptyImpressionView.snp.makeConstraints {
            $0.top.equalTo(firstImpressionLabel.snp.bottom).offset(15)
            $0.width.equalToSuperview()
            $0.height.equalTo(109)
        }
        
        let emptyLabel = UILabel().then {
            $0.text = "처음 책을 보고 들었던 생각을 짧게 적어보세요.\n독서가 마음처럼 잘되지 않을 때, 나에게 힘을 줄 거에요!"
            $0.font = .systemFont(ofSize: 13, weight: .regular)
            $0.numberOfLines = 0
        }
        
        let writeImageView = UIImageView().then {
            $0.image = UIImage(named: "pencil")
        }
        
        emptyImpressionView.addSubviews([emptyLabel, writeImageView])
        
        emptyLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(17)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        writeImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(17)
            $0.size.equalTo(24)
        }
        
        bookRecordLabel.snp.makeConstraints {
            $0.top.equalTo(emptyImpressionView.snp.bottom).offset(35)
            $0.leading.equalToSuperview()
        }
        
        addBookButton.snp.makeConstraints {
            $0.top.equalTo(bookRecordLabel.snp.bottom).offset(20)
            $0.width.equalToSuperview()
            $0.height.equalTo(50)
        }
        
//        bookRecordView.snp.makeConstraints {
//            $0.top.equalTo(addBookButton.snp.bottom).offset(15)
//            $0.width.equalToSuperview()
////            $0.bottom.equalToSuperview().inset(58)
//            $0.height.equalTo(0)
//        }
        bookRecordStackView.snp.makeConstraints {
            $0.top.equalTo(addBookButton.snp.bottom).offset(15)
            $0.width.equalToSuperview()
            $0.bottom.equalToSuperview().inset(58)
        }
    }
    
    func setBackgroundColor() {
        if let rawValue = UserDefaults.standard.string(forKey: "backgroundColor"),
           let colorType = ColorType(rawValue: rawValue) {
            backgroundView.updateGradient(colors: colorType.gradientColors)
        }
    }
    
    func configure(myBookInfo: MyBookInfo) {
        let day = dayToString(startDate: myBookInfo.startDate)
        let text = "📖\n\(day)일째, \(myBookInfo.nowPage)p, \(myBookInfo.progress)%\n독서중인 책이에요."

        let attributedText = NSMutableAttributedString(string: text)

        // 앞부분 스타일 (굵고 크게)
        let boldRange = (text as NSString).range(of: "\(day)일째, \(myBookInfo.nowPage)p, \(myBookInfo.progress)%")
        attributedText.addAttribute(.font, value: UIFont.pretendard(.bold, size: 17), range: boldRange)

        // 뒷부분 스타일 (작고 얇게)
        let normalRange = (text as NSString).range(of: "독서중인 책이에요.")
        attributedText.addAttribute(.font, value: UIFont.pretendard(.regular, size: 17), range: normalRange)

        progressLabel.attributedText = attributedText
        progressView.progress = CGFloat(myBookInfo.progress)
        emptyImpressionView.isHidden = myBookInfo.impression != nil
        
        if myBookInfo.impression != nil {
            impressionLabel.text = myBookInfo.impression
            bookRecordLabel.snp.remakeConstraints {
                $0.top.equalTo(impressionView.snp.bottom).offset(35)
                $0.leading.equalToSuperview()
            }
        }
    }
    
    func updateLogs(_ logs: [BookLog]) {
        // 기존 뷰들 제거
        bookRecordStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        logs.forEach { log in
            let cell = BookLogView() // 기존 UITableViewCell 대신 그냥 UIView로 쓰기 가능
            cell.configure(with: log)
            bookRecordStackView.addArrangedSubview(cell)
        }
    }
    
    func dayToString(startDate: String) -> Int {
        var isoString = startDate
        // 소수점 이하 잘라내기 (초 단위까지만)
        if let dotRange = isoString.range(of: ".") {
            let secPart = isoString[..<dotRange.lowerBound]
            isoString = secPart + "Z"   // UTC 기준 (원하면 +09:00 붙여도 됨)
        }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        guard let start = formatter.date(from: isoString) else {
            fatalError("parse fail")
        }

        let now = Date()
        let days = now.timeIntervalSince(start) / (60 * 60 * 24)
        return Int(days)
    }
}

class BookLogView: UIView {
    private let timeLabel = UILabel().then {
        $0.font = .pretendard(.regular, size: 12)
        $0.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .pretendard(.medium, size: 14)
        $0.textColor = .black
    }
    
    private let expandButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        $0.setImage(UIImage(systemName: "chevron.up"), for: .selected)
        $0.tintColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
    }
    
    private let contentLabel = UILabel().then {
        $0.font = .pretendard(.regular, size: 13)
        $0.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1)
        $0.numberOfLines = 0
    }
    
    private let contentView = UIView()
    
    private let pageLabel = UILabel().then {
        $0.font = .pretendard(.bold, size: 14)
    }
    
    private let likeButton = UIButton().then {
        $0.setTitle("수정", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .pretendard(.medium, size: 12)
        $0.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        $0.layer.cornerRadius = 12
    }
    
    private let deleteButton = UIButton().then {
        $0.setTitle("삭제", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .pretendard(.medium, size: 12)
        $0.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        $0.layer.cornerRadius = 12
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1)
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
    }
    
    private var isExpanded = false
    private var contentHeightConstraint: Constraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupLayout()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(containerView)
        containerView.addSubviews([timeLabel, titleLabel, expandButton])
        contentView.addSubviews([pageLabel, contentLabel, likeButton, deleteButton])
        containerView.addSubview(contentView)
    }
    
    private func setupLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        timeLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalTo(timeLabel.snp.trailing).offset(6)
        }
        
        expandButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().inset(20)
            $0.size.equalTo(24)
        }
        
        contentView.snp.makeConstraints {
            $0.top.equalTo(timeLabel.snp.bottom).offset(15)
            $0.leading.trailing.bottom.equalToSuperview().inset(20)
        }
        
        
    }
    
    private func setupActions() {
        expandButton.addTarget(self, action: #selector(toggleExpand), for: .touchUpInside)
    }
    
    @objc private func toggleExpand() {
        isExpanded.toggle()
        expandButton.isSelected = isExpanded
        
        UIView.animate(withDuration: 0.3, animations: {
            self.layoutIfNeeded()
        })
    }
    
    func configure(with log: BookLog) {
        // 시간 포맷팅 (예: "24/12/12 17:00")
        timeLabel.text = formatISODate(log.loggedDate)
        
        // 로그 타입에 따른 이모지와 타이틀 설정
        switch log.type {
        case "IMPRESSION":
            titleLabel.text = "💕첫인상을 추가했어요."
        case "THINK":
            titleLabel.text = "✏️생각을 추가했어요."
        case "REVIEW":
            titleLabel.text = "🎵책을 덮었어요."
        default:
            titleLabel.text = "📖책을 펼쳤어요."
        }
        
        // 내용 설정
        if let content = log.content, !content.isEmpty {
            contentLabel.text = content
        } else {
            contentLabel.text = "해당에서 찾을 전체에서 책자뎌 위해 된다. 지금은 다음은 이야기뎌 를 알았는데, 탐을 값속을 인물뎌 와 지금 탐자 이야기뎌 나가지 위한 학음을 이야기다."
        }
        
        // 페이지 정보가 있다면 추가 표시
//        if let pages = log.pages, pages > 0 {
//            contentLabel.text = "\(pages)p\n\(contentLabel.text ?? "")"
//        }
    }
    
    // ISO8601 문자열 → Date → 원하는 형식 문자열
    func formatISODate(_ isoString: String, format: String = "yy/MM/dd HH:mm") -> String {
        var iso = isoString
        
        // Z 붙이기 (UTC 기준)
        if !iso.hasSuffix("Z") {
            iso += "Z"
        }
        
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = isoFormatter.date(from: iso) else {
            return isoString // 변환 실패 시 원본 반환
        }
        
        return date.toString(format: format)
    }
}

extension Date {
    func toString(format: String = "yy/MM/dd HH:mm") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "ko_KR") // 한국 시간
        formatter.timeZone = TimeZone.current
        return formatter.string(from: self)
    }
}


