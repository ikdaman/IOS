//
//  AddRecordViewModel.swift
//  Ikdaman
//
//  Created by Soo on 11/18/25.
//

import UIKit
import RxSwift
import RxCocoa
import Moya

protocol AddRecordViewModel {
    func transform(input: AddRecordViewModelInput) -> AddRecordViewModelOutput
}

struct AddRecordViewModelInput {
    let tapConfirm: Observable<Void>
    let nowPageText: Observable<String?> // ✅ 현재 페이지 입력 바인딩
}

struct AddRecordViewModelOutput {
    let completeSave: PublishRelay<Void>
    let error: PublishRelay<Error>
}

final class DefaultAddRecordViewModel: AddRecordViewModel {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let addRecordUseCase: AddRecordUseCase
    let type: RecordInputType
    let bookId: Int
    var inputText: String = ""
    var createdAt: Date = Date()
    var bookTitle: String? = nil
    var bookAuthor: String? = nil
    var totalPage: Int? = nil
    var nowPage: Int? = nil
    
    private let nowPageRelay = BehaviorRelay<Int?>(value: nil) // ✅ 현재 페이지 저장
    
    // MARK: - Init
    init(addRecordUseCase: AddRecordUseCase, type: RecordInputType, bookId: Int, bookTitle: String? = nil, bookAuthor: String? = nil, totalPage: Int? = nil, nowPage: Int? = nil) {
        self.addRecordUseCase = addRecordUseCase
        self.type = type
        self.bookId = bookId
        self.bookTitle = bookTitle
        self.bookAuthor = bookAuthor
        self.totalPage = totalPage
        self.nowPage = nowPage
    }
    
    // MARK: - Transform
    func transform(input: AddRecordViewModelInput) -> AddRecordViewModelOutput {
        let completeSave = PublishRelay<Void>()
        let error = PublishRelay<Error>()
        
        // ✅ TextField 값 → nowPageRelay
        input.nowPageText
            .map { text -> Int? in
                guard let t = text, let page = Int(t) else { return nil }
                return page
            }
            .bind(to: nowPageRelay)
            .disposed(by: disposeBag)
        
        // ✅ 확인 버튼 탭 → 서버 저장
        input.tapConfirm
            .flatMapLatest { [weak self] _ -> Observable<Response> in
                guard let self = self else { return .empty() }
                
                switch self.type {
                case .firstImpression:
                    return self.addRecordUseCase
                        .addFirstImpression(bookId:self.bookId, impression: self.inputText, createdAt: self.createdAt)
                    
                case .progress:
                    guard let page = self.nowPageRelay.value else {
                        return .error(NSError(domain: "AddRecord", code: -1, userInfo: [NSLocalizedDescriptionKey: "현재 페이지 정보 없음"]))
                    }
                    return self.addRecordUseCase
                        .addProgress(bookId:self.bookId, page: page, content: self.inputText, createdAt: self.createdAt)
                    
                case .completion:
                    return self.addRecordUseCase
                        .addCompletion(bookId:self.bookId, review: self.inputText, createdAt: self.createdAt)
                }
            }
            .subscribe(onNext: { _ in
                completeSave.accept(())
            }, onError: { err in
                error.accept(err)
            })
            .disposed(by: disposeBag)
        
        return AddRecordViewModelOutput(completeSave: completeSave, error: error)
    }
}
