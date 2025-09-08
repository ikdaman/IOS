//
//  HomeViewModel.swift
//  Ikdaman
//
//  Created by 김창규 on 2/11/25.
//

import Foundation
import RxSwift
import RxRelay

enum HomeTriggerType {
    case colorSelected(ColorType)
    case addBookButtonTapped
    case addRecordBtnTapped
}

final class HomeViewModel {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let homeUseCase: HomeUseCase
    
    private let readingBooksRelay = BehaviorRelay<[ReadingBook]>(value: [])
    private let selectedColorRelay = BehaviorRelay<ColorType>(value: .purple)
    private let colorPickerVisibleRelay = BehaviorRelay<Bool>(value: false)
    
    let books = PublishSubject<[Book]>()
    
    private let outputRequest = PublishRelay<RequestDestinationVC>()
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let action: PublishRelay<HomeTriggerType>
    }

    struct Output {
        let readingBooks: Observable<[ReadingBook]>
        let selectedColorType: Observable<ColorType>
        let outputRequest: Observable<RequestDestinationVC>
        
        
//        let isColorPickerVisible: Observable<Bool>
    }
    
    // MARK: - Init
    init(homeUseCase: HomeUseCase = DefaultHomeUseCase(homeRepository: HomeRepositoryImpl())) {
        self.homeUseCase = homeUseCase
    }
    
    // MARK: - Transform
    func transform(req: Input) -> Output {
        req.viewDidLoad
            .subscribe(onNext: fetchBookDatas)
            .disposed(by: disposeBag)
        
        req.action
            .subscribe(onNext: actionTriggerRequest)
            .disposed(by: disposeBag)
        
//        input.fetchBooks
//            .subscribe(onNext: { [weak self] userId in
//                self?.fetch(userId: userId)
//            })
//            .disposed(by: disposeBag)
//        
//        input.selectColor
//            .bind(onNext: { [weak self] colorType in
//                self?.selectedColorRelay.accept(colorType)
//            })
//            .disposed(by: disposeBag)
//        
//        input.toggleColorPicker
//            .withLatestFrom(colorPickerVisibleRelay)
//            .map { !$0 }
//            .bind(to: colorPickerVisibleRelay)
//            .disposed(by: disposeBag)
        
        return Output(
            readingBooks: readingBooksRelay.asObservable(),
            selectedColorType: selectedColorRelay.asObservable(),
            outputRequest: outputRequest.asObservable()
            
//            books: books.asObserver(),
//            selectedColorType: selectedColorRelay.asObservable(),
//            isColorPickerVisible: colorPickerVisibleRelay.asObservable()
        )
    }
    
    func actionTriggerRequest(action: HomeTriggerType) {
        switch action {
        case .colorSelected(let colorType):
            selectedColorRelay.accept(colorType)
            
        case .addBookButtonTapped:
            TabBarNavigator.shared.navigateToSearch()
            
        case .addRecordBtnTapped:
            print("책 기록 추가 버튼 탭")
        }
    }
    
    private func fetch(userId: Int) {
//        fetchBooksUseCase.execute(requestValue: .init(userId: userId))
//            .compactMap { $0 }
//            .subscribe(onNext: { [weak self] bookList in
//                self?.books.onNext(bookList.books)
//            })
//            .disposed(by: disposeBag)
    }
    
    private func fetchBookDatas() {
        homeUseCase.getReadingBooks()
            .asObservable()
            .catch { error in
                print("❌ readingBooks() 에러:", error)
                return .empty()
            }
            .withUnretained(self)
            .subscribe(onNext: { `self`, bookInfo in
                print("읽고 있는 책 목록 > \(bookInfo)")
                self.readingBooksRelay.accept(bookInfo.books)
            })
            .disposed(by: disposeBag)
    }
}

extension HomeViewModel {
    enum RequestDestinationVC {
        
    }
}
