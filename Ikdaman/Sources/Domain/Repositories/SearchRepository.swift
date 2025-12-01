//
//  SearchRepository.swift
//  Ikdaman
//
//  Created by 이재혁 on 12/1/25.
//

import RxSwift
import Moya

protocol SearchRepository {
    func addMyBooks(book: AddMyBook) -> Single<Response>
}
