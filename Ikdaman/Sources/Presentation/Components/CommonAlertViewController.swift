//
//  CommonAlertViewController.swift
//  Ikdaman
//
//  Created by 김민수 on 6/8/25.
//

import UIKit
import RxSwift

enum CommonAlertType {
    case logout
    case withdraw
    case withdrawConfirm(isChecked: Bool)

    var title: String {
        switch self {
        case .logout:
            return "읽다만에서\n로그아웃하시겠어요?"
        case .withdraw:
            return "읽다만에서\n탈퇴하시겠어요?"
        case .withdrawConfirm:
            return "탈퇴 후 이전 기록은 재복구가 불가능해요.\n그래도 탈퇴하시겠어요?\n\n· 독서중인 책, 다 읽은 책\n· 책의 첫인상, 생각 기록\n· 내 책장"
        }
    }

    var hasCheckbox: Bool {
        if case .withdrawConfirm = self {
            return true
        }
        return false
    }
}



final class CommonAlertViewController: UIViewController {

    private let type: CommonAlertType
    private let disposeBag = DisposeBag()

    var onConfirm: ((Bool) -> Void)?
    var onCancel: (() -> Void)?

    private let dimmedView = UIView()
    private let containerView = UIView()
    private let titleLabel = UILabel().then {
        $0.textColor = .black
        $0.font = .pretendard(.semiBold, size: 14)
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    private let cancelButton = UIButton().then {
        $0.setTitle("아니오", for: .normal)
        $0.titleLabel?.font = .pretendard(.bold, size: 12)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .black
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 5
        $0.contentEdgeInsets = UIEdgeInsets(top: 5, left: 30, bottom: 5, right: 30)
    }
    
    private let confirmButton = UIButton().then {
        $0.setTitle("네", for: .normal)
        $0.titleLabel?.font = .pretendard(.bold, size: 12)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = #colorLiteral(red: 0.5924944878, green: 0.5924944878, blue: 0.5924944878, alpha: 1)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 5
        $0.contentEdgeInsets = UIEdgeInsets(top: 5, left: 30, bottom: 5, right: 30)
    }
    
    private let checkbox = UIButton(type: .custom).then {
        $0.setImage(UIImage(systemName: "square"), for: .normal)
        $0.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        $0.tintColor = .black
        $0.layer.borderColor = #colorLiteral(red: 0.850980401, green: 0.850980401, blue: 0.850980401, alpha: 1)
    }
    private let checkboxLabel = UILabel().then {
        $0.text = "네,탈퇴할게요"
        $0.font = .pretendard(.semiBold, size: 14)
        $0.textColor = .black
    }
    private let checkboxContainer = UIStackView()
    private var isChecked = false

    init(type: CommonAlertType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }

    private func setupUI() {
        view.addSubview(dimmedView)
        dimmedView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimmedView.snp.makeConstraints { $0.edges.equalToSuperview() }

        view.addSubview(containerView)
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12
        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(300)
        }

        titleLabel.text = type.title
        if case .withdrawConfirm = type {
            let fullText = type.title
            let detailText = "· 독서중인 책, 다 읽은 책\n· 책의 첫인상, 생각 기록\n· 내 책장"
            
            let attributedString = NSMutableAttributedString(string: fullText)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let defaultAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.pretendard(.semiBold, size: 14),
                .foregroundColor: UIColor.black,
                .paragraphStyle: paragraphStyle
            ]
            attributedString.addAttributes(defaultAttributes,
                                           range: NSRange(location: 0, length: fullText.count))
            
            if let rangeOfDetail = fullText.range(of: detailText) {
                let nsRange = NSRange(rangeOfDetail, in: fullText)
                
                let detailAttributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: #colorLiteral(red: 0.4117647409, green: 0.4117647409, blue: 0.4117647409, alpha: 1),
                    .font: UIFont.pretendard(.regular, size: 14)
                ]
                attributedString.addAttributes(detailAttributes, range: nsRange)
            }
            
            titleLabel.attributedText = attributedString
        }

        let buttonStack = UIStackView(arrangedSubviews: [cancelButton, confirmButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 5
        buttonStack.distribution = .equalCentering
        
        checkboxContainer.axis = .horizontal
        checkboxContainer.spacing = 8
        checkboxContainer.alignment = .center
        checkboxContainer.addArrangedSubview(checkbox)
        checkboxContainer.addArrangedSubview(checkboxLabel)
        checkboxContainer.isHidden = !type.hasCheckbox

        containerView.addSubview(titleLabel)
        containerView.addSubview(checkboxContainer)
        containerView.addSubview(buttonStack)

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        checkbox.snp.makeConstraints {
            $0.width.height.equalTo(24)
        }

        checkboxContainer.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }

        buttonStack.snp.makeConstraints {
            $0.top.equalTo(type.hasCheckbox ? checkboxContainer.snp.bottom : titleLabel.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(20)
            $0.height.equalTo(30)
        }
    }

    private func bind() {
        cancelButton.rx.tap
            .bind { [weak self] in
                self?.dismiss(animated: true) {
                    self?.onCancel?()
                }
            }
            .disposed(by: disposeBag)

        confirmButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                if case .withdrawConfirm = type {
                    guard self.isChecked == true else { return }
                }
                self.dismiss(animated: true) {
                    self.onConfirm?(self.isChecked)
                }
            }
            .disposed(by: disposeBag)

        checkbox.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                self.isChecked.toggle()
                self.checkbox.isSelected = self.isChecked
            }
            .disposed(by: disposeBag)
    }
}


