//
//  AladinAPIService.swift
//  Ikdaman
//
//  Created by 이재혁 on 4/27/25.
//

import Foundation
import Moya

class AladinAPIService {
    static let shared = AladinAPIService()
    private let provider = MoyaProvider<AladinAPI>()
    
    private init() {}
    
    /// 책 검색
    func searchBooks(query: String, page: Int = 1, maxResults: Int = 20, completion: @escaping (Result<BookSearchResponse, Error>) -> Void) {
        provider.request(.searchBooks(query: query, page: page, maxResults: maxResults)) { result in
            switch result {
            case .success(let response):
                do {
                    let searchResponse = try JSONDecoder().decode(BookSearchResponse.self, from: response.data)
                    completion(.success(searchResponse))
                } catch let error {
                    print("디코딩 오류: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("요청 오류: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    func searchBook(isbn: String, completion: @escaping (Result<BookSearchResponse, Error>) -> Void) {
        provider.request(.getBook(isbn: isbn)) { result in
            switch result {
            case .success(let response):
                do {
                    let searchResponse = try JSONDecoder().decode(BookSearchResponse.self, from: response.data)
                    completion(.success(searchResponse))
                } catch let error {
                    print("[searchBook] 디코딩 오류: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("[searchBook] 요청 오류: \(error)")
                completion(.failure(error))
            }
        }
    }
}
