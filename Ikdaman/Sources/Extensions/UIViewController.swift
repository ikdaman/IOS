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
