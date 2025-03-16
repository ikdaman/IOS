//
//  UserAPIService.swift
//  Ikdaman
//
//  Created by 이재혁 on 3/3/25.
//

import RxSwift

protocol UserAPIService {
    func fetchUserList(userId: Int) -> Observable<APIResult<User?>>
}
