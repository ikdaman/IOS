//
//  BookDetailRepository.swift
//  Ikdaman
//
//  Created by Soo on 8/7/25.
//

import RxSwift
import Moya
import Foundation

protocol BookDetailRepository {
    func getMyBookInfo(bookId: Int) -> Observable<BookInfo>
    func getMyBookHistory(bookId: Int, page: Int?, limit: Int?) -> Observable<BookLogs>
    func addImression(bookId: Int, impression: String, createdAt: Date) -> Observable<Response>
    func addBookLog(bookId: Int, content: String, page: Int, createdAt: Date) -> Observable<Response>
    func modifyBookLog(bookId: Int, content: String, bookLogId: Int) -> Observable<Response>
    func deleteBookLog(bookId: Int, bookLogId: Int) -> Observable<Response>
    func addCompletedBook(bookId: Int) -> Observable<Response>
}
