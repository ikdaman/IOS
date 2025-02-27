//
//  UIView+.swift
//  Ikdaman
//
//  Created by 김창규 on 2/27/25.
//

import UIKit

extension UIView {
    func addSubviews(_ views: [UIView]) {
        views.forEach { self.addSubview($0) }
    }
}
