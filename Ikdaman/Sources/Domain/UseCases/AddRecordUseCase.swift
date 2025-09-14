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
    func addFirstImpression(impression: String, createdAt: Date) -> Observable<Response>
    func addProgress(page: String, content: String?, createdAt: Date) -> Observable<Response>
    func addCompletion(review: String, createdAt: Date) -> Observable<Response>
}

final class DefaultAddRecordUseCase: AddRecordUseCase {
    private let recordRepository: RecordRepository
    
    init(recordRepository: RecordRepository) {
        self.recordRepository = recordRepository
    }
    
    func addFirstImpression(impression: String, createdAt: Date) -> Observable<Response> {
        recordRepository.addFirstImpression(impression: impression, createdAt: createdAt)
    }
    
    func addProgress(page: String, content: String?, createdAt: Date) -> Observable<Response> {
        recordRepository.addProgress(page: page, content: content, createdAt: createdAt)
    }
    
    func addCompletion(review: String, createdAt: Date) -> Observable<Response> {
        recordRepository.addCompletion(review: review, createdAt: createdAt)
    }
}
