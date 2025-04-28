//
//  UserDefaults.swift
//  Ikdaman
//
//  Created by Soo on 4/28/25.
//

import Foundation

extension UserDefaults {
    var authToken: String? {
        get { string(forKey: "authToken") }
        set { set(newValue, forKey: "authToken") }
    }
}
