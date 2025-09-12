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
    func addFirstImpression(impression: String, createdAt: Date) -> Observable<Response>
    func addProgress(page: String, content: String?, createdAt: Date) -> Observable<Response>
    func addCompletion(review: String, createdAt: Date) -> Observable<Response>
}
