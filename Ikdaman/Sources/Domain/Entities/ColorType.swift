//
//  ColorType.swift
//  Ikdaman
//
//  Created by 양원식 on 4/27/25.
//

import UIKit

enum ColorType: CaseIterable {
    case purple, blue, green, brown, darkGray
    
    var color: UIColor {
        switch self {
        case .purple: return UIColor(hex: "#C1A4DB")
        case .blue: return UIColor(hex: "#4C8ED9")
        case .green: return UIColor(hex: "#26843B")
        case .brown: return UIColor(hex: "#694E4E")
        case .darkGray: return UIColor(hex: "#595959")
        }
    }
    
    var gradientColors: [CGColor] {
        switch self {
        case .purple:
            return [
                UIColor(hex: "#C1A4DB").cgColor,
                UIColor(hex: "#E9D8F0").cgColor
            ]
        case .blue:
            return [
                UIColor(hex: "#4C8ED9").cgColor,
                UIColor(hex: "#D0E6FA").cgColor
            ]
        case .green:
            return [
                UIColor(hex: "#26843B").cgColor,
                UIColor(hex: "#AEE3BB").cgColor
            ]
        case .brown:
            return [
                UIColor(hex: "#694E4E").cgColor,
                UIColor(hex: "#D3C0BA").cgColor
            ]
        case .darkGray:
            return [
                UIColor(hex: "#595959").cgColor,
                UIColor(hex: "#C0C0C0").cgColor
            ]
        }
    }
    
    var buttonColor: UIColor {
        return self.color
    }
}
