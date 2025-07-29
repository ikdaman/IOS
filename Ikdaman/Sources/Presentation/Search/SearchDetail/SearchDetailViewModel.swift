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
    
}

class SearchDetailViewModel {
    typealias ViewModel = SearchDetailViewModel
    private let disposeBag = DisposeBag()
    
    /// 선택한 책 정보
    private var selectedBookRelay = BehaviorRelay<AladinBook>(value: .empty)
    
    private var outputRequest = PublishRelay<RequestDestinationVC>()
    
    init(book: AladinBook) {
        print("asdf2 > \(book)")
        selectedBookRelay.accept(book)
    }
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let action: PublishRelay<SearchDetailTriggerType>
    }
    
    struct Output {
        let selectedBook: Observable<AladinBook>
        
        let outputRequest: Observable<RequestDestinationVC>
    }
    
    func transform(req: ViewModel.Input) -> ViewModel.Output {
        req.action
            .subscribe(onNext: actionTriggerRequest)
            .disposed(by: disposeBag)
        
        return Output(selectedBook: selectedBookRelay.asObservable(),
                      outputRequest: outputRequest.asObservable())
    }
    
    func actionTriggerRequest(action: SearchDetailTriggerType) {
        switch action {
            
        }
        
    }
}

extension SearchDetailViewModel {
    enum RequestDestinationVC {
        
    }
}
