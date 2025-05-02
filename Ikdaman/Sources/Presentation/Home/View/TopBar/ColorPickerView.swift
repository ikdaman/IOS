//
//  ColorPickerView.swift
//  Ikdaman
//
//  Created by 양원식 on 4/27/25.
//

import UIKit
import SnapKit
import Then
import RxSwift

final class ColorPickerView: UIView {
    
    // MARK: - Public Properties
    let colorSelected = PublishSubject<ColorType>()
    
    // MARK: - Private Properties
    private var buttons: [ColorType: UIButton] = [:]
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 10
        $0.alignment = .center
        $0.distribution = .fill
    }
    
    // MARK: - Initializer
    init() {
        super.init(frame: .zero)
        setupViews()
        setupLayout()
        setupStyle()
        setInitialSelectedButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupViews() {
        addSubview(stackView)
        
        ColorType.allCases.forEach { type in
            let button = UIButton().then {
                $0.backgroundColor = type.buttonColor
                $0.layer.cornerRadius = 11.5
                $0.layer.borderColor = UIColor.white.cgColor
                $0.layer.borderWidth = 1.5
                $0.layer.shadowColor = UIColor.black.cgColor
                $0.layer.shadowOpacity = 0.2
                $0.layer.shadowOffset = CGSize(width: 0, height: 2)
                $0.layer.shadowRadius = 8
                $0.layer.masksToBounds = false
            }
            
            button.snp.makeConstraints {
                $0.width.height.equalTo(23)
            }
            
            button.rx.tap
                .subscribe(onNext: { [weak self] in
                    self?.updateSelectedButton(selectedType: type)
                    self?.colorSelected.onNext(type)
                })
                .disposed(by: disposeBag)
            
            stackView.addArrangedSubview(button)
            buttons[type] = button
        }
    }
    
    private func setupLayout() {
        stackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.equalToSuperview().inset(15)
        }
    }
    
    private func setupStyle() {
        backgroundColor = .white
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 5
    }
    
    private func setInitialSelectedButton() {
        updateSelectedButton(selectedType: .purple)
    }
    
    // MARK: - Private Methods
    private func updateSelectedButton(selectedType: ColorType) {
        UIView.animate(withDuration: 0.2) {
            self.buttons.forEach { (type, button) in
                button.layer.borderColor = (type == selectedType) ? UIColor.black.cgColor : UIColor.white.cgColor
            }
        }
    }
}
