//
//  UIViewController.swift
//  Ikdaman
//
//  Created by Soo on 7/4/25.
//

import UIKit

extension UIViewController {
    func setCustomBackButton() {
        let backImage = UIImage(systemName: "chevron.left")
        let backButton = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(didTapCustomBack))
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
    }

    @objc private func didTapCustomBack() {
        navigationController?.popViewController(animated: true)
    }
}

extension UIViewController {
    /// 모든 presented view controller를 dismiss하고 completion 실행
    func dismissAll(animated: Bool = true, completion: (() -> Void)? = nil) {
        if let presentingVC = self.presentingViewController {
            var rootVC = presentingVC
            while let parent = rootVC.presentingViewController {
                rootVC = parent
            }
            rootVC.dismiss(animated: animated, completion: completion)
        } else {
            self.dismiss(animated: animated, completion: completion)
        }
    }
}
