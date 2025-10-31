//
//  RowSeparatorView.swift
//  Ikdaman
//
//  Created by Soo on 10/31/25.
//

import UIKit

class RowSeparatorView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        let topView = UIView()
        topView.backgroundColor = #colorLiteral(red: 1, green: 0.9999999404, blue: 1, alpha: 0.3)
        let bottomView = UIView()
        bottomView.backgroundColor = .clear

        addSubview(topView)
        addSubview(bottomView)

        topView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(23)
        }
        bottomView.snp.makeConstraints {
            $0.top.equalTo(topView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(27)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class RowSeparatorFlowLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        // Decoration View 등록
        self.register(RowSeparatorView.self, forDecorationViewOfKind: "RowSeparator")
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }
        var allAttributes = attributes

        // 셀만 뽑아서 같은 Y값(= 같은 행) 기준으로 그룹핑
        let cellAttrs = attributes.filter { $0.representedElementCategory == .cell }
        let grouped = Dictionary(grouping: cellAttrs) { attr in
            Int(attr.frame.minY.rounded())
        }

        for (_, rowAttrs) in grouped {
            guard let first = rowAttrs.first else { continue }

            // 한 행 전체 width 만큼 밑줄 뷰 생성
            let decoration = UICollectionViewLayoutAttributes(
                forDecorationViewOfKind: "RowSeparator",
                with: IndexPath(item: first.indexPath.item, section: first.indexPath.section)
            )

            let rowMaxY = rowAttrs.map { $0.frame.maxY }.max() ?? first.frame.maxY
            decoration.frame = CGRect(
                x: 0,
                y: rowMaxY,
                width: collectionView?.bounds.width ?? 0,
                height: 50
            )
            decoration.zIndex = -1 // 셀보다 뒤로

            allAttributes.append(decoration)
        }

        return allAttributes
    }
}
