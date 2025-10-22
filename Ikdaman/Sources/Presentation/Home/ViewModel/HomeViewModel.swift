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
    case binTapped
    case menuTapped
    case deleteBtnTapped(Int)
    case emptyLibraryViewTapped
}

enum EditMode {
    case `default`
    case delete
}

final class HomeViewModel {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let homeUseCase: HomeUseCase
    
    private let readingBooksRelay = BehaviorRelay<[ReadingBook]>(value: [])
    private let selectedColorRelay = BehaviorRelay<ColorType>(value: .purple)
    private let colorPickerVisibleRelay = BehaviorRelay<Bool>(value: false)
    private let editModeRelay = BehaviorRelay<EditMode>(value: .default)
    
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
        let editMode: BehaviorRelay<EditMode>
        
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
            outputRequest: outputRequest.asObservable(),
            editMode: editModeRelay
            
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
            
        case .binTapped:
            print("삭제 버튼 탭")
            let mode = editModeRelay.value
            editModeRelay.accept(mode == .delete ? .default : .delete)
            
        case .menuTapped:
            print("메뉴 버튼 탭")
            
        case .deleteBtnTapped(let id):
            print("책 삭제 버튼 탭 > \(id)")
            Alert.show(title: "지금 이 책을 삭제하면\n책과 기록을 영영 복구하지 못해요 😢\n그래도 삭제하시겠어요?",
                       cancelText: "취소",
                       confirmText: "삭제",
                       onConfirm: { [weak self] in
                guard let self = self else { return }
                self.deleteBook(id)
                    .subscribe(
                        onNext: { _ in
                            print("삭제 완료")
                            self.editModeRelay.accept(.default)
                            self.fetchBookDatas()
                        },
                        onError: { error in
                            print("❌ 에러:", error)
                        }
                    )
                    .disposed(by: self.disposeBag)
            })
        case .emptyLibraryViewTapped:
            TabBarNavigator.shared.navigateToSearch()
        }
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
    
    private func deleteBook(_ id: Int) -> Observable<Void> {
        return homeUseCase.deleteMyBook(id: id)
            .asObservable()
            .flatMap { response -> Observable<Void> in
                if response.statusCode == 205 {
                    print("deleteMyBook() 성공")
                    return .just(())
                } else {
                    print("deleteMyBook() 실패 > \(response.statusCode)")
                    return .empty()
                }
            }
            .catch { error in
                print("❌ deleteMyBook() 에러:", error)
                return .empty()
            }
    }
}

extension HomeViewModel {
    enum RequestDestinationVC {
        
    }
}
