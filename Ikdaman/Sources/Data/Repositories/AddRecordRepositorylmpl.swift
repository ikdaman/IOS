//
//  AddRecordRepositorylmpl.swift
//  Ikdaman
//
//  Created by Soo on 9/12/25.
//

import RxSwift
import Moya
import Foundation

final class AddRecordRepositorylmpl: AddRecordUseCase {
    private let repository: RecordRepository
    
    init(repository: RecordRepository) {
        self.repository = repository
    }
    
    func addFirstImpression(impression: String, createdAt: Date) -> Observable<Response> {
        repository.addFirstImpression(impression: impression, createdAt: createdAt)
    }
    
    func addProgress(page: String, content: String?, createdAt: Date) -> Observable<Response> {
        repository.addProgress(page: page, content: content, createdAt: createdAt)
    }
    
    func addCompletion(review: String, createdAt: Date) -> Observable<Response> {
        repository.addCompletion(review: review, createdAt: createdAt)
    }
}
