//
//  BookEndpoint.swift
//  Ikdaman
//
//  Created by Soo on 1/7/26.
//

import Foundation

enum BookEndpoint {
    /// access token 재발급
    case reissueToken
    /// 로그인
    case login(type: LoginType)
    /// 로그아웃
    case logout
    /// 내 정보 수정
    case modifyProfile(user: User)
    /// 내 정보 조회
    case getProfile
    /// 닉네임 중복 확인
    case checkNickname(nickName: String)
    /// 회원탈퇴
    case withdrawal
    /// 나의 책 기록 조회
    case bookHistory(bookId: Int, page: Int, limit: Int)
    /// 나의 책 목록 조회
    case bookList(status: String?, keyword: String?, page: Int?, limit: Int?)
    /// 나의 책 삭제
    case deleteBook(bookId: Int)
    /// 나의 책 정보 조회
    case book(bookId: Int)
    /// 나의 책 추가
    case addBook(book: AddMyBook)
    /// 독서중인 책 목록 조회
    case bookListReading
    /// 생각 삭제
    case deleteThink(bookId: Int, bookLogId: Int)
    /// 생각 수정
    case modifyThink(bookId: Int, content: String, bookLogId: Int)
    /// 생각 추가
    case addThink(bookId: Int, content: String, page: Int, createdAt: Date)
    /// 완독 추가
    case addCompleteRead(bookId: Int, review: String, createdAt: Date)
    /// 완독 삭제
    case deleteCompleteRead(bookId: Int, bookLogId: Int)
    /// 완독 수정
    case modifyCompleteRead(bookId: Int, bookLogId: Int)
    /// 첫 인상 추가
    case firstImpression(bookId: Int, impression: String, createdAt: Date)
    /// 공지사항 목록 조회
    case noticeList(page: Int, limit: Int)
    /// 공지사항 상세 조회
    case noticeDetail(noticeId: Int)
    /// 공지사항 생성
    case addNotice
}

extension BookEndpoint: APIEndpoint {
    var baseURL: String {
        return "https://ikdaman.shop"
    }
    
    var path: String {
        switch self {
        case .reissueToken:
            return "/auth/reissue"
        case .login:
            return "/auth/login"
        case .logout:
            return "/auth/logout"
        case .modifyProfile, .getProfile:
            return "/members/me"
        case .checkNickname:
            return "/members/check"
        case .withdrawal:
            return "/members/me"
        case .bookHistory(let bookId, _, _):
            return "/mybooks/\(bookId)/booklog"
        case .bookList:
            return "/mybooks"
        case .deleteBook(let bookId), .book(let bookId):
            return "/mybooks/\(bookId)"
        case .addBook:
            return "/mybooks"
        case .bookListReading:
            return "/mybooks/in-progress"
        case .deleteThink(let bookId, let bookLogId), .modifyThink(let bookId, _, let bookLogId):
            return "/mybooks/\(bookId)/booklog/\(bookLogId)"
        case .addThink(let bookId, _, _, _):
            return "/mybooks/\(bookId)/booklog"
        case .addCompleteRead(let bookId, _, _):
            return "/mybooks/\(bookId)/completed"
        case .deleteCompleteRead(let bookId, let bookLogId), .modifyCompleteRead(let bookId, let bookLogId):
            return "/mybooks/\(bookId)/booklog/\(bookLogId)/completed"
        case .firstImpression(let bookId, _, _):
            return "/mybooks/\(bookId)/impression"
        case .noticeList:
            return "/notices"
        case .noticeDetail(let noticeId):
            return "/notices/\(noticeId)"
        case .addNotice:
            return "/notices"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .reissueToken, .login, .addBook, .addThink, .addCompleteRead, .firstImpression, .addNotice:
            return .post
        case .logout, .withdrawal, .deleteBook, .deleteThink, .deleteCompleteRead:
            return .delete
        case .modifyProfile, .modifyThink, .modifyCompleteRead:
            return .put
        case .getProfile, .checkNickname, .bookHistory, .bookList, .book, .bookListReading, .noticeList, .noticeDetail:
            return .get
        }
    }
    
    var headers: [String: String]? {
        var headers = ["Content-Type": "application/json"]
        
        switch self {
        case .reissueToken:
            let accessToken = "Bearer " + (KeychainService.shared.load(forKey: .accessToken) ?? "")
            let refreshToken = KeychainService.shared.load(forKey: .refreshToken) ?? ""
            headers["Authorization"] = accessToken
            headers["refresh-token"] = refreshToken
            
        case .login:
            // social-token은 APIClient에서 주입됨
            break
            
        case .logout, .getProfile, .withdrawal, .modifyProfile, .noticeList, .addBook, .book, .bookHistory,
             .firstImpression, .addThink, .modifyThink, .deleteThink, .addCompleteRead, .bookList,
             .noticeDetail, .bookListReading, .deleteBook, .deleteCompleteRead, .modifyCompleteRead:
            let accessToken = "Bearer " + (KeychainService.shared.load(forKey: .accessToken) ?? "")
            headers["Authorization"] = accessToken
            
        default:
            break
        }
        
        return headers
    }
    
    var queryParameters: [String: String]? {
        switch self {
        case .checkNickname(let nickname):
            return ["nickname": nickname]
            
        case .bookList(let status, let keyword, let page, let limit):
            var params: [String: String] = [:]
            if let status = status {
                params["status"] = status
            }
            if let keyword = keyword, !keyword.isEmpty {
                params["keyword"] = keyword
            }
            if let page = page {
                params["page"] = "\(page)"
            }
            if let limit = limit {
                params["limit"] = "\(limit)"
            }
            return params.isEmpty ? nil : params
            
        case .bookHistory(_, let page, let limit):
            return ["page": "\(page)", "limit": "\(limit)"]
            
        case .noticeList(let page, let limit):
            return ["page": "\(page)", "limit": "\(limit)"]
            
        default:
            return nil
        }
    }
    
    var body: Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        switch self {
        case .login(let type):
            let params: [String: Any] = [
                "provider": type.provider.rawValue,
                "providerId": type.providerId
            ]
            return try? JSONSerialization.data(withJSONObject: params)
            
        case .modifyProfile(let user):
            return try? encoder.encode(user)
            
        case .addBook(let book):
            return try? encoder.encode(book)
            
        case .firstImpression(_, let impression, let createdAt):
            let params: [String: Any] = [
                "impression": impression,
                "createdAt": createdAt.utcString
            ]
            return try? JSONSerialization.data(withJSONObject: params)
            
        case .addThink(_, let content, let page, let createdAt):
            let params: [String: Any] = [
                "content": content,
                "page": page,
                "createdAt": createdAt.utcString
            ]
            return try? JSONSerialization.data(withJSONObject: params)
            
        case .addCompleteRead(_, let review, let createdAt):
            let params: [String: Any] = [
                "review": review,
                "createdAt": createdAt.utcString
            ]
            return try? JSONSerialization.data(withJSONObject: params)
            
        case .modifyThink(_, let content, _):
            let params: [String: Any] = ["content": content]
            return try? JSONSerialization.data(withJSONObject: params)
            
        default:
            return nil
        }
    }
}
