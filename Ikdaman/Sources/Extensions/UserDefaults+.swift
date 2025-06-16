//
//  UserDefaults.swift
//  Ikdaman
//
//  Created by Soo on 4/28/25.
//

import Foundation

extension UserDefaults {
    var nickName: String? {
        get { string(forKey: "nickName") }
        set { set(newValue, forKey: "nickName") }
    }
}
