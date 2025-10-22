//
//  AlertViewController.swift
//  Ikdaman
//
//  Created by 이재혁 on 9/9/25.
//

import UIKit

class AlertViewController: UIViewController {
    
    var cancelAction: (() -> Void)?
   var confirmAction: (() -> Void)?
    
    private var titleText: String?
    private var cancelText: String?
    private var confirmText: String?
    
    // MARK: - Properties
    private lazy var containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
        
        $0.addSubviews([containerStackView, buttonStackView])
        
        containerStackView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.lessThanOrEqualTo(buttonStackView.snp.top).offset(-24)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(20)
            $0.width.equalTo(167)
        }
    }
    
    private lazy var containerStackView = UIStackView().then {
        $0.backgroundColor = .white
        $0.axis = .vertical
        $0.distribution = .fillProportionally
        $0.spacing = 24
        
        $0.addArrangedSubviews([titleLabel, customContainerView])
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = .black
        $0.textAlignment = .center
        $0.font = .pretendard(.semiBold, size: 14)
        $0.numberOfLines = 0
    }
    
    private let customContainerView = UIView().then {
        $0.isHidden = true
    }
    
    private lazy var buttonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 5
        $0.distribution = .fillEqually
        
        $0.addArrangedSubviews([cancelBtn, confirmBtn])
        
        [cancelBtn, confirmBtn].forEach {
            $0.snp.makeConstraints {
                $0.height.equalTo(30)
            }
        }
    }
    
    private lazy var cancelBtn = UIButton().then {
        $0.backgroundColor = .black
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .pretendard(.semiBold, size: 14)
        $0.layer.cornerRadius = 5
        $0.clipsToBounds = true
        $0.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
    }
    
    private lazy var confirmBtn = UIButton().then {
        $0.backgroundColor = .init(hex: "858585")
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .pretendard(.semiBold, size: 14)
        $0.layer.cornerRadius = 5
        $0.clipsToBounds = true
        $0.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        attribute()
    }
    
    // MARK: - Methods
    private func setupLayout() {
        view.addSubview(containerView)
        
        containerView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(44)
            $0.centerY.equalToSuperview()
        }
    }
    
    private func attribute() {
        view.backgroundColor = .black.withAlphaComponent(0.5)
    }
    
    // MARK: - Actions
    @objc private func cancelTapped() {
        cancelAction?()
        dismiss(animated: true)
    }
    
    @objc private func confirmTapped() {
        confirmAction?()
        dismiss(animated: true)
    }
    
    // MARK: - Public Methods
    func configure(titleText: String, cancelText: String = "취소", confirmText: String = "확인", customView: UIView? = nil) {
        titleLabel.text = titleText
        cancelBtn.setTitle(cancelText, for: .normal)
        confirmBtn.setTitle(confirmText, for: .normal)
        
        if let customView = customView {
            customContainerView.addSubview(customView)
            customView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            
            customContainerView.isHidden = false
        }
    }
}

class Alert {
    static func show(
        title: String,
        cancelText: String = "취소",
        confirmText: String = "확인",
        customView: UIView? = nil,
        onCancel: (() -> Void)? = nil,
        onConfirm: (() -> Void)? = nil
    ) {
        let alertVC = AlertViewController()
        alertVC.configure(titleText: title, cancelText: cancelText, confirmText: confirmText, customView: customView)
        alertVC.cancelAction = onCancel
        alertVC.confirmAction = onConfirm
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve
        
        guard let topVC = UIApplication.getMostTopViewController() else { return }
        topVC.present(alertVC, animated: true)
    }
    
    // MARK: - Builder Pattern (체이닝 방식)
    private var alertVC: AlertViewController
    
    init() {
        self.alertVC = AlertViewController()
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve
    }
    
    @discardableResult
    func title(_ text: String) -> Alert {
        alertVC.configure(titleText: text, cancelText: "", confirmText: "")
        return self
    }
    
    @discardableResult
    func cancelButton(_ text: String, action: (() -> Void)? = nil) -> Alert {
        alertVC.cancelAction = action
        return self
    }
    
    @discardableResult
    func confirmButton(_ text: String, action: (() -> Void)? = nil) -> Alert {
        alertVC.confirmAction = action
        return self
    }
    
    func show() {
        guard let topVC = UIApplication.getMostTopViewController() else { return }
        topVC.present(alertVC, animated: true)
    }
}
