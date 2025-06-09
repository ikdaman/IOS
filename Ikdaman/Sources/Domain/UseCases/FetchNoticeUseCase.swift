//
//  FetchNoticeUseCase.swift
//  Ikdaman
//
//  Created by Soo on 6/9/25.
//

import RxSwift

protocol FetchNoticesUseCase {
    func getNotices(page: Int) -> Observable<Notices>
    func getNotice(id: Int) -> Observable<Notice>
}

final class DefaultFetchNoticesUseCase: FetchNoticesUseCase {
    private let repository: NoticeRepository

    init(repository: NoticeRepository) {
        self.repository = repository
    }

    func getNotices(page: Int) -> Observable<Notices> {
        return repository.fetchNotices(page: page)
    }

    func getNotice(id: Int) -> Observable<Notice> {
        return repository.fetchNotice(id: id)
    }
}
