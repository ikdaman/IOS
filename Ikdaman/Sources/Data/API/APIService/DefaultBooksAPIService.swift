//
//  DefaultBooksAPIService.swift
//  Ikdaman
//
//  Created by 김창규 on 2/11/25.
//

import Foundation
import RxSwift

final class DefaultBooksAPIService: BooksAPIService {

    init() {}
    
    func fetchBooksList(userId: Int) -> Observable<APIResult<BookList?>> {
        return URLSession.shared
            .request(BooksAPI.fetchBooks)
            .handleAPIResponse(responseType: BookList.self)
            .map { response in
                switch response {
                case .success(let data):
                    // API호출과 데이터를 성공적으로 받았을 때 처리합니다.
                    return .success(result: data)
                    
                case .failure(let error):
                    // API호출은 성공이지만 내부적으로 실패했을 때 처리합니다.
                    return .failure(error)
                }
            }
    }
    
}
