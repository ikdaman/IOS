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
        $0.font = .systemFont(ofSize: 20, weight: .regular)
    }
    
    private let arrowImageView = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.right")
        $0.tintColor = .systemGray3
        $0.contentMode = .scaleAspectFit
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
        contentView.addSubview(arrowImageView)
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(34)
            $0.centerY.equalToSuperview()
        }
        
        arrowImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-36)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(12)
            $0.height.equalTo(18)
        }
    }
    
    func configure(with title: String, showArrow: Bool = true) {
        titleLabel.text = title
        arrowImageView.isHidden = !showArrow
    }
}
