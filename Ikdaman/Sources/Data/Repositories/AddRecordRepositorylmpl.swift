//
//  AddRecordRepositorylmpl.swift
//  Ikdaman
//
//  Created by Soo on 9/12/25.
//

import RxSwift
import Moya
import Foundation

final class AddRecordRepositorylmpl: RecordRepository {
    private let networkProvider = NetworkProvider.shared
    
    func addFirstImpression(bookId: Int, impression: String, createdAt: Date) -> RxSwift.Observable<Moya.Response> {
        return networkProvider
            .requestRaw(BookAPI.firstImpression(bookId: bookId, impression: impression, createdAt: createdAt))
            .asObservable()
    }
    
    func addProgress(bookId: Int, page: Int, content: String, createdAt: Date) -> RxSwift.Observable<Moya.Response> {
        return networkProvider
            .requestRaw(BookAPI.addThink(bookId: bookId, content: content, page: page, createdAt: createdAt))
            .asObservable()
    }
    
    func addCompletion(bookId: Int, review: String, createdAt: Date) -> RxSwift.Observable<Moya.Response> {
        return networkProvider
            .requestRaw(BookAPI.addCompleteRead(bookId: bookId, review: review, createdAt: createdAt))
            .asObservable()
    }
}
