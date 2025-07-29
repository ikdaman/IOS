//
//  NoticeRepositoryImpl.swift
//  Ikdaman
//
//  Created by Soo on 6/9/25.
//

import RxSwift

final class NoticeRepositoryImpl: NoticeRepository {
    private let networkProvider = NetworkProvider.shared
    
    func fetchNotices(page: Int?, limit: Int?) -> Observable<Notices> {
        return networkProvider
            .request(BookAPI.noticeList(page: page, limit: limit), type: Notices.self)
            .asObservable()
//        return Observable.just(Notices(notices: [Notice(noticeId: 1, title: "개인정보 처리 방침 안내", content: "안녕하세요\n\n개인정보보호")], nowPage: 1, totalPage: 10))
    }
    
    func fetchNotice(id: Int) -> Observable<Notice> {
        return networkProvider
            .request(BookAPI.noticeDetail(noticeId: id), type: Notice.self)
            .asObservable()
    }
}
