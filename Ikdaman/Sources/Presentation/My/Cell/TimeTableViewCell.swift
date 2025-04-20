//
//  TimeTableViewCell.swift
//  Ikdaman
//
//  Created by 이재혁 on 3/16/25.
//

import UIKit

class TimeTableViewCell: UITableViewCell {
    static let identifier = "TimeTableViewCell"
    
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 20, weight: .regular)
    }
    
    private let timeLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 20, weight: .regular)
        $0.textColor = .black
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(timeLabel)
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
        
        timeLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
    }
    
    private func attribute() {
        selectionStyle = .none
    }
    
    func configure(with title: String, time: String) {
        titleLabel.text = title
        timeLabel.text = time
    }
}
