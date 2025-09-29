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
    let booklogs: [BookLog]?
    let hasNext: Bool
}

struct BookLog: Codable {
    let booklogId: Int
    let type: String
    let page: Int?
    let content: String?
    let loggedDate: String
}

protocol BookDetailViewModel {
    func transform(input: BookDetailViewModelInput) -> BookDetailViewModelOutput
}

struct BookDetailViewModelInput {
    let fetchBookInfo: Observable<Void>
    let fetchBookHistory: Observable<Void>
    let tapDeleteBook: Observable<Void>
    let tapModifyLog: Observable<(String, Int)>
    let tapDeleteLog: Observable<Int>
}

struct BookDetailViewModelOutput {
    var bookInfo: BehaviorRelay<MyBookInfo?>
    var bookHistory: BehaviorRelay<BookLogs?>
    var completeDelete: PublishRelay<Void>
}

final class DefaultBookDetailViewModel: BookDetailViewModel {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let bookDetailUseCase: BookDetailUseCase
    
    var bookId: Int
    var bookLogId: Int?
    var page: Int? = 1
    var limit: Int? = 9
    var bookInfo = BehaviorRelay<MyBookInfo?>(value: nil)
    var bookHistory = BehaviorRelay<BookLogs?>(value: nil)
    var completeDelete = PublishRelay<Void>()
    
    // MARK: - Init
    init(bookDetailUseCase: BookDetailUseCase = DefaultBookDetailUseCase(bookDetailRepository: BookDetailRepositorylmpl()), bookId: Int) {
        self.bookDetailUseCase = bookDetailUseCase
        self.bookId = bookId
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
        
        input.tapDeleteBook
            .subscribe(onNext: { [weak self] _ in
                self?.deleteBook()
            }).disposed(by: disposeBag)
        
        input.tapModifyLog
            .subscribe(onNext: { [weak self] tuple in
                let (content, logId) = tuple
                self?.modifyLog(content: content, bookLogId: logId)
            }).disposed(by: disposeBag)
        
        input.tapDeleteLog
            .subscribe(onNext: { [weak self] logId in
                self?.deleteLog(logId: logId)
            }).disposed(by: disposeBag)

        return BookDetailViewModelOutput(bookInfo: bookInfo, bookHistory: bookHistory, completeDelete: completeDelete)
    }
    
    private func fetchBookInfo() {
        bookDetailUseCase.getMyBookInfo(bookId: bookId)
            .subscribe(onNext: { [weak self] bookInfo in
                self?.bookInfo.accept(bookInfo)
            }).disposed(by: disposeBag)
    }
    
    private func fetchBookHistory() {
        bookDetailUseCase.getMyBookHistory(bookId: bookId, page: page, limit: limit)
            .subscribe(onNext: { [weak self] bookHistory in
                self?.bookHistory.accept(bookHistory)
            }).disposed(by: disposeBag)
    }
    
    private func deleteBook() {
        bookDetailUseCase.deleteBook(bookId: bookId)
            .subscribe(onNext: { [weak self] _ in
                self?.completeDelete.accept(())
            }).disposed(by: disposeBag)
    }
    
    private func modifyLog(content: String, bookLogId: Int) {
        bookDetailUseCase.modifyBookLog(bookId: bookId, content: content, bookLogId: bookLogId)
            .subscribe(onNext: { _ in
                print("modifyLog")
            })
            .disposed(by: disposeBag)
    }
    
    private func deleteLog(logId: Int) {
        bookDetailUseCase.deleteBookLog(bookId: bookId, bookLogId: logId)
            .subscribe(onNext: { _ in
                self.fetchBookHistory()
            })
            .disposed(by: disposeBag)
    }
}
