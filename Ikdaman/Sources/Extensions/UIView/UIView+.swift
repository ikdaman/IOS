//
//  UIView+.swift
//  Ikdaman
//
//  Created by 김창규 on 2/27/25.
//

import UIKit
import RxSwift
import RxCocoa

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

/// 버튼이 아닌 일반 View에서도 터치 이벤트를 받고 싶을 때 사용해요.
extension Reactive where Base: UIView {
    public var tap: ControlEvent<Void> {
        let tapGesture = UITapGestureRecognizer()
        base.addGestureRecognizer(tapGesture)
        base.isUserInteractionEnabled = true
        
        let source = tapGesture.rx.event.map { _ in () }
        return ControlEvent(events: source)
    }
}

extension UIView {
    var parentViewController: UIViewController? {
        var responder: UIResponder? = self
        while let next = responder?.next {
            if let vc = next as? UIViewController {
                return vc
            }
            responder = next
        }
        return nil
    }
}
