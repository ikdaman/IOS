//
//  SearchRepositoryImpl.swift
//  Ikdaman
//
//  Created by 이재혁 on 12/1/25.
//

import Foundation
import RxSwift
import Moya

final class SearchRepositoryImpl: SearchRepository {
    private let networkProvider = NetworkProvider.shared
    
    func addMyBooks(book: AddMyBook) -> Single<Response> {
        return networkProvider.requestRaw(BookAPI.addBook(book: book))
    }
}
