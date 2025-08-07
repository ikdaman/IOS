//
//  SearchDetailUseCase.swift
//  Ikdaman
//
//  Created by 이재혁 on 8/6/25.
//

import Foundation
import RxSwift
import Moya

protocol SearchDetailUseCase {
    func addBook(book: AddMyBook) -> Single<Response>
}

final class DefaultSearchDetailUseCase: SearchDetailUseCase {
    private let searchDetailRepository: SearchDetailRepository
    
    // MARK: - Init
    init(searchDetailRepository: SearchDetailRepository) {
        self.searchDetailRepository = searchDetailRepository
    }
    
    func addBook(book: AddMyBook) -> Single<Response> {
        searchDetailRepository.addMyBooks(book: book)
    }
}
