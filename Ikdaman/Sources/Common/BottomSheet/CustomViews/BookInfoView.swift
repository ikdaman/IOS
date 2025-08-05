//
//  BookInfoView.swift
//  Ikdaman
//
//  Created by 이재혁 on 8/5/25.
//

import UIKit

// MARK: - 책 정보를 보여주는 커스텀 뷰 예시
class BookInfoView: UIView {
    
    private let bookImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = .black
        $0.font = .pretendard(.semiBold, size: 14)
    }
    private let authorLabel = UILabel().then {
        $0.textColor = .black
        $0.font = .pretendard(.regular, size: 12)
        $0.numberOfLines = 2
    }
    
    lazy var addBookContainerView = UIView().then {
        $0.backgroundColor = .black
        $0.layer.cornerRadius = 5
        $0.addSubviews([addBookLabel, addImageView])
        
        addBookLabel.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(5)
            $0.left.equalToSuperview().inset(12)
        }
        
        addImageView.snp.makeConstraints {
            $0.left.equalTo(addBookLabel.snp.right).offset(5)
            $0.right.equalToSuperview().inset(12)
            $0.centerY.equalTo(addBookLabel)
            $0.size.equalTo(12)
        }
    }
    
    private let addBookLabel = UILabel().then {
        $0.text = "이 책 추가"
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 12, weight: .bold)
    }
    
    private let addImageView = UIImageView().then {
        $0.image = UIImage(named: "ic_plus")
        $0.contentMode = .scaleAspectFit
    }
    
    private let addBtn = UIButton().then {
        $0.backgroundColor = UIColor(hex: "FF5252")
        $0.setTitle("이 책 추가", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
//        $0.isHidden = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        addSubviews([bookImageView, titleLabel, authorLabel, addBookContainerView])
        
        bookImageView.snp.makeConstraints {
            $0.verticalEdges.left.equalToSuperview()
            $0.width.equalTo(80)
//            $0.height.equalTo(114)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(bookImageView.snp.top).offset(5)
            $0.left.equalTo(bookImageView.snp.right).offset(15)
            $0.right.equalToSuperview()
        }
        
        authorLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(3)
            $0.left.equalTo(bookImageView.snp.right).offset(15)
            $0.right.equalToSuperview()
        }
        
        addBookContainerView.snp.makeConstraints {
            $0.right.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Configure
    func configure(imageUrl: String, title: String, author: String) {
        bookImageView.loadImage(from: imageUrl)
        titleLabel.text = title
        authorLabel.text = author
    }
}
