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
            return "탈퇴 후 이전 기록은 재복구가 불가능해요.\n정말로 탈퇴하시겠어요?"
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
    private let titleLabel = UILabel()
    private let cancelButton = UIButton(type: .system)
    private let confirmButton = UIButton(type: .system)
    private let checkbox = UIButton(type: .custom)
    private let checkboxLabel = UILabel()
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
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)

        cancelButton.setTitle("아니요", for: .normal)
        confirmButton.setTitle("네", for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        confirmButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)

        let buttonStack = UIStackView(arrangedSubviews: [cancelButton, confirmButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually

        checkbox.setImage(UIImage(systemName: "square"), for: .normal)
        checkbox.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        checkbox.tintColor = .black

        checkboxLabel.text = "네,탈퇴할게요"
        checkboxLabel.font = .systemFont(ofSize: 14)

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
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        buttonStack.snp.makeConstraints {
            $0.top.equalTo(type.hasCheckbox ? checkboxContainer.snp.bottom : titleLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(20)
            $0.height.equalTo(44)
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


