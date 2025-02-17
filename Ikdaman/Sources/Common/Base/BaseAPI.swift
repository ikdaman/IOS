//
//  BaseAPI.swift
//  Ikdaman
//
//  Created by 김창규 on 2/11/25.
//

import Foundation

protocol BaseAPI {
    /// API의 엔드포인트 경로
    var path: String { get }
    
    /// HTTP 요청 메서드 (예: `GET`, `POST`)
    var method: String { get }
    
    /// HTTP 요청에 포함될 헤더
    var headers: [String: String]? { get }
}

extension BaseAPI {
    /**
     API 요청의 기본 URL을 반화합니다.
     
     - Returns: 개발 또는 운영 서버의 기본 URL
     */
    var baseURL: String {
        #if DEBUG
        // 개발 서버
        return "http://..."
        #else
        // 운영 서버
        return "http://..."
        #endif
    }
}

enum APIResult<T> {
    case success(result: T)
    case failure(APIError)
}

enum APIError: Error {
    case invalidResponse
    case parsingError(Error)
    case clientError
    case serverError
    case unknownError
}
