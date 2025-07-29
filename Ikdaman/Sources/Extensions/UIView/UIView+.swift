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

extension UIView {
    func applyGradient(colors: [CGColor] = [UIColor(hex: "BE9FD9", alpha: 1).cgColor, UIColor.white.cgColor],
                       startPoint: CGPoint = CGPoint(x: 0.5, y: 0.0),
                       endPoint: CGPoint = CGPoint(x: 0.5, y: 1.0)) {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        
        layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        layer.insertSublayer(gradientLayer, at: 0)
    }
}
