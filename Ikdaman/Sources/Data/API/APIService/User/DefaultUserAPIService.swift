//
//  DefaultUserAPIService.swift
//  Ikdaman
//
//  Created by 이재혁 on 3/3/25.
//

import Foundation
import RxSwift
// TODO: 다시 수정 필요
final class DefaultUserAPIService: UserAPIService {

    init() {}
    
    func fetchUserList(userId: Int) -> Observable<APIResult<User?>> {
        return URLSession.shared
            .request(BooksAPI.fetchBooks)
            .handleAPIResponse(responseType: User.self)
            .map { response in
                switch response {
                case .success(let data):
                    // API호출과 데이터를 성공적으로 받았을 때 처리합니다.
                    return .success(result: data)
                    
                case .failure(let error):
                    // API호출은 성공이지만 내부적으로 실패했을 때 처리합니다.
                    return .failure(error)
                }
            }
    }
    
}
