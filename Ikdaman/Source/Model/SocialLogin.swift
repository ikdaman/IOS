//
//  SocialLogin.swift
//  Ikdaman
//
//  Created by Soo on 3/16/26.
//

import Foundation

struct SocialLogin: Codable {
    var provider: String
    var providerId: String
    var socialToken: String
    var nickname: String?
}

struct ModifyBook: Codable {
    var shelfType: String
    var reason: String
    var historyInfo: HistoryInfo
    var bookInfo: BookInfo
}

struct HistoryInfo: Codable {
    var startedDate: String?
    var finishedDate: String?
}

struct BookInfo: Codable {
    var source: String
    var aladinId: Int
    var isbn: String
    var title: String
    var author: String
    var publisher: String?
    var description: String?
    var totalPage: Int
    var publishDate: Date?
    var coverImage: String
    var link: String?
}
