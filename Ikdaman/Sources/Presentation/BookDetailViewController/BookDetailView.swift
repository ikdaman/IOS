//
//  BookDetailView.swift
//  Ikdaman
//
//  Created by Soo on 11/18/25.
//

import UIKit
import RxSwift
import RxCocoa

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
    
    func updateLogs(_ logs: [BookLog],
                    modifyLogSubject: PublishSubject<(String, Int)>,
                    deleteLogSubject: PublishSubject<Int>) {

        bookRecordStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        logs.forEach { log in
            let cell = BookLogView()
            cell.configure(with: log)
            bookRecordStackView.addArrangedSubview(cell)

            // Cell의 tap 이벤트를 바로 외부 Subject에 연결
            cell.tapModify
                .bind(to: modifyLogSubject)
                .disposed(by: disposeBag)

            cell.tapDelete
                .bind(to: deleteLogSubject)
                .disposed(by: disposeBag)
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
