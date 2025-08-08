//
//  CustomTopBarView.swift
//  Ikdaman
//
//  Created by Soo on 8/6/25.
//

import UIKit

protocol CustomTopBarViewDelegate: AnyObject {
    func didTapBackButton()
}

class CustomTopBarView: UIView {
    let backButton = UIButton().then {
        $0.setImage(UIImage(named: "backButton"), for: .normal)
    }
    var centerTitle: String? = nil
    var customButton: UIButton? = nil
    
    init(centerTitle: String? = nil, customButton: UIButton? = nil, isHiddenBackBtn: Bool = false) {
        self.centerTitle = centerTitle
        self.customButton = customButton
        backButton.isHidden = isHiddenBackBtn
        super.init(frame: .zero)
        setupLayout()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupLayout() {
        self.backgroundColor = .clear
        self.snp.makeConstraints {
            $0.height.equalTo(50)
        }
        addSubview(backButton)
        
        backButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(13)
            $0.size.equalTo(26)
        }
        
        if let centerTitle = centerTitle {
            let centerTitleLabel = UILabel().then {
                $0.text = centerTitle
                $0.font = .systemFont(ofSize: 18, weight: .bold)
                $0.textColor = .black
            }
            addSubview(centerTitleLabel)
            centerTitleLabel.snp.makeConstraints {
                $0.center.equalToSuperview()
            }
        }
        
        if let customButton = customButton {
            addSubview(customButton)
            customButton.snp.makeConstraints {
                $0.trailing.equalToSuperview().inset(14)
                $0.centerY.equalToSuperview()
            }
        }
    }
    
    private func setupActions() {
        backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
    }

    @objc private func handleBack() {
        if let vc = self.parentViewController {
            vc.navigationController?.popViewController(animated: true)
        }
    }
}

