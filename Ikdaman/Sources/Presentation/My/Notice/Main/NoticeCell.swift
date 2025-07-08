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
            expandView.isHidden = !isExpanded
            if expandView.isHidden {
                expandView.snp.makeConstraints {
                    $0.height.equalTo(0)
                }
            } else {
                detailLabel.snp.makeConstraints {
                    $0.top.bottom.equalToSuperview().inset(15)
                    $0.leading.trailing.equalToSuperview().inset(25)
                }
                
                detailLabel.numberOfLines = 0
                detailLabel.font = .systemFont(ofSize: 14)
                detailLabel.textColor = .darkGray
            }
            arrowImageView.transform = isExpanded ? CGAffineTransform(rotationAngle: .pi) : .identity
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
        dateLabel.text = Date().toString()
        titleLabel.text = notice.title
        detailLabel.text = notice.content
        isExpanded = notice.isExpanded
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
