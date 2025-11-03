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
    var isKeywordSearch: BehaviorRelay<Bool>
}

class DefaultBookCaseViewModel: BookCaseViewModel {
    private let disposeBag = DisposeBag()
    private let booksUseCase: BookCaseUseCase
    
    var books = BehaviorRelay<[Book]>(value: [])
    var currentFilter: FilterType? = .all
    
    var nowPage = 1
    var totalPage = 1
    var isLoading = false
    private var keyword: String? = nil
    private var isKeywordSearh = BehaviorRelay<Bool>(value: false)
    
    init(booksUseCase: BookCaseUseCase = DefaultBookCaseUseCase(bookCaseRepository: BookCaseRepositorylmpl())) {
        self.booksUseCase = booksUseCase
    }
    
    func transform(input: BookCaseViewModelInput) -> BookCaseViewModelOutput {
        // 최초 로딩
        input.fetchBooks
            .subscribe(onNext: { [weak self] in
                self?.resetAndFetch()
            })
            .disposed(by: disposeBag)
        
        // 필터 선택 시
        input.filterTapped
            .subscribe(onNext: { [weak self] filterType in
                self?.currentFilter = filterType
                self?.resetAndFetch()
            })
            .disposed(by: disposeBag)
        
        // 검색 버튼 탭 시
        input.searchTapped
            .subscribe(onNext: { [weak self] keyword in
                self?.keyword = keyword
                if keyword == "" {
                    self?.isKeywordSearh.accept(false)
                } else {
                    self?.isKeywordSearh.accept(true)
                }
                self?.resetAndFetch()
            })
            .disposed(by: disposeBag)
        
        return BookCaseViewModelOutput(
            books: books,
            isKeywordSearch: isKeywordSearh
        )
    }
    
    // MARK: - Private
    private func resetAndFetch() {
        nowPage = 1
        totalPage = 1
        books.accept([])
        fetchMyBook(page: nowPage, status: currentFilter?.status, keyword: keyword)
    }
    
    func fetchNextPage() {
        guard !isLoading, nowPage < totalPage else { return }
        nowPage += 1
        fetchMyBook(page: nowPage, status: currentFilter?.status, keyword: keyword)
    }
    
    private func fetchMyBook(page: Int, status: String? = nil, keyword: String? = nil, limit: Int? = 9) {
        guard !isLoading else { return }
        isLoading = true
        
        booksUseCase.getMyBooks(status: status, keyword: keyword, page: page, limit: limit)
            .subscribe(onNext: { [weak self] bookList in
                guard let self = self else { return }
                self.isLoading = false
                self.nowPage = bookList.nowPage
                self.totalPage = bookList.totalPage
                
                let newBooks: [Book]
                if page == 1 {
                    newBooks = bookList.books
                } else {
                    newBooks = self.books.value + bookList.books
                }
                self.books.accept(newBooks)
            }, onError: { [weak self] _ in
                self?.isLoading = false
            })
            .disposed(by: disposeBag)
    }
}
