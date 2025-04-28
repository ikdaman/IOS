//
//  SwitchTableViewCell.swift
//  Ikdaman
//
//  Created by 이재혁 on 3/16/25.
//

import UIKit

class SwitchTableViewCell: UITableViewCell {
    static let identifier = "SwitchTableViewCell"
    
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 18, weight: .medium)
    }
    
    let toggleSwitch = UISwitch().then {
        $0.onTintColor = .systemGray
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
        contentView.addSubview(toggleSwitch)
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
        
        toggleSwitch.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
    }
    
    private func attribute() {
        selectionStyle = .none
    }
    
    func configure(with title: String, isOn: Bool = false) {
        titleLabel.text = title
        toggleSwitch.isOn = isOn
    }
}
