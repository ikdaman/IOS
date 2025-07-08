//
//  Book.swift
//  Ikdaman
//
//  Created by Soo on 7/8/25.
//

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

// TODO: 삭제 필요
struct BookList: Codable {
    
}
