//
//  NoticeRepositoryImpl.swift
//  Ikdaman
//
//  Created by Soo on 6/9/25.
//

import RxSwift

final class NoticeRepositoryImpl: NoticeRepository {
    private let networkProvider = NetworkProvider.shared
    
    func fetchNotices(page: Int) -> Observable<Notices> {
        return networkProvider
            .request(BookAPI.noticeList(page: page, limit: 10), type: Notices.self)
            .asObservable()
    }
    
    func fetchNotice(id: Int) -> Observable<Notice> {
        return networkProvider
            .request(BookAPI.noticeDetail(noticeId: id), type: Notice.self)
            .asObservable()
    }
}
