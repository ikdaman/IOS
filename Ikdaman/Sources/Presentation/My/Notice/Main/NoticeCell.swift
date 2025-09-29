//
//  NoticeCell.swift
//  Ikdaman
//
//  Created by Soo on 6/9/25.
//

import UIKit
import SnapKit

class NoticeCell: UITableViewCell {
    static let id = "NoticeCell"
    
    private let dateLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12, weight: .regular)
    }
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 15, weight: .regular)
    }
    private let arrowImageView = UIImageView(image: UIImage(systemName: "chevron.down")).then {
        $0.tintColor = .black
    }
    private let expandView = UIView().then {
        $0.backgroundColor = #colorLiteral(red: 0.9725490212, green: 0.9725490212, blue: 0.9725490212, alpha: 1)
    }
    private let detailLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 13, weight: .regular)
    }
    
    var isExpanded: Bool = false {
        didSet {
            exandView(isExpanded: isExpanded)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupUI()
    }
    
    private func setupUI() {
        [dateLabel, titleLabel, arrowImageView, expandView].forEach {
            contentView.addSubview($0)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.leading.equalToSuperview().offset(25)
        }
        
        arrowImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(25)
            $0.top.equalToSuperview().offset(21.5)
            $0.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(5)
            $0.leading.equalTo(dateLabel)
            $0.trailing.equalTo(arrowImageView.snp.leading).offset(-8)
        }
        
        expandView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(15)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        expandView.addSubview(detailLabel)
    }

    func configure(with notice: Notice) {
        dateLabel.text = notice.uploadedAt.toYYYYMMDD()
        titleLabel.text = notice.title
        isExpanded = notice.isExpanded ?? false
    }
    
    func exandView(isExpanded: Bool) {
        expandView.isHidden = !isExpanded
        arrowImageView.transform = isExpanded ? CGAffineTransform(rotationAngle: .pi) : .identity
        
        expandView.subviews.forEach { $0.removeFromSuperview() }
        
        if isExpanded {
            expandView.addSubview(detailLabel)
            detailLabel.numberOfLines = 0
            detailLabel.font = .systemFont(ofSize: 14)
            detailLabel.textColor = .darkGray
            
            detailLabel.snp.remakeConstraints {
                $0.edges.equalToSuperview().inset(15)
            }

            expandView.snp.remakeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom).offset(15)
                $0.leading.trailing.bottom.equalToSuperview()
            }
        } else {
            expandView.snp.remakeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom).offset(15)
                $0.leading.trailing.bottom.equalToSuperview()
                $0.height.equalTo(0)
            }
        }
    }
    
    func setDetailLabel(detail: String) {
        self.detailLabel.text = detail
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}

extension String {
    /// ISO 8601 문자열을 "yyyy-MM-dd" 형식으로 변환
    func toYYYYMMDD() -> String? {
        // 가능한 입력 포맷 배열 (마이크로초 유무, 초 유무 등)
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS", // 마이크로초 포함
            "yyyy-MM-dd'T'HH:mm:ss.SSS",    // 밀리초 포함
            "yyyy-MM-dd'T'HH:mm:ss",        // 초까지
            "yyyy-MM-dd"                     // 날짜만
        ]
        
        let inputFormatter = DateFormatter()
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        var date: Date? = nil
        for format in formats {
            inputFormatter.dateFormat = format
            if let d = inputFormatter.date(from: self) {
                date = d
                break
            }
        }
        
        guard let validDate = date else { return nil }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy-MM-dd"
        outputFormatter.locale = Locale(identifier: "ko_KR")
        
        return outputFormatter.string(from: validDate)
    }
}
