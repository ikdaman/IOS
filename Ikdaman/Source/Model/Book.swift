//
//  Book.swift
//  읽다만 iOS
//
//  Created on 2026-03-09.
//

import Foundation

struct Books: Codable, Identifiable {
    let id = UUID()
    let myBookId: Int
    let createdDate: String
    let reason: String
    let bookInfo: BookInfo
}
