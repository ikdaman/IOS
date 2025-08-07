//
//  SearchDetailViewModel.swift
//  Ikdaman
//
//  Created by 이재혁 on 5/11/25.
//

import Foundation
import RxSwift
import RxCocoa

enum SearchDetailTriggerType {
    case backBtnTapped
    case impressionText(String)
    case addBookBtnTapped
}

class SearchDetailViewModel {
    typealias ViewModel = SearchDetailViewModel
    private let disposeBag = DisposeBag()
    
    private let searchDetailUseCase: SearchDetailUseCase
    
    /// 책의 첫인상 텍스트
    private var impressionText: String?
    /// 선택한 책 정보
    private var bookRelay = BehaviorRelay<AladinBook>(value: .empty)
    
    private var outputRequest = PublishRelay<RequestDestinationVC>()
    
    init(book: AladinBook,
        searchDetailUseCase: SearchDetailUseCase = DefaultSearchDetailUseCase(searchDetailRepository: SearchDetailRepositoryImpl())) {
        bookRelay.accept(book)
        self.searchDetailUseCase = searchDetailUseCase
    }
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let action: PublishRelay<SearchDetailTriggerType>
    }
    
    struct Output {
        let bookRelay: Observable<AladinBook>
        
        let outputRequest: Observable<RequestDestinationVC>
    }
    
    func transform(req: ViewModel.Input) -> ViewModel.Output {
        req.action
            .subscribe(onNext: actionTriggerRequest)
            .disposed(by: disposeBag)
        
        return Output(bookRelay: bookRelay.asObservable(),
                      outputRequest: outputRequest.asObservable())
    }
    
    func actionTriggerRequest(action: SearchDetailTriggerType) {
        switch action {
        case .backBtnTapped:
            outputRequest.accept(.back)
        case .impressionText(let text):
            impressionText = text
        case .addBookBtnTapped:
            let book = bookRelay.value
            let date = Date()
            let formatter = ISO8601DateFormatter()
            let dateString = formatter.string(from: date)
            
            let addMyBook = AddMyBook(title: book.title, writer: book.author, publisher: book.publisher,
                                      isbn: book.isbn, page: book.subInfo?.itemPage ?? 0, coverImage: book.cover,
                                      itemId: book.itemId, impression: impressionText ?? "", createdAt: dateString)
            
            searchDetailUseCase.addBook(book: addMyBook)
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

extension SearchDetailViewModel {
    enum RequestDestinationVC {
        case back
        case home
    }
}
