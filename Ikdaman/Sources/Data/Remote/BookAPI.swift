//
//  BookAPI.swift
//  Ikdaman
//
//  Created by Soo on 4/21/25.
//

import Foundation
import Moya
import RxSwift

protocol BaseTargetType: TargetType {}

enum BookAPI {
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
    case bookHistory(bookId: Int, page: Int, limit: Int)
    /// 나의 책 목록 조회
    case bookList(status: String?, keyword: String?, page: Int?, limit: Int?)
    /// 나의 책 삭제
    case deleteBook(bookId: Int)
    /// 나의 책 정보 조회
    case book(bookId: Int)
    /// 나의 책 추가
    case addBook(bookId: Int)
    /// 독서중인 책 목록 조회
    case bookListReading
    /// 생각 삭제
    case deleteThink(bookId: Int, bookLogId: Int)
    /// 생각 수정
    case modifyThink(bookId: Int, bookLogId: Int)
    /// 생각 추가
    case addThink(bookId: Int)
    /// 완독 추가
    case addCompleteRead(bookId: Int)
    /// 완독 삭제
    case deleteCompleteRead(bookId: Int, bookLogId: Int)
    /// 완독 수정
    case modifyCompleteRead(bookId: Int, bookLogId: Int)
    /// 첫 인상 추가
    case firstImpression(bookId: Int)
    /// 공지사항 목록 조회
    case noticeList(page: Int?, limit: Int?)
    /// 공지사항 상세 조회
    case noticeDetail(noticeId: Int)
    /// 공지사항 생성
    case addNotice
}

extension BookAPI: TargetType {
    var baseURL: URL { URL(string: "https://ikdaman.shop")! }

    var path: String {
        switch self {
        case .reissueToken:
            "/auth/reissue"
        case .login:
            "/auth/login"
//            "/auth/login/idToken"
        case .logout:
            "/auth/logout"
        case .modifyProfile:
            "/members/me"
        case .getProfile:
            "/members/me"
        case .checkNickname:
            "/members/check"
        case .withDrawal:
            "/members/me"
        case .bookHistory(let bookId, _, _):
            "/mybooks/\(bookId)"
        case .bookList(_, _, _, _):
            "/mybooks"
        case .deleteBook(let bookId):
            "/mybooks/\(bookId)"
        case .book(let bookId):
            "/mybooks/\(bookId)"
        case .addBook:
            "/mybooks"
        case .bookListReading:
            "/mybooks/in-progress"
        case .deleteThink(let bookId, let bookLodId):
            "/mybooks/\(bookId)/booklog/\(bookLodId)"
        case .modifyThink(let bookId, let bookLodId):
            "/mybooks/\(bookId)/booklog/\(bookLodId)"
        case .addThink(let bookId):
            "/mybooks/\(bookId)/booklog"
        case .addCompleteRead(let bookId):
            "/mybooks/\(bookId)/completed"
        case .deleteCompleteRead(let bookId, let bookLogId):
            "/mybooks/\(bookId)/booklog/\(bookLogId)/completed"
        case .modifyCompleteRead(let bookId, let bookLogId):
            "/mybooks/\(bookId)/booklog/\(bookLogId)/completed"
        case .firstImpression(let bookId):
            "/mybooks/\(bookId)/impression"
        case .noticeList(_, _):
            "/notices"
        case .noticeDetail(let noticeId):
            "/notices/\(noticeId)"
        case .addNotice:
            "/notices"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .reissueToken, .login, .addBook(_), .addThink(_), .addCompleteRead(_), .firstImpression(_), .addNotice:
            return .post
        case .logout, .withDrawal, .deleteBook(_), .deleteThink(_, _), .deleteCompleteRead(_, _):
            return .delete
        case .modifyProfile, .modifyThink(_, _), .modifyCompleteRead(_, _):
            return .put
        case .getProfile, .checkNickname, .bookHistory(_, _, _), .bookList(_, _, _, _), .book(_), .bookListReading,
                .noticeList, .noticeDetail(_):
            return .get
        }
    }
    
    var task: Task {
        var param: [String: Any] = [:]
        switch self {
        case .login(let type):
            param = ["provider": type.provider, "providerId": type.providerId]
        case .checkNickname(let nickname):
            param = ["nickname": nickname]
            return .requestParameters(parameters: param, encoding: URLEncoding.default)
        case .modifyProfile(let user):
            param = ["nickname": user.nickname, "birthdate": user.birthdate, "gender": user.gender]
        case .bookList(let status, let keyword, let page, let limit):
            param = ["status": status, "keyword": keyword, "page": page, "limit": limit]
            return .requestParameters(parameters: param, encoding: URLEncoding.default)
        case .noticeList(let page, let limit):
            if let page = page, let limit = limit {
                param = ["page": page, "limit": limit]
            }
            return .requestParameters(parameters: param, encoding: URLEncoding.default)
        default:
            return .requestPlain
        }
        return .requestParameters(parameters: param, encoding: JSONEncoding.default)
        
    }

    var headers: [String: String]? {
        var defaultHeaders = ["Content-Type": "application/json"]
        let accessToken = "Bearer " + (KeychainService.shared.load(forKey: .accessToken) ?? "")
        let socialToken = AuthService.shared.loginType.value?.token
        
        switch self {
        case .reissueToken:
            let refreshToken = KeychainService.shared.load(forKey: .refreshToken)
            defaultHeaders["Authorization"] = accessToken
            defaultHeaders["refresh-token"] = refreshToken
        case .login(_):
            defaultHeaders["social-token"] = socialToken
        case .logout, .getProfile, .withDrawal, .modifyProfile:
            defaultHeaders["Authorization"] = accessToken
        default:
            break
        }
        
        return defaultHeaders
    }
}

extension BookAPI: BaseTargetType {}

