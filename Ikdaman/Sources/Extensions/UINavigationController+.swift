//
//  UINavigationController+.swift
//  Ikdaman
//
//  Created by 이재혁 on 8/7/25.
//

import UIKit

extension UINavigationController {
    func popToRootViewController(animated: Bool = true, completion: (() -> Void)? = nil) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.popToRootViewController(animated: animated)
        CATransaction.commit()
    }
}
