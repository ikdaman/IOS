//
//  SearchDetailRepositoryImpl.swift
//  Ikdaman
//
//  Created by 이재혁 on 8/6/25.
//

import Foundation
import RxSwift
import Moya

final class SearchDetailRepositoryImpl: SearchDetailRepository {
    private let networkProvider = NetworkProvider.shared
    
    func addMyBooks(book: AddMyBook) -> Single<Response> {
        return networkProvider.requestRaw(BookAPI.addBook(book: book))
    }
}
