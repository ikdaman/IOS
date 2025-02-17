//
//  BooksAPI.swift
//  Ikdaman
//
//  Created by 김창규 on 2/11/25.
//

import Foundation

enum BooksAPI: BaseAPI {
    case fetchBooks
}

extension BooksAPI {
    var path: String {
        switch self {
        case .fetchBooks:
            return "https:// ... "
        }
    }
    
    var method: String {
        switch self {
        case .fetchBooks:
            return "GET"
        }
    }
    
    // 추가적인 헤더나 파라미터가 필요하면 확장 가능
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}
