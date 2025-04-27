//
//  UIColor+.swift
//  Ikdaman
//
//  Created by 이재혁 on 4/20/25.
//

import UIKit

import Foundation // Scanner를 사용하기 위해 필요

extension UIColor {
    static let cream = UIColor(red: 1.0, green: 0.965, blue: 0.929, alpha: 1.0)
    
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        // 6자리인지 확인하고 아니면 기본값 사용
        guard hexSanitized.count == 6 else {
            self.init(red: 0, green: 0, blue: 0, alpha: alpha)
            return
        }
        
        let scanner = Scanner(string: hexSanitized)
        var rgb: UInt64 = 0
        
        // 스캐너가 제대로 값을 읽었는지 확인
        guard scanner.scanHexInt64(&rgb) else {
            self.init(red: 0, green: 0, blue: 0, alpha: alpha)
            return
        }
        
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}
