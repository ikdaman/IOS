//
//  SearchDetailRepository.swift
//  Ikdaman
//
//  Created by 이재혁 on 8/6/25.
//

import RxSwift
import Moya

protocol SearchDetailRepository {
    func addMyBooks(book: AddMyBook) -> Single<Response>
}
