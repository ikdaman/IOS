//
//  BookDetailRepositorylmpl.swift
//  Ikdaman
//
//  Created by Soo on 8/7/25.
//

import Foundation
import RxSwift
import Moya

final class BookDetailRepositorylmpl: BookDetailRepository {
    private let networkProvider = NetworkProvider.shared
    
    func getMyBookInfo(bookId: Int) -> RxSwift.Observable<MyBookInfo> {
        return networkProvider
            .request(BookAPI.book(bookId: bookId), type: MyBookInfo.self)
            .asObservable()
    }
    
    func getMyBookHistory(bookId: Int, page: Int?, limit: Int?) -> RxSwift.Observable<BookLogs> {
        return networkProvider
            .request(BookAPI.bookHistory(bookId: bookId, page: page, limit: limit), type: BookLogs.self)
            .asObservable()
    }
    
    func deleteBook(bookId: Int) -> RxSwift.Observable<Moya.Response> {
        return networkProvider.requestRaw(BookAPI.deleteBook(bookId: bookId))
            .asObservable()
    }
    
    func addImression(bookId: Int, impression: String, createdAt: Date) -> RxSwift.Observable<Moya.Response> {
        return networkProvider.requestRaw(BookAPI.firstImpression(bookId: bookId, impression: impression, createdAt: createdAt))
            .asObservable()
    }
    
    func addBookLog(bookId: Int, content: String, page: Int, createdAt: Date) -> RxSwift.Observable<Moya.Response> {
        return networkProvider.requestRaw(BookAPI.addThink(bookId: bookId, content: content, page: page, createdAt: createdAt))
            .asObservable()
    }
    
    func modifyBookLog(bookId: Int, content: String, bookLogId: Int) -> RxSwift.Observable<Moya.Response> {
        return networkProvider.requestRaw(BookAPI.modifyThink(bookId: bookId, content: content, bookLogId: bookLogId))
            .asObservable()
    }
    
    func deleteBookLog(bookId: Int, bookLogId: Int) -> RxSwift.Observable<Moya.Response> {
        return networkProvider.requestRaw(BookAPI.deleteThink(bookId: bookId, bookLogId: bookLogId))
            .asObservable()
    }
    
    func addCompletedBook(bookId: Int, review: String, createdAt: Date) -> RxSwift.Observable<Moya.Response> {
        return networkProvider.requestRaw(BookAPI.addCompleteRead(bookId: bookId, review: review, createdAt: createdAt))
            .asObservable()    }
}
