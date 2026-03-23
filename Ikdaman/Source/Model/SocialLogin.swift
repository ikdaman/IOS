//
//  SocialLogin.swift
//  Ikdaman
//
//  Created by Soo on 3/16/26.
//

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
    var endedDate: String?
}

struct BookInfo: Codable {
    var title: String
    var author: [String]
    var coverImage: String
    var description: String
    var ISBN: String?
    var totalPage: Int?
    var publisher: String?
    var publishDate: String?
    var link: String?
}
