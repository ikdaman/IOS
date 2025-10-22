//
//  ReadingBookCell.swift
//  Ikdaman
//
//  Created by 이재혁 on 8/27/25.
//

import UIKit
import RxSwift

class ReadingBookCell: UICollectionViewCell {
    static let identifier = "ReadingBookCell"
    
    var disposeBag = DisposeBag()
    
    private let bookImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    let deleteBtn = UIButton().then {
        $0.setImage(UIImage(named: "ic_delete"), for: .normal)
        $0.isHidden = true
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
        contentView.addSubviews([bookImageView, deleteBtn])
        
        bookImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
//            $0.height.equalTo(284)
//            $0.width.equalTo(199)
        }
        
        deleteBtn.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.right.equalToSuperview().inset(10)
            $0.size.equalTo(32)
        }
    }
    
    func configure(with book: ReadingBook, editMode: EditMode) {
        bookImageView.setImage(from: book.coverImage, placeholder: UIImage(named: "ic_no_image"))
        deleteBtn.isHidden = editMode == .default
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bookImageView.image = nil
        deleteBtn.isHidden = true
        disposeBag = DisposeBag()
    }
}
