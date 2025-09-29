//
//  NoticeDetailViewModel.swift
//  Ikdaman
//
//  Created by Soo on 6/9/25.
//

import RxSwift
import RxCocoa

final class NoticeDetailViewModel {
    private let fetchUseCase: NoticesUseCase
    var id: Int
//    var notice = PublishRelay<Notice>()
    var disposeBag = DisposeBag()

    init(fetchUseCase: NoticesUseCase, id: Int) {
        self.fetchUseCase = fetchUseCase
        self.id = id
    }

    func loadNotices(id: Int) {
        fetchUseCase.getNotice(id: id)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] notice in
//                self?.notice.accept(notice)
            })
            .disposed(by: disposeBag)
    }
}
