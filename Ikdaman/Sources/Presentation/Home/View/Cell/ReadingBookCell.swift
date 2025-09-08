//
//  ReadingBookCell.swift
//  Ikdaman
//
//  Created by 이재혁 on 8/27/25.
//

import UIKit

class ReadingBookCell: UICollectionViewCell {
    static let identifier = "ReadingBookCell"
    
    private let containerView = UIView().then {
        $0.backgroundColor = .init(hex: "F2F2F2")
    }
    
    private let bookImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
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
        contentView.addSubview(containerView)
        containerView.addSubview(bookImageView)
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        bookImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
//            $0.height.equalTo(284)
//            $0.width.equalTo(199)
        }
    }
    
    func configure(with book: ReadingBook) {
        bookImageView.setImage(from: book.coverImage, placeholder: UIImage(named: "ic_no_image"))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bookImageView.image = nil
    }
}
