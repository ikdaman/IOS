//
//  UserDefaults.swift
//  Ikdaman
//
//  Created by Soo on 4/28/25.
//

import Foundation
import CoreGraphics

extension UserDefaults {
    var nickName: String? {
        get { string(forKey: "nickName") }
        set { set(newValue, forKey: "nickName") }
    }
    
    var backgroundColor: String? {
        get { string(forKey: "backgroundColor") }
        set { set(newValue, forKey: "backgroundColor") }
    }
}
