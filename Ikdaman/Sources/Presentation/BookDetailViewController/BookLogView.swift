//
//  BookLogView.swift
//  Ikdaman
//
//  Created by Soo on 11/18/25.
//

import UIKit
import RxSwift
import SnapKit

class BookLogView: UIView, UITextViewDelegate {
    private let timeLabel = UILabel().then {
        $0.font = .pretendard(.regular, size: 12)
        $0.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .pretendard(.medium, size: 14)
        $0.textColor = .black
    }
    
    private let expandButton = UIButton().then {
        $0.setImage(UIImage(named: "arrowDown"), for: .normal)
        $0.setImage(UIImage(named: "arrowUp"), for: .selected)
    }
    
    private let contentLabel = UITextView().then {
        $0.font = .pretendard(.regular, size: 13)
        $0.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1)
        $0.isScrollEnabled = false
        $0.backgroundColor = .clear
        $0.isHidden = true
    }
    
    private let contentView = UIView()
    
    private let pageLabel = UILabel().then {
        $0.font = .pretendard(.bold, size: 14)
    }
    
    private let modifyButton = UIButton().then {
        $0.setTitle("수정", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .pretendard(.medium, size: 12)
        $0.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        $0.layer.cornerRadius = 5
        $0.isHidden = true
    }
    
    private let deleteButton = UIButton().then {
        $0.setTitle("삭제", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .pretendard(.medium, size: 12)
        $0.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        $0.layer.cornerRadius = 5
        $0.isHidden = true
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1)
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
    }
    
    private var isExpanded = false
    private var contentHeightConstraint: Constraint?
    
    var logId: Int = 0
    let tapModify = PublishSubject<(String, Int)>()
    let tapDelete = PublishSubject<Int>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupLayout()
        setupActions()
        contentLabel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(containerView)
        containerView.addSubviews([timeLabel, titleLabel, expandButton])
        contentView.addSubviews([pageLabel, contentLabel, modifyButton, deleteButton])
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
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().inset(20)
            $0.size.equalTo(24)
        }
        
        contentView.snp.makeConstraints {
            $0.top.equalTo(timeLabel.snp.bottom).offset(15)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(5)
            $0.height.equalTo(0)
        }
        
        pageLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
        }
        
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(pageLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(46)
        }
        
        deleteButton.snp.makeConstraints {
            $0.trailing.bottom.equalToSuperview()
            $0.width.equalTo(41)
            $0.height.equalTo(26)
        }
        
        modifyButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(47)
            $0.bottom.equalToSuperview()
            $0.width.equalTo(41)
            $0.height.equalTo(26)
        }
    }
    
    private func setupActions() {
        expandButton.addTarget(self, action: #selector(toggleExpand), for: .touchUpInside)
        modifyButton.addTarget(self, action: #selector(toggleModify), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(toggleDelete), for: .touchUpInside)
    }
    
    @objc private func toggleExpand() {
        isExpanded.toggle()
        expandButton.isSelected = isExpanded
        deleteButton.isHidden = !isExpanded
        modifyButton.isHidden = !isExpanded
        contentLabel.isHidden = !isExpanded
        
        if isExpanded {
            contentView.snp.remakeConstraints {
                $0.top.equalTo(timeLabel.snp.bottom).offset(15)
                $0.leading.trailing.bottom.equalToSuperview().inset(20)
            }
        } else {
            contentView.snp.remakeConstraints {
                $0.top.equalTo(timeLabel.snp.bottom).offset(15)
                $0.leading.trailing.equalToSuperview().inset(20)
                $0.bottom.equalToSuperview().inset(5)
                $0.height.equalTo(0)
            }
        }
        
        self.layoutIfNeeded()
    }
    
    @objc private func toggleModify() {
        tapModify.onNext((contentLabel.text ?? "", logId))
        self.layoutIfNeeded()
    }
    
    @objc private func toggleDelete() {
        tapDelete.onNext(logId)
        self.layoutIfNeeded()
    }
    
    func configure(with log: BookLog) {
        // 시간 포맷팅 (예: "24/12/12 17:00")
        timeLabel.text = formatISODate(log.loggedDate)
        self.logId = log.booklogId
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
        }
        
        // 페이지 정보가 있다면 추가 표시
        if let pages = log.page, pages > 0 {
            pageLabel.text = "\(pages)p"
        }
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
    
    @objc private func didTapContentLabel() {
        isExpanded = true
        expandButton.isSelected = true
        deleteButton.isHidden = false
        modifyButton.isHidden = false
        contentLabel.isHidden = false

        contentView.snp.remakeConstraints {
            $0.top.equalTo(timeLabel.snp.bottom).offset(15)
            $0.leading.trailing.bottom.equalToSuperview().inset(20)
        }

        contentLabel.becomeFirstResponder()
        UIView.animate(withDuration: 0.25) {
            self.layoutIfNeeded()
        }
    }
    
    // UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        NotificationCenter.default.post(name: .bookLogTextViewDidBeginEditing, object: self)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        NotificationCenter.default.post(name: .bookLogTextViewDidEndEditing, object: self)
    }
}
