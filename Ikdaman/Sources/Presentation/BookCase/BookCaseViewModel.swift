//
//  BookCaseViewModel.swift
//  Ikdaman
//
//  Created by Soo on 7/7/25.
//

import Foundation
import RxSwift
import RxRelay

protocol BookCaseViewModel {
    func transform(input: BookCaseViewModelInput) -> BookCaseViewModelOutput
}

struct BookCaseViewModelInput {
    let fetchBooks: Observable<Void>
    let searchTapped: Observable<String>
    let filterTapped: Observable<FilterType>
}

struct BookCaseViewModelOutput {
    var books: BehaviorRelay<[Book]>
}

final class DefaultBookCaseViewModel: BookCaseViewModel {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let booksUseCase: BookCaseUseCase
    
    var books = BehaviorRelay<[Book]>(value: [])
    
    // MARK: - Init
    init(booksUseCase: BookCaseUseCase = DefaultBookCaseUseCase(bookCaseRepository: BookCaseRepositorylmpl())) {
        self.booksUseCase = booksUseCase
    }
    
    // MARK: - Transform
    func transform(input: BookCaseViewModelInput) -> BookCaseViewModelOutput {
        
        input.fetchBooks
            .subscribe(onNext: { [weak self] in
                self?.fetchMyBook()
            })
            .disposed(by: disposeBag)
        
        input.filterTapped
            .subscribe { [weak self] filterType in
                self?.fetchMyBook(keyword: filterType.status)
            }.disposed(by: disposeBag)
        
        return BookCaseViewModelOutput(
            books: books
        )
    }
    
    private func fetchMyBook(status: String? = nil, keyword: String? = nil, page: Int? = nil, limit: Int? = nil) {
        booksUseCase.getMyBooks(status: status, keyword: keyword, page: page, limit: limit)
            .subscribe(onNext: { [weak self] bookList in
                self?.books.accept(bookList.books)
            })
            .disposed(by: disposeBag)
    }
}
