//
//  UIFont+.swift
//  Ikdaman
//
//  Created by 이재혁 on 8/5/25.
//

import UIKit

extension UIFont {
    enum Style: String {
        /// 폰트 OTF 파일 이름이 아니라 PostScript 이름으로 명시해야 함. FontFamily 검색하면 확인 가능 (Mac 서체 관리자에서도 확인 가능)
        
        /// font-weight 100
        case thin = "Pretendard-Thin"
        /// font-weight 200
        case extraLight = "Pretendard-ExtraLight"
        /// font-weight 300
        case light = "Pretendard-Light"
        /// font-weight 400
        case regular = "Pretendard-Regular"
        /// font-weight 500
        case medium = "Pretendard-Medium"
        /// font-weight 600
        case semiBold = "Pretendard-SemiBold"
        /// font-weight 700
        case bold = "Pretendard-Bold"
        /// font-weight 800
        case extraBold = "Pretendard-ExtraBold"
        /// font-weight 900
        case black = "Pretendard-Black"
    }
    
    static func pretendard(_ style: Style = .regular, size: CGFloat) -> UIFont {
        return UIFont(name: style.rawValue, size: size)!
    }
    
    static func pretendard(size: CGFloat, weight: Style) -> UIFont {
        return UIFont(name: weight.rawValue, size: size)!
    }
}
