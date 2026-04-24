//
//  BookEndpoint.swift
//  Ikdaman
//
//  Created by Soo on 3/16/26.
//

import Foundation

enum BookEndpoint {
    /// 로그아웃
    case logout
    /// 소셜 로그인 - 네이버, 카카오
    case login(type: SocialLogin)
    /// 소셜 로그인 - 구글, 애플
    case login2(type: SocialLogin)
    /// access token 재발급
    case reissueToken
    /// 소셜 회원가입
    case signup(type: SocialLogin)


    /// 내 정보 수정
    case modifyProfile(nickname: String)
    /// 내 정보 조회
    case getProfile
    /// 닉네임 중복 확인
    case checkNickname(nickname: String)
    /// 회원탈퇴
    case withdrawal
    
    
    /// 독서 시작
    case startRead(bookId: Int, bookDate: BookDate)
    /// 나의 책 삭제
    case deleteBook(bookId: Int)
    /// 나의 책 정보 수정
    case modifyMyBook(bookId: Int, modifyBook: ModifyBook)
    /// 나의 책 상세 조회
    case myBook(bookId: Int)
    /// 나의 책 추가
    case addBook(bookInfo: BookInfo, historyInfo: HistoryInfo?, reason: String?)
    /// 내 서점 책 목록 조회
    case bookList(keyword: String?, page: Int?, limit: Int?, sort: String?)
    /// 히스토리 목록 조회
    case history(page: Int, limit: Int)
    /// 나의 책 검색
    case searchMyBook(query: String)
    

//    /// 공지사항 목록 조회
//    case noticeList(page: Int, limit: Int)
//    /// 공지사항 상세 조회
//    case noticeDetail(noticeId: Int)
//    /// 공지사항 생성
//    case addNotice
}

extension BookEndpoint: APIEndpoint {
    var baseURL: String {
        return "https://ikdaman.shop"
    }
    
    var path: String {
        switch self {
        case .logout:
            return "/auth/logout"
        case .login:
            return "/auth/login"
        case .login2:
            return "/auth/login/idToken"
        case .reissueToken:
            return "/auth/reissue"
        case .signup:
            return "/auth/signup"
        
        case .modifyProfile, .getProfile, .withdrawal:
            return "/members/me"
        case .checkNickname:
            return "/members/check"
            
        case .startRead(let bookId, _):
            return "/mybooks/\(bookId)/reading-status"
        case .deleteBook(let bookId), .modifyMyBook(let bookId, _), .myBook(let bookId) :
            return "/mybooks/\(bookId)"
        case .addBook, .searchMyBook:
            return "/mybooks"
        case .bookList:
            return "/mybooks/store"
        case .history:
            return "/mybooks/history"

//        case .noticeList:
//            return "/notices"
//        case .noticeDetail(let noticeId):
//            return "/notices/\(noticeId)"
//        case .addNotice:
//            return "/notices"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .login, .login2, .reissueToken,.signup, .addBook:
            return .post
        case .logout, .withdrawal, .deleteBook:
            return .delete
        case .modifyProfile, .startRead, .modifyMyBook:
            return .patch
        case .getProfile, .checkNickname, .myBook, .bookList, .history, .searchMyBook:
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

        case .login, .login2, .signup:
            // social-token은 APIClient에서 주입됨
            break

        case .addBook, .logout, .withdrawal, .deleteBook, .modifyProfile, .startRead, .modifyMyBook, .getProfile, .checkNickname, .myBook, .bookList, .history, .searchMyBook:
            let accessToken = "Bearer " + (KeychainService.shared.load(forKey: .accessToken) ?? "")
            headers["Authorization"] = accessToken
            // addBook은 한글 body를 포함하므로 charset 명시 (Android Retrofit 동작과 동일)
            if case .addBook = self {
                headers["Content-Type"] = "application/json; charset=UTF-8"
            }
        }

        return headers
    }
    
    var queryParameters: [String: String]? {
        switch self {
        case .checkNickname(let nickname):
            return ["nickname": nickname]
        case .searchMyBook(let query):
            return ["query": query]
        case .bookList(let keyword, let page, let limit, let sort):
            var params: [String: String] = [:]
            if let keyword = keyword, !keyword.isEmpty {
                params["keyword"] = keyword
            }
            params["page"] = "\(page ?? 0)"
            params["size"] = "\(limit ?? 20)"
            params["sort"] = sort ?? "createdAt,desc"
            return params

        case .history(let page, let limit):
            return [
                "page": "\(page)",
                "size": "\(limit)"
            ]

        default:
            return nil
        }
    }
    
    var body: Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        var params: [String: Any] = [: ]
        switch self {
        case .login(let type), .login2(let type):
            params = [
                "provider": type.provider,
                "providerId": type.providerId
            ]
        case .signup(let type):
            params = [
                "provider": type.provider,
                "providerId": type.providerId
            ]
            if let nickname = type.nickname {
                params["nickname"] = nickname
            }
        case .modifyProfile(let nickname):
            params = [
                "nickname": nickname
            ]
        case .startRead(_, let bookDate):
            params = [
                "startedDate": bookDate.startDate
            ]
            if let finishedDate = bookDate.finishedDate {
                params["finishedDate"] = finishedDate
            }
        case .modifyMyBook(_, let modifyBook):
            return try? encoder.encode(modifyBook)
            
        case .addBook(let bookInfo, let historyInfo, let reason):
            // ✅ 딕셔너리 직접 구성 - null이 구조적으로 포함될 수 없음
            var bookInfoDict: [String: Any] = [
                "source":      bookInfo.source,
                "title":       bookInfo.title,
                "author":      bookInfo.author,
                "publisher":   bookInfo.publisher,
                "totalPage":   max(bookInfo.totalPage, 1),  // 0이면 1로 폴백
                "publishDate": bookInfo.publishDate          // "yyyy-MM-dd"
            ]
            // Optional 필드 - nil이면 키 자체를 추가하지 않음
            if let aladinId   = bookInfo.aladinId    { bookInfoDict["aladinId"]    = aladinId }
            if let isbn       = bookInfo.isbn         { bookInfoDict["isbn"]        = isbn }
            if let coverImage = bookInfo.coverImage   { bookInfoDict["coverImage"] = coverImage }
            // description: 서버 스펙 "2차 때 반영" → 현재 미구현, 전송 제외
            // if let desc = bookInfo.description { bookInfoDict["description"] = desc }

            var params: [String: Any] = ["bookInfo": bookInfoDict]

            // historyInfo – Optional
            if let historyInfo = historyInfo {
                var historyDict: [String: Any] = [:]
                if let started  = historyInfo.startedDate  { historyDict["startedDate"]  = started }
                if let finished = historyInfo.finishedDate { historyDict["finishedDate"] = finished }
                if !historyDict.isEmpty { params["historyInfo"] = historyDict }
            }

            // reason – Optional
            if let reason = reason, !reason.isEmpty { params["reason"] = reason }

            // 🔍 디버그: 실제 전송 Body 확인
            print("📋 [addBook DEBUG] body = \(params)")

            return try? JSONSerialization.data(withJSONObject: params)

        default:
            return nil
        }


        if !params.isEmpty {
             return try? JSONSerialization.data(withJSONObject: params)
        } else {
            return nil
        }
    }
}
