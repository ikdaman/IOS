//
//  NoticeRepository.swift
//  Ikdaman
//
//  Created by Soo on 6/9/25.
//

import RxSwift

protocol NoticeRepository {
    func fetchNotices(page: Int?, limit: Int?) -> Observable<Notices>
    func fetchNotice(id: Int) -> Observable<Notice>
}
