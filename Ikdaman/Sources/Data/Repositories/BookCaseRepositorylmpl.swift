//
//  BookCaseRepositorylmpl.swift
//  Ikdaman
//
//  Created by Soo on 7/8/25.
//

import RxSwift
import Moya

final class BookCaseRepositorylmpl: BookCaseRepository {
    private let networkProvider = NetworkProvider.shared
    
    func getMyBooks(status: String?, keyword: String?, page: Int?, limit: Int?) -> RxSwift.Observable<MyBook> {
        return networkProvider
            .request(BookAPI.bookList(status: status, keyword: keyword, page: page, limit: limit), type: MyBook.self)
            .asObservable()
    }
    
    func deleteMyBook(id: Int) -> RxSwift.Observable<Moya.Response> {
        return networkProvider
            .requestRaw(BookAPI.deleteBook(bookId: id))
            .asObservable()
    }
}
