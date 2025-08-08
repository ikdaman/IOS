//
//  MyBookInfo.swift
//  Ikdaman
//
//  Created by Soo on 8/6/25.
//

struct MyBookInfo: Codable {
    let bookInfo: [BookInfo]
    let mybookId: Int
    let startDate: String
    let nowPage: Int
    let progress: Int
    let impression: String?
}

struct BookInfo: Codable {
    let title: String
    let author: String
    let coverImage: String
    let publisher: String
    let totalPage: Int
    let category: String
}
