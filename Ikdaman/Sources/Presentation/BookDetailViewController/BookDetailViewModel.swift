//
//  BookDetailViewModel.swift
//  Ikdaman
//
//  Created by Soo on 7/10/25.
//

import Foundation
import RxSwift
import RxRelay

struct BookLogs: Codable {
    let booklogs: [BookLog]
    let hasNext: Bool
}

struct BookLog: Codable {
    let booklogId: Int
    let type: String
    let page: Int
    let content: String
    let loggedDate: Date
}

protocol BookDetailViewModel {
    func transform(input: BookDetailViewModelInput) -> BookDetailViewModelOutput
}

struct BookDetailViewModelInput {
    let fetchBookInfo: Observable<Void>
    let fetchBookHistory: Observable<Void>
}

struct BookDetailViewModelOutput {
    var bookInfo: BehaviorRelay<BookInfo?>
    var bookHistory: BehaviorRelay<BookLogs?>
}

final class DefaultBookDetailViewModel: BookDetailViewModel {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let bookDetailUseCase: BookDetailUseCase
    
    var bookInfo = BehaviorRelay<BookInfo?>(value: nil)
    var bookHistory = BehaviorRelay<BookLogs?>(value: nil)
    
    // MARK: - Init
    init(bookDetailUseCase: BookDetailUseCase = DefaultBookDetailUseCase(bookDetailRepository: BookDetailRepositorylmpl())) {
        self.bookDetailUseCase = bookDetailUseCase
    }
    
    // MARK: - Transform
    func transform(input: BookDetailViewModelInput) -> BookDetailViewModelOutput {
        
        input.fetchBookInfo
            .subscribe(onNext: { [weak self] _ in
                self?.fetchBookInfo()
            }).disposed(by: disposeBag)
        
        input.fetchBookHistory
            .subscribe(onNext: { [weak self] _ in
                self?.fetchBookHistory()
            }).disposed(by: disposeBag)

        return BookDetailViewModelOutput(bookInfo: bookInfo, bookHistory: bookHistory)
    }
    
    private func fetchBookInfo() {
        bookDetailUseCase.getMyBookInfo(bookId: 0)
            .subscribe(onNext: { [weak self] bookInfo in
                self?.bookInfo.accept(bookInfo)
            }).disposed(by: disposeBag)
    }
    
    private func fetchBookHistory() {
        bookDetailUseCase.getMyBookHistory(bookId: 0, page: 0, limit: 0)
            .subscribe(onNext: { [weak self] bookHistory in
                self?.bookHistory.accept(bookHistory)
            }).disposed(by: disposeBag)
    }
}
