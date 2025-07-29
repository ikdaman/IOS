//
//  BookCaseRepository.swift
//  Ikdaman
//
//  Created by Soo on 7/8/25.
//

import RxSwift
import Moya

protocol BookCaseRepository {
    func getMyBooks(status: String?, keyword: String?, page: Int?, limit: Int?) -> Observable<MyBook>
    func deleteMyBook(id: Int) -> Observable<Response>
}
