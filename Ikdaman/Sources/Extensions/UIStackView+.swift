//
//  UIStackView+.swift
//  Ikdaman
//
//  Created by 이재혁 on 5/18/25.
//

import UIKit

extension UIStackView {
    /// StackView 다중 추가
    func addArrangedSubviews(_ subviews: [UIView]) {
        for subview in subviews {
            addArrangedSubview(subview)
        }
    }
}
