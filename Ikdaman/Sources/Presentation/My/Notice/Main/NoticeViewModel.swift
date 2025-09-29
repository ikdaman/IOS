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
    var notice: NoticeDetail?
    let reloadTrigger = PublishSubject<Void>()
    let noticeContentTrigger = PublishSubject<String?>()
    
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
    
    func loadNotice(id: Int) {
        fetchUseCase.getNotice(id: id)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] notice in
                self?.notice = notice
                self?.noticeContentTrigger.onNext(notice.content)
            })
            .disposed(by: disposeBag)
    }
}
