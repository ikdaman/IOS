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
    
    private let binButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_bin"), for: .normal)
    }
    
    private let menuButton = UIButton().then {
        $0.setImage(UIImage(named: "Menu"), for: .normal)
    }
    
    private let leftStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 0
    }
    
    private let rightStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 12
    }
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupLayout() {
        addSubviews([leftStackView, rightStackView])
        leftStackView.addArrangedSubview(colorButton)
        rightStackView.addArrangedSubviews([binButton, menuButton])
        
        leftStackView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.left.equalToSuperview().inset(16)
            $0.height.equalTo(23)
        }
        
        rightStackView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.right.equalToSuperview().inset(16)
            $0.height.equalTo(23)
        }
        
        [colorButton, binButton, menuButton].forEach {
            $0.snp.makeConstraints {
                $0.size.equalTo(26)
            }
        }
    }
}
