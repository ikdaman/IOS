//
//  HomeRepositoryImpl.swift
//  Ikdaman
//
//  Created by 이재혁 on 8/25/25.
//

import Foundation
import RxSwift
import Moya

final class HomeRepositoryImpl: HomeRepository {
    private let networkProvider = NetworkProvider.shared
    
    func getReadingBooks() -> RxSwift.Observable<ReadingBookInfo> {
        return networkProvider
            .request(BookAPI.bookListReading, type: ReadingBookInfo.self)
            .asObservable()
    }
    
    func deleteMyBook(id: Int) -> RxSwift.Observable<Moya.Response> {
        return networkProvider
            .requestRaw(BookAPI.deleteBook(bookId: id))
            .asObservable()
    }
}
