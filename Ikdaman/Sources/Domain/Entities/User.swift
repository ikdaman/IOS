//
//  User.swift
//  Ikdaman
//
//  Created by 이재혁 on 3/3/25.
//

import Foundation

struct User: Equatable, Decodable {
    let id: Int
    let birthDate: String
    let gender: String
}
