//
//  FetchBooksUseCase.swift
//  Ikdaman
//
//  Created by 김창규 on 2/11/25.
//

import Foundation
import RxSwift

struct FetchBooksUseCaseRequestValue {
    let userId: Int
}

protocol FetchBooksUseCase {
    func execute(requestValue: FetchBooksUseCaseRequestValue) -> Observable<BookList>
}

final class DefaultFetchBooksUseCase: FetchBooksUseCase {
    // MARK: - Properties
    private let booksAPIService: BooksAPIService
    
    // MARK: - Init
    init(
        booksAPIService: BooksAPIService
    ) {
        self.booksAPIService = booksAPIService
    }
    
    func execute(requestValue: FetchBooksUseCaseRequestValue) -> Observable<BookList> {
        return booksAPIService.fetchBooksList(userId: requestValue.userId)
            .compactMap { result in
                switch result {
                case .success(let result):
                    return result!
                case .failure(let alrtMessage):
                    return nil
                }
            }
    }
}
