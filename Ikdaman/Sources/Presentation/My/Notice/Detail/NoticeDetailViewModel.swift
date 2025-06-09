//
//  NoticeDetailViewModel.swift
//  Ikdaman
//
//  Created by Soo on 6/9/25.
//

import RxSwift

final class NoticeDetailViewModel {
    private let fetchUseCase: FetchNoticesUseCase
    var id: Int
    var notice: Observable<Notice>?

    init(fetchUseCase: FetchNoticesUseCase, id: Int) {
        self.fetchUseCase = fetchUseCase
        self.id = id
    }

    func loadNotices(id: Int) {
        notice = fetchUseCase.getNotice(id: id)
    }
}
