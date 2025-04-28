//
//  HomeViewModel.swift
//  Ikdaman
//
//  Created by 김창규 on 2/11/25.
//

import Foundation
import RxSwift
import RxRelay

protocol HomeViewModel {
    func transform(input: HomeViewModelInput) -> HomeViewModelOutput
}

struct HomeViewModelInput {
    let fetchBooks: Observable<Int>
    let selectColor: Observable<ColorType>
    let toggleColorPicker: Observable<Void>
}

struct HomeViewModelOutput {
    let books: PublishSubject<[Book]>
    let selectedColorType: Observable<ColorType>
    let isColorPickerVisible: Observable<Bool>
}

final class DefaultHomeViewModel: HomeViewModel {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let fetchBooksUseCase: FetchBooksUseCase
    private let selectedColorRelay = BehaviorRelay<ColorType>(value: .purple)
    private let colorPickerVisibleRelay = BehaviorRelay<Bool>(value: false)
    
    let books = PublishSubject<[Book]>()
    
    // MARK: - Init
    init(fetchBooksUseCase: FetchBooksUseCase = DefaultFetchBooksUseCase()) {
        self.fetchBooksUseCase = fetchBooksUseCase
    }
    
    // MARK: - Transform
    func transform(input: HomeViewModelInput) -> HomeViewModelOutput {
        
        input.fetchBooks
            .subscribe(onNext: { [weak self] userId in
                self?.fetch(userId: userId)
            })
            .disposed(by: disposeBag)
        
        input.selectColor
            .bind(onNext: { [weak self] colorType in
                self?.selectedColorRelay.accept(colorType)
            })
            .disposed(by: disposeBag)
        
        input.toggleColorPicker
            .withLatestFrom(colorPickerVisibleRelay)
            .map { !$0 }
            .bind(to: colorPickerVisibleRelay)
            .disposed(by: disposeBag)
        
        return HomeViewModelOutput(
            books: books.asObserver(),
            selectedColorType: selectedColorRelay.asObservable(),
            isColorPickerVisible: colorPickerVisibleRelay.asObservable()
        )
    }
    
    private func fetch(userId: Int) {
        fetchBooksUseCase.execute(requestValue: .init(userId: userId))
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] bookList in
                self?.books.onNext(bookList.books)
            })
            .disposed(by: disposeBag)
    }
}
