//
//  NoticeViewModel.swift
//  Ikdaman
//
//  Created by 김민수 on 6/8/25.
//

import UIKit
import RxSwift

final class NoticeViewModel {
    let fetchUseCase: NoticesUseCase
    var disposeBag = DisposeBag()
    var notices: Notices?
    let reloadTrigger = PublishSubject<Void>()
    
    init(fetchUseCase: NoticesUseCase = DefaultNoticesUseCase(
        repository: NoticeRepositoryImpl()
    )) {
        self.fetchUseCase = fetchUseCase
    }
    
    func loadNotices(page: Int?, limit: Int?) {
        fetchUseCase.getNotices(page: page, limit: limit)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] notices in
                self?.notices = notices
                self?.reloadTrigger.onNext(())
            }, onError: { error in
                print("Load notices error: \(error)")
            })
            .disposed(by: disposeBag)
    }
}
