//
//  Color+Extension.swift
//  Ikdaman
//
//  Created by Soo on 3/11/26.
//

import SwiftUI

extension Color {
    // 0~255 숫자로 바로 생성하기 위한 생성자
    init(r: Double, g: Double, b: Double, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red: r / 255.0,
            green: g / 255.0,
            blue: b / 255.0,
            opacity: opacity
        )
    }
    
    // HEX 코드(예: #FF5733)를 사용하는 경우를 대비한 유틸리티 (선택사항)
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let r = Double((rgb >> 16) & 0xFF)
        let g = Double((rgb >> 8) & 0xFF)
        let b = Double(rgb & 0xFF)
        
        self.init(r: r, g: g, b: b)
    }
}

extension Color {
    static let customBg = Color(r: 235, g: 238, b: 243)
    static let customLb = Color(r: 51, g: 51, b: 51)
    static let customBt = Color(r: 212, g: 212, b: 212)
    static let customBlue = Color(r: 1, g: 1, b: 150)
    // 브랜드 아이덴티티 컬러
    static let brandPrimary = Color(r: 52, g: 152, b: 219)    // 시원한 블루
    static let brandSecondary = Color(r: 46, g: 204, b: 113)  // 에메랄드 그린
    
    // 배경 및 텍스트용 컬러
    
    static let pointRed = Color(r: 231, g: 76, b: 60)
    
    // HEX 코드로 관리하고 싶을 때
    static let mainDark = Color(hex: "2C3E50")
}
