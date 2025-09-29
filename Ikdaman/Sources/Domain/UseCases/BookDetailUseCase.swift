//
//  BookDetailUseCase.swift
//  Ikdaman
//
//  Created by Soo on 8/7/25.
//

import Foundation
import RxSwift
import Moya

protocol BookDetailUseCase {
    func getMyBookInfo(bookId: Int) -> Observable<MyBookInfo>
    func getMyBookHistory(bookId: Int, page: Int?, limit: Int?) -> Observable<BookLogs>
    func deleteBook(bookId: Int) -> Observable<Response>
    func addImression(bookId: Int, impression: String, createdAt: Date) -> Observable<Response>
    func addBookLog(bookId: Int, content: String, page: Int, createdAt: Date) -> Observable<Response>
    func modifyBookLog(bookId: Int, content: String, bookLogId: Int) -> Observable<Response>
    func deleteBookLog(bookId: Int, bookLogId: Int) -> Observable<Response>
    func addCompletedBook(bookId: Int, review: String, createdAt: Date) -> Observable<Response>
}

final class DefaultBookDetailUseCase: BookDetailUseCase {
    private let bookDetailRepository: BookDetailRepository
    
    init(bookDetailRepository: BookDetailRepository) {
        self.bookDetailRepository = bookDetailRepository
    }
    
    func getMyBookInfo(bookId: Int) -> RxSwift.Observable<MyBookInfo> {
        bookDetailRepository.getMyBookInfo(bookId: bookId)
    }
    
    func getMyBookHistory(bookId: Int, page: Int?, limit: Int?) -> RxSwift.Observable<BookLogs> {
        bookDetailRepository.getMyBookHistory(bookId: bookId, page: page, limit: limit)
//        .just(BookLogs(booklogs: [BookLog(booklogId: 1, type: "11", page: 1, content: "컨텐츠", loggedDate: Date())], hasNext: false))
    }
    
    func deleteBook(bookId: Int) -> RxSwift.Observable<Moya.Response> {
        bookDetailRepository.deleteBook(bookId: bookId)
    }
    
    func addImression(bookId: Int, impression: String, createdAt: Date) -> RxSwift.Observable<Moya.Response> {
        bookDetailRepository.addImpression(bookId: bookId, impression: impression, createdAt: createdAt)
    }
    
    func addBookLog(bookId: Int, content: String, page: Int, createdAt: Date) -> RxSwift.Observable<Moya.Response> {
        bookDetailRepository.addBookLog(bookId: bookId, content: content, page: page, createdAt: createdAt)
    }
    
    func modifyBookLog(bookId: Int, content: String, bookLogId: Int) -> RxSwift.Observable<Moya.Response> {
        bookDetailRepository.modifyBookLog(bookId: bookId, content: content, bookLogId: bookLogId)
    }
    
    func deleteBookLog(bookId: Int, bookLogId: Int) -> RxSwift.Observable<Moya.Response> {
        bookDetailRepository.deleteBookLog(bookId: bookId, bookLogId: bookLogId)
    }
    
    func addCompletedBook(bookId: Int, review: String, createdAt: Date) -> RxSwift.Observable<Moya.Response> {
        bookDetailRepository.addCompletedBook(bookId: bookId, review: review, createdAt: createdAt)
    }
}
