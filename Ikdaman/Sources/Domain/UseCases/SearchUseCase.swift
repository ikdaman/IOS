//
//  SearchUseCase.swift
//  Ikdaman
//
//  Created by 이재혁 on 12/1/25.
//

import Foundation
import RxSwift
import Moya

protocol SearchUseCase {
    func addBook(book: AddMyBook) -> Single<Response>
}

final class DefaultSearchUseCase: SearchUseCase {
    private let searchRepository: SearchRepository
    
    // MARK: - Init
    init(searchRepository: SearchRepository) {
        self.searchRepository = searchRepository
    }
    
    func addBook(book: AddMyBook) -> Single<Response> {
        searchRepository.addMyBooks(book: book)
    }
}
