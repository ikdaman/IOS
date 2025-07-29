//
//  IconTextButton.swift
//  Ikdaman
//
//  Created by Soo on 5/26/25.
//

import UIKit

class IconTextButton: UIButton {
    
    init(
        title: String,
        image: UIImage?,
        backgroundColor: UIColor,
        textColor: UIColor,
        borderColor: CGColor? = nil
    ) {
        super.init(frame: .zero)
        
        setTitle(title, for: .normal)
        if let image = image {
            setImage(image, for: .normal)
        }

        self.backgroundColor = backgroundColor
        self.setTitleColor(textColor, for: .normal)
        self.layer.cornerRadius = 10
        self.imageView?.contentMode = .scaleAspectFit
        self.titleLabel?.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        if let borderColor = borderColor {
            self.layer.borderWidth = 1
            self.layer.borderColor = borderColor
        }

        // text, image 간격
        var buttonConfig = UIButton.Configuration.plain()
        buttonConfig.imagePadding = 10
        self.configuration = buttonConfig
        
        self.translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
