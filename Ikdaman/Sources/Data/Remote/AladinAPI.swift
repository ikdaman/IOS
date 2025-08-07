//
//  AladinAPI.swift
//  Ikdaman
//
//  Created by 이재혁 on 4/27/25.
//

import Foundation
import Moya

struct BookSearchResponse: Decodable {
    let item: [AladinBook]
    let totalResults: Int
}

struct AladinBook: Decodable {
    let title: String
    let author: String
    let publisher: String
    let pubDate: String
    let cover: String
    let isbn: String
    let itemId: Int
    let priceStandard: Int
    let description: String?
    
    let subInfo: AladinBookSubInfo?
}

extension AladinBook {
    static let empty = AladinBook(
        title: "",
        author: "",
        publisher: "",
        pubDate: "",
        cover: "",
        isbn: "",
        itemId: 0,
        priceStandard: 0,
        description: nil,
        subInfo: nil
    )
}

struct AladinBookItem: Decodable {
    let subInfo: AladinBookSubInfo
}

struct AladinBookSubInfo: Decodable {
    let itemPage: Int?
}

extension AladinBookSubInfo {
    static let empty = AladinBookSubInfo(
        itemPage: 0
    )
}

enum AladinAPI {
    case searchBooks(query: String, page: Int, maxResults: Int)
    case getBook(isbn: String)
}

extension AladinAPI: TargetType {
    var baseURL: URL {
        return URL(string: "https://www.aladin.co.kr/ttb/api")!
    }
    
    var path: String {
        switch self {
        case .searchBooks: return "ItemSearch.aspx"
        case .getBook: return "ItemLookUp.aspx"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Moya.Task {
        switch self {
        case .searchBooks(let query, let page, let maxResults):
            let parameters: [String: Any] = [
                "ttbkey": "ttbgju060611831003", // 알라딘에서 발급받은 키
                "Query": query,
                "QueryType": "Title",
                "MaxResults": maxResults,
                "start": page,
                "SearchTarget": "Book",
                "output": "js",
                "Version": "20131101"
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case .getBook(let isbn):
            let parameters: [String: Any] = [
                "ttbkey": "ttbgju060611831003",
                "itemIdType": "ISBN",
                "ItemId": isbn,
                "output": "js",
                "Version": "20131101",
                "OptResult": "ebookList,usedList,reviewList"
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
    
    var sampleData: Data {
        return Data()
    }
}
