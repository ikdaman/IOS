//
//  Observable+.swift
//  Ikdaman
//
//  Created by 김창규 on 2/11/25.
//

import Foundation
import RxSwift

extension Observable where Element == (data: Data, response: URLResponse) {
    
    // 서버 응답의 상태 코드와 데이터를 처리하는 메서드
    func handleAPIResponse<T: Decodable>(responseType: T.Type) -> Observable<APIResult<T>> {
        return flatMap { (data, response) -> Observable<APIResult<T>> in
            // 상태 코드 체크 및 데이터 디코딩
            guard let httpResponse = response as? HTTPURLResponse else {
                return .just(.failure(APIError.invalidResponse))
            }
            
            switch httpResponse.statusCode {
            case 200:
                do {
                    let decodedData = try JSONDecoder().decode(T.self, from: data)
                    return .just(.success(result: decodedData))
                } catch {
                    return .just(.failure(APIError.parsingError(error)))
                }
            case 400...499:
                // 클라이언트 오류
                return .just(.failure(APIError.clientError))
            case 500...599:
                // 서버 오류
                return .just(.failure(APIError.serverError))
            default:
                return .just(.failure(APIError.unknownError))
            }
        }
    }
}
