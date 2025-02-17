//
//  Book.swift
//  Ikdaman
//
//  Created by 김창규 on 2/11/25.
//

import Foundation

struct Book: Equatable, Decodable {
    let id: Int
    let title: String
    let author: String
    let totalPage: Int
    let currentPage: Int
}

struct BookList: Equatable, Decodable {
    let pages: Int
    let books: [Book]
}
