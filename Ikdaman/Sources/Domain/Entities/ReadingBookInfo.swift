//
//  ReadingBookInfo.swift
//  Ikdaman
//
//  Created by 이재혁 on 8/25/25.
//

import Foundation

struct ReadingBookInfo: Codable {
    let books: [ReadingBook]
}

struct ReadingBook: Codable {
    let mybookId: Int
    let title: String
    let author: String
    let progress: String?
    let firstImpression: String?
    let recentEdit: String
    let coverImage: String
}
