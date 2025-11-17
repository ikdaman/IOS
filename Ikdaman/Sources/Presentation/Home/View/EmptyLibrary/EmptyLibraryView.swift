//
//  EmptyLibraryView.swift
//  Ikdaman
//
//  Created by Soo on 7/7/25.
//

import UIKit
import SnapKit
import Then
import RxSwift

enum EmtpyType {
    case hasNoBooks
    case hasNoCompleteBooks
    
    var title: String {
        switch self {
        case .hasNoBooks:
            return "+\n가지고 있는 책이 없어요.\n독서를 추가해보세요 🤓️"
        case .hasNoCompleteBooks:
            return "+\n완독한 책이 없어요.\n 읽다만 책을 읽어볼까요?"
        }
    }
}

class EmptyLibraryView: UIView {
    
    // MARK: - UI
    private let containerView = UIView().then {
        $0.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
    }
    
    private let messageLabel = UILabel().then {
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.font = .systemFont(ofSize: 15, weight: .regular)
        $0.textColor = .black
    }
    
    // MARK: - Property
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    init(frame: CGRect = .zero, type: EmtpyType? = .hasNoBooks) {
        self.messageLabel.text = type?.title
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(messageLabel)
        
        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(175)
        }
        
        messageLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(56)
            $0.centerX.equalToSuperview()
        }
    }
}

class SearchEmptyLibraryView: UIView {
    
    // MARK: - UI
    var messageLabel = UILabel().then {
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.font = .systemFont(ofSize: 15, weight: .regular)
        $0.textColor = .black
    }
    
    
    // MARK: - Init
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        addSubview(messageLabel)
        
        messageLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(56)
            $0.centerX.equalToSuperview()
        }
    }
}
