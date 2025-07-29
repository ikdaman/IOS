//
//  UIButton+.swift
//  Ikdaman
//
//  Created by 김민수 on 6/8/25.
//

import UIKit

extension UIButton {
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        let image = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: CGSize(width: 1, height: 1)))
        }
        self.setBackgroundImage(image, for: state)
    }
}
