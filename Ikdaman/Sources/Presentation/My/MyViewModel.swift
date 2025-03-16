//
//  MyViewModel.swift
//  Ikdaman
//
//  Created by 이재혁 on 3/3/25.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

// [START] Interface
struct MyViewModelActions {
//    let setupTableView: () -> Void
    let fetchUserInfo: () -> Void
}

struct MyViewModelInput {
    let viewDidLoad: Observable<Void>
//    let fetchUserInfo: Observable<Int>
}

struct MyViewModelOutput {
//    var user: PublishSubject<[User]>
    var sections: Observable<[Section]>
}

protocol MyViewModel {
    // MARK: - Binding
    func transform(input: MyViewModelInput) -> MyViewModelOutput
    
    // 기능 인터페이스 추가
}

// [END] Interface

final class DefaultMyViewModel: MyViewModel {
    private var disposeBag = DisposeBag()
    
    private var sections = BehaviorRelay<[Section]>(value: [])
    
    func transform(input: MyViewModelInput) -> MyViewModelOutput {
        input.viewDidLoad
            .subscribe(onNext: setupTableView)
            .disposed(by: disposeBag)
        
        return MyViewModelOutput(sections: sections.asObservable())
    }
    
}

extension DefaultMyViewModel {
    private func setupTableView() {
        let sectionData = [
            Section(items: [.arrow(title: "내 정보 관리")]),
            Section(items: [
                .toggle(title: "푸시 메시지 설정", isOn: true),
                .time(title: "시간", time: "21:00")
            ]),
            Section(items: [
                .arrow(title: "공지사항"),
                .arrow(title: "이용약관"),
                .arrow(title: "1:1 문의")
            ])
        ]
        
        sections.accept(sectionData)
    }
}

//final class DefaultMyViewModel: MyViewModel {
//    // MARK: - Properties
//    private var disposeBag = DisposeBag()
//    private let fetchUserUseCase: FetchUserUseCase
//    
//    // MARK: - Output
//    let user = PublishSubject<[User]>()
//    
//    // MARK: - Init
//    init(fetchUserUseCase: FetchUserUseCase = DefaultFetchUserUseCase()) {
//        self.fetchUserUseCase = fetchUserUseCase
//    }
//    
//    // MARK: - Methods
//    func transform(input: MyViewModelInput) -> MyViewModelOutput {
//        input.fetchUserInfo
//            .subscribe(onNext: { [weak self] userId in
////                self?.fetch(userId: userId)
//            }).disposed(by: disposeBag)
//        
//        return MyViewModelOutput(user: user.asObserver())
//    }
//    
//    // MARK: - Private Methods
//    private func fetch(userId: Int) {
//        fetchUserUseCase.execute(requestValue: .init(userId: userId))
//            .compactMap { $0 }
//            .subscribe(onNext: { [weak self] userInfo in
//                self?.user.onNext(userInfo)
//            }).disposed(by: disposeBag)
//    }
//}

enum CellType {
    case arrow(title: String)
    case toggle(title: String, isOn: Bool)
    case time(title: String, time: String)
}

struct Section {
    var items: [CellType]
}
