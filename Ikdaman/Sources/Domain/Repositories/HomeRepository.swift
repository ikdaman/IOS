//
//  HomeRepository.swift
//  Ikdaman
//
//  Created by 이재혁 on 8/25/25.
//

import RxSwift
import Moya

protocol HomeRepository {
    func getReadingBooks() -> RxSwift.Observable<ReadingBookInfo>
    func deleteMyBook(id: Int) -> Observable<Response>
}

