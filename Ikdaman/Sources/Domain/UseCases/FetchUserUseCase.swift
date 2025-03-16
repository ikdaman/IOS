//
//  FetchUserUseCase.swift
//  Ikdaman
//
//  Created by 이재혁 on 3/3/25.
//

import Foundation
import RxSwift

struct FetchUserUseCaseRequestValue {
    let userId: Int
}

protocol FetchUserUseCase {
    func execute(requestValue: FetchUserUseCaseRequestValue) -> Observable<User>
}

final class DefaultFetchUserUseCase: FetchUserUseCase {
    // MARK: - Properties
    private let userAPIService: UserAPIService
    
    // MARK: - Init
    init(
        userAPIService: UserAPIService = DefaultUserAPIService()
    ) {
        self.userAPIService = userAPIService
    }
    
    func execute(requestValue: FetchUserUseCaseRequestValue) -> Observable<User> {
        return userAPIService.fetchUserList(userId: requestValue.userId)
            .compactMap { result in
                switch result {
                case .success(let result):
                    return result!
                case .failure(let alrtMessage):
                    return nil
                }
            }
    }
}
