//
//  NoticesUseCase.swift
//  Ikdaman
//
//  Created by Soo on 6/9/25.
//

import RxSwift

protocol NoticesUseCase {
    func getNotices(page: Int?, limit: Int?) -> Observable<Notices>
    func getNotice(id: Int) -> Observable<Notice>
}

final class DefaultNoticesUseCase: NoticesUseCase {
    private let repository: NoticeRepository

    init(repository: NoticeRepository) {
        self.repository = repository
    }

    func getNotices(page: Int?, limit: Int?) -> Observable<Notices> {
        return repository.fetchNotices(page: page, limit: limit)
    }

    func getNotice(id: Int) -> Observable<Notice> {
        return repository.fetchNotice(id: id)
    }
}
