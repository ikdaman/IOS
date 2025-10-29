//
//  ProgressIndicatorView.swift
//  Ikdaman
//
//  Created by Soo on 8/6/25.
//

import UIKit

class ProgressIndicatorView: UIView {

    private let trackView = UIView()
    private let fillView = UIView()
    private let centerLabelContainer = UIView()
    private let iconImageView = UIImageView()
    private let percentageLabel = UILabel()

    var progress: CGFloat = 0.50 {
        didSet {
            updateProgress()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        layoutViews()
        updateProgress()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        trackView.backgroundColor = UIColor.purple.withAlphaComponent(0.3)
        trackView.layer.cornerRadius = 2
        addSubview(trackView)

        fillView.backgroundColor = .black
        fillView.layer.cornerRadius = 2
        addSubview(fillView)

        centerLabelContainer.backgroundColor = .black
        centerLabelContainer.layer.cornerRadius = 14
        centerLabelContainer.clipsToBounds = true
        addSubview(centerLabelContainer)

        iconImageView.image = UIImage(systemName: "book.fill")
        iconImageView.tintColor = .white
        centerLabelContainer.addSubview(iconImageView)

        percentageLabel.textColor = .white
        percentageLabel.font = .boldSystemFont(ofSize: 14)
        centerLabelContainer.addSubview(percentageLabel)
    }

    private func layoutViews() {
        trackView.snp.makeConstraints {
            $0.height.equalTo(3)
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }

        fillView.snp.makeConstraints {
            $0.left.top.bottom.equalTo(trackView)
            $0.width.equalTo(0) // Will update
        }

        centerLabelContainer.snp.makeConstraints {
            $0.centerY.equalTo(trackView)
            $0.centerX.equalTo(fillView.snp.right)
            $0.height.equalTo(28)
        }

        iconImageView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(8)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(16)
        }

        percentageLabel.snp.makeConstraints {
            $0.left.equalTo(iconImageView.snp.right).offset(4)
            $0.right.equalToSuperview().inset(8)
            $0.centerY.equalToSuperview()
        }
    }

    private func updateProgress() {
        percentageLabel.text = "\(Int(progress))%"
        
        let totalWidth = self.bounds.width
        let fillWidth = totalWidth / 100 * progress 
        
        fillView.snp.updateConstraints {
            $0.width.equalTo(fillWidth)
        }
        
        // centerLabelContainer의 반쪽 너비
        let containerHalfWidth = centerLabelContainer.bounds.width / 2
        let minX = containerHalfWidth
        let maxX = totalWidth - containerHalfWidth
        
        // fillWidth 기준 targetX 계산
        let targetX = min(max(fillWidth, minX), maxX)
        
        // centerX를 superview 기준으로 갱신
        centerLabelContainer.snp.remakeConstraints {
            $0.centerY.equalTo(trackView)
            $0.centerX.equalToSuperview().offset(targetX - totalWidth / 2)
            $0.height.equalTo(28)
        }
        
        layoutIfNeeded()
    }


    override func layoutSubviews() {
        super.layoutSubviews()
        updateProgress()
    }
}
