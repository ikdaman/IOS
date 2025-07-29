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
    case searchBtnTapped
    case selectBook(AladinBook)
}

class SearchViewModel {
    typealias ViewModel = SearchViewModel
    private let disposeBag = DisposeBag()
    
    /// 화면 모드
    private var searchModeRelay = BehaviorRelay<SearchMode>(value: .default)
    /// 검색어 저장
    private var searchQueryRelay = BehaviorRelay<String>(value: "")
    /// 책 데이터
    private var searchBooksRelay = BehaviorRelay<[AladinBook]>(value: [])
    
    private var outputRequest = PublishRelay<RequestDestinationVC>()
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let action: PublishRelay<SearchTriggerType>
    }
    
    struct Output {
        let searchMode: Observable<SearchMode>
        let searchQuery: BehaviorRelay<String>
        let searchBooks: Observable<[AladinBook]>
        
        let outputRequest: Observable<RequestDestinationVC>
    }
    
    func transform(req: ViewModel.Input) -> ViewModel.Output {
        req.viewDidLoad
            .subscribe(onNext: fetchDataList)
            .disposed(by: disposeBag)
        
        req.action
            .subscribe(onNext: actionTriggerRequest)
            .disposed(by: disposeBag)
        
        return Output(searchMode: searchModeRelay.asObservable(),
                      searchQuery: searchQueryRelay,
                      searchBooks: searchBooksRelay.asObservable(),
                      outputRequest: outputRequest.asObservable()
        )
    }
    
    func actionTriggerRequest(action: SearchTriggerType) {
        switch action {
        case .searchQuery(let query):
            searchQueryRelay.accept(query)
            searchModeRelay.accept(query.isEmpty ? .default : .searching)
        case .searchBtnTapped:
            guard !searchQueryRelay.value.isEmpty else { return }
            searchWithQuery(searchQueryRelay.value)
        case .selectBook(let book):
            outputRequest.accept(.detailBook(book))
        }
    }
}

extension SearchViewModel {
    private func fetchDataList() {
        
    }
    
    func searchWithQuery(_ query: String) {
        print("검색어 > \(query)")
        
        // TODO: 최대 보여질 수 있는 개수 제한 확인 필요
        AladinAPIService.shared.searchBooks(query: query, maxResults: 50) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                print("검색 결과: 총 \(response.totalResults)개")
                let books = response.item
                self.searchBooksRelay.accept(books)
                print("책 정보 > \(books)")
            case .failure(let error):
                print("검색 에러: \(error)")
            }
        }
    }
}

extension SearchViewModel {
    enum RequestDestinationVC {
        case detailBook(AladinBook)
    }
}

enum SearchMode {
    case `default`, searching
}
