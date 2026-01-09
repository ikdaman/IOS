//
//  APIEndpoints.swift
//  Ikdaman
//
//  Created by Soo on 1/7/26.
//

import Foundation

// MARK: - API Endpoint Protocol
protocol APIEndpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var queryParameters: [String: String]? { get }
    var body: Data? { get }
}

// MARK: - Base Configuration
enum APIConfiguration {
    static let baseURL = "https://ikdaman.shop"
}

// MARK: - Book API Endpoints
enum BookEndpoint: APIEndpoint {
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
    case withDrawal
    /// 나의 책 기록 조회
    case bookHistory(bookId: Int, page: Int?, limit: Int?)
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
    case noticeList(page: Int?, limit: Int?)
    /// 공지사항 상세 조회
    case noticeDetail(noticeId: Int)
    /// 공지사항 생성
    case addNotice

    
    var baseURL: String {
        return APIConfiguration.baseURL
    }
    
    var path: String {
        switch self {
        case .bookList:
            return "/books"
        case .bookListReading:
            return "/books/reading"
        case .book(let bookId):
            return "/books/\(bookId)"
        case .addBook:
            return "/books"
        case .deleteBook(let bookId):
            return "/books/\(bookId)"
        case .bookHistory(let bookId, _, _):
            return "/books/\(bookId)/history"
        case .firstImpression(let bookId, _, _):
            return "/books/\(bookId)/impression"
        case .addThink(let bookId, _, _, _):
            return "/books/\(bookId)/thinks"
        case .modifyThink(let bookId, _, let bookLogId):
            return "/books/\(bookId)/thinks/\(bookLogId)"
        case .deleteThink(let bookId, let bookLogId):
            return "/books/\(bookId)/thinks/\(bookLogId)"
        case .addCompleteRead(let bookId, _, _):
            return "/books/\(bookId)/complete"
        case .deleteCompleteRead(let bookId, let bookLogId):
            return "/books/\(bookId)/complete/\(bookLogId)"
        case .reissueToken:
            return "/auth/reissue"
        case .login:
            return "/auth/login"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .reissueToken, .login, .addBook(_), .addThink(_, _, _, _), .addCompleteRead(_, _, _), .firstImpression(_, _, _), .addNotice:
            return .post
        case .logout, .withDrawal, .deleteBook(_), .deleteThink(_, _), .deleteCompleteRead(_, _):
            return .delete
        case .modifyProfile, .modifyThink(_, _, _), .modifyCompleteRead(_, _):
            return .put
        case .getProfile, .checkNickname, .bookHistory(_, _, _), .bookList(_, _, _, _), .book(_), .bookListReading,
                .noticeList, .noticeDetail(_):
            return .get
        }
    }
    
    var headers: [String: String]? {
        var defaultHeaders = ["Content-Type": "application/json"]
        let accessToken = "Bearer " + (KeychainService.shared.load(forKey: .accessToken) ?? "")
        let socialToken = AuthService.shared.loginType?.token
        
        switch self {
        case .reissueToken:
            let refreshToken = KeychainService.shared.load(forKey: .refreshToken)
            defaultHeaders["Authorization"] = accessToken
            defaultHeaders["refresh-token"] = refreshToken
        case .login(_):
            defaultHeaders["social-token"] = socialToken
        case .logout, .getProfile, .withDrawal, .modifyProfile, .noticeList, .addBook, .book, .bookHistory, .firstImpression, .addThink, .modifyThink, .deleteThink, .addCompleteRead, .bookList, .noticeDetail, .bookListReading, .deleteBook:
            defaultHeaders["Authorization"] = accessToken
        default:
            break
        }
        
        return defaultHeaders
    }
    
    var queryParameters: [String: String]? {
        var param: [String: Any] = [:]
        switch self {
        case .login(let type):
            param = ["provider": type.provider.rawValue, "providerId": type.providerId]
        case .checkNickname(let nickname):
            param = ["nickname": nickname]
            return .requestParameters(parameters: param, encoding: URLEncoding.default)
        case .modifyProfile(let user):
            param = ["nickname": user.nickname, "birthdate": user.birthdate, "gender": user.gender]
        case .bookList(let status, let keyword, let page, let limit):
            if let status {
                param = ["status": status, "keyword": keyword ?? ""]
            }
            if let page, let limit {
                param = ["page": page, "limit": limit]
            }
            if let status, let page, let limit {
                param = ["status": status, "page": page, "limit": limit]
            }
            if let page, let limit, let keyword, keyword != "" {
                param = ["page": page, "limit": limit, "keyword": keyword]
            }
            if let status, let page, let limit, let keyword, keyword != "" {
                param = ["status": status, "page": page, "limit": limit, "keyword": keyword]
            }
            return .requestParameters(parameters: param, encoding: URLEncoding.default)
        case .noticeList(let page, let limit):
            param = ["page": page ?? 1, "limit": limit ?? 10]
            return .requestParameters(parameters: param, encoding: URLEncoding.default)
        case .bookHistory(_, let page, let limit):
            param = ["page": page ?? 1, "limit": limit ?? 9]
            return .requestParameters(parameters: param, encoding: URLEncoding.default)
        case .addBook(let book):
            param = ["title": book.title, "writer": book.writer, "publisher": book.publisher,
                     "isbn": book.isbn, "page": book.page, "coverImage": book.coverImage,
                     "itemId": book.itemId, "impression": book.impression, "createdAt": book.createdAt]
            return .requestParameters(parameters: param, encoding: JSONEncoding.default)
        case .firstImpression(_, let impression, let createdAt):
            param = ["impression": impression, "createdAt": createdAt.utcString]
        case .addThink(_, let content, let page, let createdAt):
            param = ["content": content, "page": page, "createdAt": createdAt.utcString]
        case .addCompleteRead(_, let review, let createdAt):
            param = ["review": review, "createdAt": createdAt.utcString]
        case .modifyThink(_, let content, _):
            param = ["content": content]
        default:
            return .requestPlain
        }
        return .requestParameters(parameters: param, encoding: JSONEncoding.default)
    }
    
    var body: Data? {
        switch self {
        case .addBook(let book):
            return try? book.toJSONData()
            
        case .firstImpression(_, let impression, let createdAt):
            let body = FirstImpressionRequest(
                impression: impression,
                createdAt: createdAt
            )
            return try? body.toJSONData()
            
        case .addThink(_, let content, let page, let createdAt):
            let body = AddThinkRequest(
                content: content,
                page: page,
                createdAt: createdAt
            )
            return try? body.toJSONData()
            
        case .modifyThink(_, let content, _):
            let body = ModifyThinkRequest(content: content)
            return try? body.toJSONData()
            
        case .addCompleteRead(_, let review, let createdAt):
            let body = CompleteReadRequest(
                review: review,
                createdAt: createdAt
            )
            return try? body.toJSONData()
            
        case .login(let type):
            return ["type": type]
            
        case .modifyProfile(let user):
            let body = UpdateProfileRequest(nickname: nickname)
            return try? body.toJSONData()
            
        default:
            return nil
        }
    }
}
