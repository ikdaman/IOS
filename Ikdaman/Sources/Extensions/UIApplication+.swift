//
//  UIApplication+.swift
//  Ikdaman
//
//  Created by Soo on 4/28/25.
//

import UIKit

extension UIApplication {
    var topPadding: CGFloat {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return scene?.windows.first?.safeAreaInsets.top ?? .zero
    }
    
    var bottomPadding: CGFloat {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return scene?.windows.first?.safeAreaInsets.bottom ?? .zero
    }

}
