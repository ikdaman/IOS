//
//  BookCaseCell.swift
//  Ikdaman
//
//  Created by Soo on 11/18/25.
//

import UIKit

class BookCaseCell: UICollectionViewCell {

    static let identifier = "BookCaseCell"

    private let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        contentView.layer.cornerRadius = 8

        contentView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func configure(book: Book) {
        let highResURLString = book.coverImage.aladinHighResURL()
        
        if let url = URL(string: highResURLString) {
            imageView.kf.setImage(with: url)
        }
    }
}
