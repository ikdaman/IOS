//
//  ReadingHistory.swift
//  읽다만 iOS
//
//  Created on 2026-03-09.
//

import Foundation

struct ReadingHistory: Identifiable, Codable {
    let id: UUID
    let bookId: UUID
    let date: Date
    let pagesRead: Int
    let memo: String?
    
    init(
        id: UUID = UUID(),
        bookId: UUID,
        date: Date = Date(),
        pagesRead: Int,
        memo: String? = nil
    ) {
        self.id = id
        self.bookId = bookId
        self.date = date
        self.pagesRead = pagesRead
        self.memo = memo
    }
}
