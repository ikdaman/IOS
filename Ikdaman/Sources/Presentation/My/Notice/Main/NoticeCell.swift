//
//  NoticeCell.swift
//  Ikdaman
//
//  Created by Soo on 6/9/25.
//

import UIKit
import SnapKit

final class NoticeCell: UITableViewCell {
    static let id = "NoticeCell"

    private let numberLabel = UILabel()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        numberLabel.font = .systemFont(ofSize: 14)
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        dateLabel.font = .systemFont(ofSize: 14)
        dateLabel.textColor = .gray

        let hStack = UIStackView(arrangedSubviews: [numberLabel, titleLabel, dateLabel])
        hStack.axis = .horizontal
        hStack.distribution = .fillProportionally
        hStack.spacing = 8

        contentView.addSubview(hStack)
        hStack.snp.makeConstraints { $0.edges.equalToSuperview().inset(16) }
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(index: Int, notice: Notice) {
        numberLabel.text = "\(notice.noticeId)"
        titleLabel.text = notice.title
//        dateLabel.text = ""
    }
}
