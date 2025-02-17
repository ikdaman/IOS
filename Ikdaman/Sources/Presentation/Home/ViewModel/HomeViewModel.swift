//
//  HomeViewModel.swift
//  Ikdaman
//
//  Created by 김창규 on 2/11/25.
//

import Foundation
import RxSwift

// [START] Interface
struct HomeViewModelActions {
    let fetchBooks: () -> Void
}

struct HomeViewModelInput {
    let fetchBooks: Observable<Int>
}

struct HomeViewModelOutput {
    var books: PublishSubject<[Book]>
}

protocol HomeViewModel {
    //MARK: - Binding
    func transform(input: HomeViewModelInput) -> HomeViewModelOutput
    
    // 기능 인터페이스 추가
}

// [END] Interface

final class DefaultHomeViewModel: HomeViewModel {
    // MARK: - Properties
    private var disposeBag = DisposeBag()
    private let fetchBooksUseCase: FetchBooksUseCase
    
    // MARK: - Output
    let books = PublishSubject<[Book]>()
    
    // MARK: - Init
    init(fetchBooksUseCase: FetchBooksUseCase) {
        self.fetchBooksUseCase = fetchBooksUseCase
    }
    
    // MARK: - Methods
    func transform(input: HomeViewModelInput) -> HomeViewModelOutput {
        input.fetchBooks
            .subscribe(onNext: { [weak self] userId in
                self?.fetch(userId: userId)
            }).disposed(by: disposeBag)
        
        return HomeViewModelOutput(books: books.asObserver())
    }
    
    // MARK: - Private Methods
    private func fetch(userId: Int) {
        fetchBooksUseCase.execute(requestValue: .init(userId: userId))
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] bookList in
                self?.books.onNext(bookList.books)
            }).disposed(by: disposeBag)
    }
}
