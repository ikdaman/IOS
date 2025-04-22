//
//  SignUpRepository.swift
//  Ikdaman
//
//  Created by Soo on 4/22/25.
//

import RxSwift

protocol SignUpRepository {
    func login() -> Single<LoginInfo>
    func test() -> Single<User>
}
