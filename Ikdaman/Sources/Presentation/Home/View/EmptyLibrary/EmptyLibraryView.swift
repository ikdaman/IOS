//
//  EmptyLibraryView.swift
//  Ikdaman
//
//  Created by 양원식 on 4/27/25.
//
import UIKit
import SnapKit
import Then
import RxSwift

final class EmptyLibraryView: UIView {
    
    // MARK: - UI
    private let containerView = UIView().then {
        $0.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
    }
    
    private let plusLabel = UILabel().then {
        $0.text = "+"
        $0.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        $0.textAlignment = .center
        $0.textColor = .black
    }
    
    private let messageLabel = UILabel().then {
        $0.text = "가지고 있는 책이 없어요.\n독서를 추가해보세요 🤓️"
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = .black
    }
    
    // MARK: - Property
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(plusLabel)
        containerView.addSubview(messageLabel)
        
        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.greaterThanOrEqualTo(150) // 적당한 높이 설정
        }
        
        plusLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.centerX.equalToSuperview()
        }
        
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(plusLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.lessThanOrEqualToSuperview().inset(24)
        }
    }
}
