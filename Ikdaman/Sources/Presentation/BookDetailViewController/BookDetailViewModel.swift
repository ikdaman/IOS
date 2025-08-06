//
//  BookDetailViewModel.swift
//  Ikdaman
//
//  Created by Soo on 7/10/25.
//

import UIKit

struct BookLogs: Codable {
    let booklogs: [BookLog]
    let hasNext: Bool
}

struct BookLog: Codable {
    let booklogId: Int
    let type: String
    let page: Int
    let content: String
    let loggedDate: Date
}
