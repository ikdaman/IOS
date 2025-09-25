//
//  AddRecordRepository.swift
//  Ikdaman
//
//  Created by Soo on 9/12/25.
//

import RxSwift
import Moya
import Foundation

protocol RecordRepository {
    func addFirstImpression(bookId: Int, impression: String, createdAt: Date) -> Observable<Response>
    func addProgress(bookId: Int, page: Int, content: String, createdAt: Date) -> Observable<Response>
    func addCompletion(bookId: Int, review: String, createdAt: Date) -> Observable<Response>
}
