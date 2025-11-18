//
//  SettingsTableViewCell.swift
//  Ikdaman
//
//  Created by 이재혁 on 3/16/25.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    static let identifier = "SettingsTableViewCell"
    
    private let titleLabel = UILabel().then {
        $0.textColor = .black
    }
    
    private let arrowImageView = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.right")
        $0.tintColor = .systemGray3
        $0.contentMode = .scaleAspectFit
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        attribute()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.backgroundColor = .white
        contentView.addSubview(titleLabel)
        contentView.addSubview(arrowImageView)
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
        
        arrowImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(21)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(12)
            $0.height.equalTo(18)
        }
    }
    
    private func attribute() {
        selectionStyle = .none
    }
    
    func configure(with title: String, showArrow: Bool = true) {
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: showArrow ? 18 : 16, weight: .medium)
        arrowImageView.isHidden = !showArrow
    }
}
