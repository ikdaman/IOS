//
//  UILabel+.swift
//  Ikdaman
//
//  Created by Soo on 8/11/25.
//

import UIKit

extension UILabel {
    func setText(_ text: String, letterSpacing: CGFloat) {
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.kern, value: letterSpacing, range: NSRange(location: 0, length: text.count))
        self.attributedText = attributedString
    }
}
