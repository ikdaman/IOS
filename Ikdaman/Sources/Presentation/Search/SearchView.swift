//
//  SearchView.swift
//  Ikdaman
//
//  Created by 이재혁 on 4/20/25.
//

import UIKit
import RxSwift
import RxCocoa

class SearchView: UIView {
    // MARK: - Properties
    
    private lazy var searchContainerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 30
        $0.clipsToBounds = true
        
        $0.addSubviews([searchTextField, searchButton])
        
        searchTextField.snp.makeConstraints {
            $0.left.equalToSuperview().inset(22)
            $0.right.equalTo(searchButton.snp.left).offset(-10)
            $0.verticalEdges.equalToSuperview()
        }
        
        searchButton.snp.makeConstraints {
            $0.verticalEdges.right.equalToSuperview().inset(5)
            $0.size.equalTo(45)
        }
    }
    
    private let searchTextField = UITextField().then {
        $0.placeholder = "책 제목을 검색해주세요."
        $0.backgroundColor = .clear
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.borderStyle = .none
    }
    
    private let searchButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_magnifier"), for: .normal)
        $0.backgroundColor = UIColor(hex: "36271D")
        $0.layer.cornerRadius = 45 / 2
    }
    
    private lazy var noResultBookView = UIView().then {
        $0.addSubviews([noBookLabel, enterDirectlyBtn])
        
        noBookLabel.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalTo(enterDirectlyBtn.snp.left).offset(-7)
            $0.centerY.equalTo(enterDirectlyBtn)
        }
        
        enterDirectlyBtn.snp.makeConstraints {
            $0.verticalEdges.right.equalToSuperview()
        }
    }
    
    private let noBookLabel = UILabel().then {
        $0.text = "찾으시는 책이 없으신가요?"
        $0.textColor = .black
        $0.font = .systemFont(ofSize: 14, weight: .regular)
    }
    
    private let enterDirectlyBtn = UIButton().then {
        let attributedString = NSAttributedString(
            string: "직접 입력하기",
            attributes: [
                .font: UIFont.systemFont(ofSize: 12, weight: .bold),
                .foregroundColor: UIColor.black,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
        )
        $0.setAttributedTitle(attributedString, for: .normal)
    }


    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        attribute()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    private func setupLayout() {
        addSubviews([searchContainerView, noResultBookView])
        
        // SnapKit을 사용한 레이아웃 설정
        searchContainerView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(55)
        }
        
        noResultBookView.snp.makeConstraints {
            $0.top.equalTo(searchContainerView.snp.bottom).offset(15)
            $0.centerX.equalTo(searchContainerView)
        }
    }
    
    private func attribute() {
        backgroundColor = UIColor(hex: "FFF6ED", alpha: 0.8)
    }
    
    private func bind() {
        
    }
}
