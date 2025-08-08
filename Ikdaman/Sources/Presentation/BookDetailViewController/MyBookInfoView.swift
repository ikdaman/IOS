//
//  MyBookInfoView.swift
//  Ikdaman
//
//  Created by Soo on 8/6/25.
//

import UIKit

class MyBookInfoView: UIView {
    var myBookInfo: MyBookInfo?
    
    let containerView = UIView().then {
        $0.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.7)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
    }
    
    let bookImage = UIImageView()
    
    let bookTitle = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .bold)
        $0.textAlignment = .left
        $0.numberOfLines = 0
        $0.text = "테스트"
    }
    
    let bookAuthor = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.textAlignment = .left
    }
    
    let bookPulbisher = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.textAlignment = .left
    }
    
    let bookTotalPage = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.textAlignment = .left
    }
    
    let showAladinButton = UIButton().then {
        let title = "알라딘에서 보기"
        let attributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .font: UIFont.systemFont(ofSize: 12, weight: .bold)
        ]
        let attributedTitle = NSAttributedString(string: title, attributes: attributes)
        $0.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupLayout() {
        addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }
        
        let authorLabel = UILabel().then {
            $0.text = "작가"
            $0.font = .systemFont(ofSize: 14, weight: .bold)
            $0.textAlignment = .left
        }
        
        let publisherLabel = UILabel().then {
            $0.text = "출판사"
            $0.font = .systemFont(ofSize: 14, weight: .bold)
            $0.textAlignment = .left
        }
        
        let totalPageLabel = UILabel().then {
            $0.text = "총 페이지"
            $0.font = .systemFont(ofSize: 14, weight: .bold)
            $0.textAlignment = .left
        }
        
        let aladinInfoLabel = UILabel().then {
            $0.text = "도서정보 알라딘 제공"
            $0.font = .systemFont(ofSize: 12, weight: .regular)
            $0.textAlignment = .left
        }
        
        containerView.addSubviews([bookImage, bookTitle, authorLabel, bookAuthor, publisherLabel, bookPulbisher,
                                   totalPageLabel, bookTotalPage, aladinInfoLabel, showAladinButton])
        
        bookImage.snp.makeConstraints {
            $0.top.equalToSuperview().offset(17)
            $0.leading.equalToSuperview().offset(17)
            $0.width.equalTo(91)
            $0.height.equalTo(130)
        }
        
        bookTitle.snp.makeConstraints {
            $0.top.equalToSuperview().offset(17)
            $0.leading.equalTo(bookImage.snp.trailing).offset(15)
            $0.trailing.equalToSuperview().inset(17)
        }
        
        authorLabel.snp.makeConstraints {
            $0.top.equalTo(bookTitle.snp.bottom).offset(22)
            $0.leading.equalTo(bookTitle.snp.leading)
            $0.width.equalTo(50)
        }
        
        bookAuthor.snp.makeConstraints {
            $0.top.equalTo(bookTitle.snp.bottom).offset(22)
            $0.leading.equalTo(authorLabel.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().inset(17)
        }
        
        publisherLabel.snp.makeConstraints {
            $0.top.equalTo(authorLabel.snp.bottom).offset(22)
            $0.leading.equalTo(bookTitle.snp.leading)
            $0.width.equalTo(50)
        }
        
        bookPulbisher.snp.makeConstraints {
            $0.top.equalTo(authorLabel.snp.bottom).offset(22)
            $0.leading.equalTo(publisherLabel.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().inset(17)
        }
        
        totalPageLabel.snp.makeConstraints {
            $0.top.equalTo(publisherLabel.snp.bottom).offset(22)
            $0.leading.equalTo(bookTitle.snp.leading)
            $0.width.equalTo(50)
        }
        
        bookTotalPage.snp.makeConstraints {
            $0.top.equalTo(publisherLabel.snp.bottom).offset(22)
            $0.leading.equalTo(totalPageLabel.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().inset(17)
        }
        
        aladinInfoLabel.snp.makeConstraints {
            $0.top.equalTo(totalPageLabel.snp.bottom).offset(18)
            $0.leading.equalTo(bookTitle.snp.leading)
            $0.bottom.equalToSuperview().inset(20)
        }
        
        showAladinButton.snp.makeConstraints {
            $0.centerY.equalTo(aladinInfoLabel)
            $0.leading.equalTo(aladinInfoLabel.snp.trailing).offset(9)
        }
    }
}

