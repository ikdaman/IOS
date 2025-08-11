//
//  Book.swift
//  Ikdaman
//
//  Created by Soo on 7/8/25.
//

import Foundation

struct MyBook: Codable {
    let books: [Book]
    let totalPage: Int
    let nowPage: Int
}

struct Book: Codable {
    let mybookId: Int
    let title: String
    let author: String
    let coverImage: String
}

struct AddMyBook: Codable {
    let title: String
    let writer: String
    let publisher: String
    let isbn: String
    let page: Int
    let coverImage: String
    let itemId: Int
    let impression: String
    let createdAt: String
}

// TODO: 삭제 필요
struct BookList: Codable {
    
}
