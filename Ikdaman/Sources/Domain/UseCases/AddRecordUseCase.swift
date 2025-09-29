//
//  AddRecordUseCase.swift
//  Ikdaman
//
//  Created by Soo on 9/12/25.
//

import RxSwift
import Moya
import Foundation

protocol AddRecordUseCase {
    func addFirstImpression(bookId: Int, impression: String, createdAt: Date) -> Observable<Response>
    func addProgress(bookId: Int, page: Int, content: String, createdAt: Date) -> Observable<Response>
    func addCompletion(bookId: Int, review: String, createdAt: Date) -> Observable<Response>
}

final class DefaultAddRecordUseCase: AddRecordUseCase {
    private let recordRepository: RecordRepository
    
    init(recordRepository: RecordRepository) {
        self.recordRepository = recordRepository
    }
    
    func addFirstImpression(bookId: Int, impression: String, createdAt: Date) -> Observable<Response> {
        recordRepository.addFirstImpression(bookId: bookId, impression: impression, createdAt: createdAt)
    }
    
    func addProgress(bookId: Int, page: Int, content: String, createdAt: Date) -> Observable<Response> {
        recordRepository.addProgress(bookId: bookId, page: page, content: content, createdAt: createdAt)
    }
    
    func addCompletion(bookId: Int, review: String, createdAt: Date) -> Observable<Response> {
        recordRepository.addCompletion(bookId: bookId, review: review, createdAt: createdAt)
    }
}
