//
//  SignUpViewModel.swift
//  Ikdaman
//
//  Created by 김민수 on 2/23/25.
//

import Foundation
import RxSwift

// [START] Interface
struct SignUpViewModelActions {
    let fetchBooks: () -> Void
}

struct SignUpViewModelInput {
    let fetchBooks: Observable<Int>
}

struct SignUpViewModelOutput {
    var books: PublishSubject<[Book]>
}

protocol SignUpViewModel {
    //MARK: - Binding
    func transform(input: HomeViewModelInput) -> HomeViewModelOutput
    
    // 기능 인터페이스 추가
}

// [END] Interface

//final class DefaultLoginViewModel: LoginViewModel {
//    // MARK: - Properties
//    private var disposeBag = DisposeBag()
//    private let fetchBooksUseCase: FetchBooksUseCase
//
//    // MARK: - Output
//    let books = PublishSubject<[Book]>()
//
//    // MARK: - Init
//    init(fetchBooksUseCase: FetchBooksUseCase) {
//        self.fetchBooksUseCase = fetchBooksUseCase
//    }
//
//    // MARK: - Methods
//    func transform(input: HomeViewModelInput) -> HomeViewModelOutput {
//        input.fetchBooks
//            .subscribe(onNext: { [weak self] userId in
//                self?.fetch(userId: userId)
//            }).disposed(by: disposeBag)
//
//        return HomeViewModelOutput(books: books.asObserver())
//    }
//
//    // MARK: - Private Methods
//    private func fetch(userId: Int) {
//        fetchBooksUseCase.execute(requestValue: .init(userId: userId))
//            .compactMap { $0 }
//            .subscribe(onNext: { [weak self] bookList in
//                self?.books.onNext(bookList.books)
//            }).disposed(by: disposeBag)
//    }
//}
