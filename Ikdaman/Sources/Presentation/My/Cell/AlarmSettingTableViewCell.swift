//
//  AlarmSettingTableViewCell.swift
//  Ikdaman
//
//  Created by Soo on 6/16/25.
//

import UIKit
import RxSwift
import RxCocoa

class AlarmSettingTableViewCell: UITableViewCell {
    static let identifier = "AlarmSettingTableViewCell"
    
    let toggleRelay = PublishRelay<Bool>()
    let timeTapRelay = PublishRelay<Void>()
    let disposeBag = DisposeBag()
    
    private let titleLabel = UILabel().then {
        $0.text = "푸시 메시지 설정"
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.textColor = .black
    }

    let toggleSwitch = UISwitch().then {
        $0.onTintColor = .systemBlue
    }

    private let timeTitleLabel = UILabel().then {
        $0.text = "시간"
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .lightGray
    }

    let timeButton = UIButton(type: .system).then {
        $0.setTitle("21:00", for: .normal)
        $0.setTitleColor(.darkGray, for: .normal)
        $0.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        $0.titleLabel?.font = .systemFont(ofSize: 14)
        $0.layer.cornerRadius = 8
        $0.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
    }

    // MARK: - Initializer

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
        selectionStyle = .none
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(toggleSwitch)
        contentView.addSubview(timeTitleLabel)
        contentView.addSubview(timeButton)
    }

    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(16)
        }

        toggleSwitch.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().inset(16)
        }

        timeTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().inset(20)
        }

        timeButton.snp.makeConstraints {
            $0.centerY.equalTo(timeTitleLabel)
            $0.leading.equalTo(timeTitleLabel.snp.trailing).offset(12)
            $0.width.equalTo(80)
            $0.height.equalTo(36)
        }
    }
    
    private func bind() {
        toggleSwitch.rx.isOn
            .bind(to: toggleRelay)
            .disposed(by: disposeBag)

        timeButton.rx.tap
            .bind(to: timeTapRelay)
            .disposed(by: disposeBag)
    }

    func configureBindings() {
        bind()
    }
}
