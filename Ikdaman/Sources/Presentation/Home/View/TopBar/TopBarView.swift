//
//  TopBarView.swift
//  Ikdaman
//
//  Created by 양원식 on 4/27/25.
//

import UIKit
import SnapKit
import Then

final class TopBarView: UIView {
    
    // MARK: - UI Components
    let colorPickerView = ColorPickerView().then {
        $0.alpha = 0
    }
    
    let colorButton = UIButton().then {
        $0.layer.cornerRadius = 11.5
        $0.layer.borderColor = UIColor.white.cgColor
        $0.layer.borderWidth = 1.5
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.2
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.shadowRadius = 8
        $0.layer.masksToBounds = false
        $0.backgroundColor = .systemPurple
    }
    
    private let menuButton = UIButton().then {
        $0.setImage(UIImage(named: "Menu"), for: .normal)
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .equalSpacing
        $0.spacing = 0
    }
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupViews() {
        addSubview(stackView)
        addSubview(colorPickerView)
        
        stackView.addArrangedSubview(colorButton)
        stackView.addArrangedSubview(UIView())
        stackView.addArrangedSubview(menuButton)
    }
    
    private func setupLayout() {
        stackView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(23)
        }
        
        colorButton.snp.makeConstraints {
            $0.width.height.equalTo(23)
        }
        
        menuButton.snp.makeConstraints {
            $0.width.equalTo(20)
            $0.height.equalTo(14)
        }
        
        colorPickerView.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(12)
            $0.leading.equalTo(colorButton)
            $0.width.equalTo(185)
            $0.height.equalTo(53)
        }
    }
}
