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
        $0.font = .systemFont(ofSize: 18, weight: .medium)
        $0.textColor = .black
    }

    let toggleSwitch = UISwitch().then {
        $0.onTintColor = #colorLiteral(red: 0.2666666667, green: 0.2666666667, blue: 0.2666666667, alpha: 1)
    }

    private let timeTitleLabel = UILabel().then {
        $0.text = "시간"
        $0.font = .systemFont(ofSize: 18)
        $0.textColor = .black
    }

    var timePicker = UIDatePicker().then {
        $0.datePickerMode = .time
        $0.preferredDatePickerStyle = .compact
        $0.locale = Locale(identifier: "en_GB")
        $0.isUserInteractionEnabled = true

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
        contentView.backgroundColor = .white
        contentView.addSubview(titleLabel)
        contentView.addSubview(toggleSwitch)
        contentView.addSubview(timeTitleLabel)
        contentView.addSubview(timePicker)
    }

    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.height.equalTo(26)
        }

        toggleSwitch.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().inset(22)
        }

        timeTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview().inset(35)
        }

        timePicker.snp.makeConstraints {
            $0.top.equalTo(toggleSwitch.snp.bottom).offset(21)
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(30)
        }
    }
    
    private func bind() {
        let hour = UserDefaults.standard.integer(forKey: "alarmHour")
        let minute = UserDefaults.standard.integer(forKey: "alarmMinute")

        if hour != 0 || minute != 0 {
            let calendar = Calendar.current
            let date = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: Date())!
            timePicker.setDate(date, animated: false)
        }

        // 저장된 토글 상태 로드
        let isOn = UserDefaults.standard.bool(forKey: "alarmToggle")
        toggleSwitch.isOn = isOn
        
        toggleSwitch.rx.isOn
            .bind(to: toggleRelay)
            .disposed(by: disposeBag)

        timePicker.rx.date
            .skip(1)
            .subscribe(onNext: { [weak self] date in
                let calendar = Calendar.current
                let hour = calendar.component(.hour, from: date)
                let minute = calendar.component(.minute, from: date)

                UserDefaults.standard.set(hour, forKey: "alarmHour")
                UserDefaults.standard.set(minute, forKey: "alarmMinute")

                // 현재 ON 상태라면 바로 예약 갱신
                if self?.toggleSwitch.isOn == true {
                    UserNotificationService.shared.scheduleDailyNotification(hour: hour, minute: minute)
                }
            })
            .disposed(by: disposeBag)
    }

    func configureBindings() {
        bind()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        timePicker.setNeedsLayout()
        timePicker.layoutIfNeeded()
    }
}
