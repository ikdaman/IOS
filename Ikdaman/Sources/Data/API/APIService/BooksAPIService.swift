//
//  BooksAPIService.swift
//  Ikdaman
//
//  Created by 김창규 on 2/11/25.
//
import RxSwift

protocol BooksAPIService {
    func fetchBooksList(userId: Int) -> Observable<APIResult<BookList?>>
}
