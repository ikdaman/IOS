//
//  BookCaseUseCase.swift
//  Ikdaman
//
//  Created by Soo on 7/8/25.
//

import RxSwift

protocol BookCaseUseCase {
    func getMyBooks(status: String?, keyword: String?, page: Int?, limit: Int?) -> Observable<MyBook>
}

final class DefaultBookCaseUseCase: BookCaseUseCase {
    private let bookCaseRepository: BookCaseRepository
    
    init(bookCaseRepository: BookCaseRepository) {
        self.bookCaseRepository = bookCaseRepository
    }
    
    func getMyBooks(status: String?, keyword: String?, page: Int?, limit: Int?) -> RxSwift.Observable<MyBook> {
        bookCaseRepository.getMyBooks(status: status, keyword: keyword, page: page, limit: limit)
    }
}
