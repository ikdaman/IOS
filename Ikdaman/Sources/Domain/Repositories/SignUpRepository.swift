//
//  SignUpRepository.swift
//  Ikdaman
//
//  Created by Soo on 4/22/25.
//

import RxSwift

protocol SignUpRepository {
    func login(type: LoginType) -> Observable<Profile>
}
