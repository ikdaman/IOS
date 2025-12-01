//
//  SearchViewModel.swift
//  Ikdaman
//
//  Created by 이재혁 on 4/20/25.
//

import Foundation
import RxSwift
import RxCocoa

enum SearchTriggerType {
    case searchQuery(String)
    case searchReturnKeyTapped(String)
    case cameraBtnTapped
    case searchBtnTapped
    case selectBook(AladinBook)
    case loadMoreBooks
    case addBookBtnTapped(AladinBook)
}

class SearchViewModel {
    typealias ViewModel = SearchViewModel
    private let disposeBag = DisposeBag()
    
    private let searchUseCase: SearchUseCase
    
    init(searchUseCase: SearchUseCase = DefaultSearchUseCase(searchRepository: SearchRepositoryImpl())) {
        self.searchUseCase = searchUseCase
    }
    
    /// 화면 모드
    private var searchModeRelay = BehaviorRelay<SearchMode>(value: .default)
    /// 검색어 저장
    private var searchQueryRelay = BehaviorRelay<String>(value: "")
    /// 책 데이터
    private var searchBooksRelay = BehaviorRelay<[AladinBook]>(value: [])
    private var isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private var hasMoreDataRelay = BehaviorRelay<Bool>(value: true)
    
    private var currentQuery = ""
    private var currentPage = 1
    private let pageSize = 10
    private var totalResults = 0
    
    /// 선택한 책 정보
    private var bookRelay = BehaviorRelay<AladinBook>(value: .empty)
    
    private var outputRequest = PublishRelay<RequestDestinationVC>()
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let action: PublishRelay<SearchTriggerType>
    }
    
    struct Output {
        let searchMode: Observable<SearchMode>
        let searchQuery: BehaviorRelay<String>
        let searchBooks: Observable<[AladinBook]>
        var isLoading: Observable<Bool>
        var hasMoreData: Observable<Bool>
        
        let outputRequest: Observable<RequestDestinationVC>
    }
    
    func transform(req: ViewModel.Input) -> ViewModel.Output {
        req.action
            .subscribe(onNext: actionTriggerRequest)
            .disposed(by: disposeBag)
        
        return Output(searchMode: searchModeRelay.asObservable(),
                      searchQuery: searchQueryRelay,
                      searchBooks: searchBooksRelay.asObservable(),
                      isLoading: isLoadingRelay.asObservable(),
                      hasMoreData: hasMoreDataRelay.asObservable(),
                      outputRequest: outputRequest.asObservable()
        )
    }
    
    func actionTriggerRequest(action: SearchTriggerType) {
        switch action {
        case .searchQuery(let query):
            searchQueryRelay.accept(query)
            searchModeRelay.accept(query.isEmpty ? .default : .searching)
            
        case let .searchReturnKeyTapped(query):
            resetSearchResults(query)
            
        case .cameraBtnTapped:
            outputRequest.accept(.barcodeScanner)
            
        case .searchBtnTapped:
            guard !searchQueryRelay.value.isEmpty else { return }
            searchWithQuery(searchQueryRelay.value)
            
        case .selectBook(let book):
            AladinAPIService.shared.searchBook(isbn: book.isbn) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    print("ISBN 책 응답 > \(response)")
                    guard let book = response.item.first else {
                        print("책 정보 가져올 수 없음")
                        return
                    }
                    
                    self.outputRequest.accept(.detailBook(book))
                case .failure(let error):
                    print("검색 에러: \(error)")
                }
            }
            
            
        case .loadMoreBooks:
            loadMoreBooks()
        case .addBookBtnTapped(let book):
            let dateString = Date.currentISO8601String
            
            let addMyBook = AddMyBook(title: book.title, writer: book.author, publisher: book.publisher,
                                      isbn: book.isbn, page: book.subInfo?.itemPage ?? 0, coverImage: book.cover,
                                      itemId: book.itemId, impression: "", createdAt: dateString)
            
            searchUseCase.addBook(book: addMyBook)
                .flatMap { response -> Single<Void> in
                    if response.statusCode == 201 {
                        return .just(())
                    } else {
                        // 실패: 에러 반환
                        return .error(NSError(domain: "", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: "Add book failed with status: \(response.statusCode)"]))
                    }
                }
                .asObservable()
                .materialize()
                .withUnretained(self)
                .subscribe(onNext: { `self`, event in
                    switch event {
                    case .completed:
                        print("책 추가 성공")
                        self.outputRequest.accept(.home)
                    case .error(let error):
                        print("책 추가 실패 > \(error)")
                    default: break
                    }
                })
                .disposed(by: disposeBag)
        }
    }
}

extension SearchViewModel {
    func searchWithQuery(_ query: String) {
        print("검색어 > \(query)")
        resetSearchResults(query)
    }
    
    private func resetSearchResults(_ query: String) {
        // 새로운 검색이면 초기화
        if currentQuery != query {
            currentQuery = query
            currentPage = 1
            searchBooksRelay.accept([]) // 기존 결과 클리어
            hasMoreDataRelay.accept(true)
        }
        
        loadBooks()
    }
    
    func loadMoreBooks() {
        guard !isLoadingRelay.value && hasMoreDataRelay.value else { return }
        currentPage += 1
        loadBooks()
    }
    
    private func loadBooks() {
        isLoadingRelay.accept(true)
        
        AladinAPIService.shared.searchBooks(
            query: currentQuery,
            page: currentPage,
            maxResults: pageSize
        ) { [weak self] result in
            guard let self = self else { return }
            
            self.isLoadingRelay.accept(false)
            
            switch result {
            case .success(let response):
                print("검색 결과: 총 \(response.totalResults)개, 현재 페이지: \(self.currentPage)")
                
                self.totalResults = response.totalResults
                let newBooks = response.item
                
                // 기존 데이터에 새 데이터 추가
                var currentBooks = self.searchBooksRelay.value
                if self.currentPage == 1 {
                    currentBooks = newBooks // 첫 페이지면 교체
                } else {
                    currentBooks.append(contentsOf: newBooks) // 추가 페이지면 append
                }
                
                self.searchBooksRelay.accept(currentBooks)
                
                // 더 불러올 데이터가 있는지 확인
                let totalLoadedCount = currentBooks.count
                let hasMore = totalLoadedCount < self.totalResults && newBooks.count == self.pageSize
                self.hasMoreDataRelay.accept(hasMore)
                
                print("현재 로드된 책: \(totalLoadedCount)개, 더 있나요: \(hasMore)")
                
            case .failure(let error):
                print("검색 에러: \(error)")
            }
        }
    }
}

extension SearchViewModel {
    enum RequestDestinationVC {
        case detailBook(AladinBook)
        case barcodeScanner
        case home
    }
}

enum SearchMode {
    case `default`, searching
}
