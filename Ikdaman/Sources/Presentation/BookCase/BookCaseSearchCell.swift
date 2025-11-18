//
//  BookCaseSearchCell.swift
//  Ikdaman
//
//  Created by Soo on 11/18/25.
//

import UIKit

class BookCaseSearchCell: UICollectionViewCell {
    static let identifier = "BookCaseSearchCell"

    private let imageView = UIImageView()
    private let titleLabel = UILabel().then {
        $0.font = .pretendard(.medium, size: 14)
        $0.numberOfLines = 2
        $0.textAlignment = .left
    }
    private let authorLabel = UILabel().then {
        $0.font = .pretendard(.regular, size: 12)
        $0.textAlignment = .left
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {

        contentView.addSubviews([imageView, titleLabel, authorLabel])
        imageView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(160)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(36)
        }
        
        authorLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(5)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(21)
        }
        
    }

    func configure(book: Book) {
        titleLabel.text = book.title
        authorLabel.text = book.author
        let highResURLString = book.coverImage.aladinHighResURL()
        
        if let url = URL(string: highResURLString) {
            imageView.kf.setImage(with: url)
        }
    }
}
