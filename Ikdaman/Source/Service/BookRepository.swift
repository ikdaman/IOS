//
//  BookRepository.swift
//  Ikdaman
//
//  Created by Soo on 3/16/26.
//

import Foundation

// MARK: - Book Repository Protocol
protocol BookRepositoryProtocol {
    // MARK: - Auth
    func login(type: SocialLogin) async throws -> String
    func login2(type: SocialLogin) async throws -> String
    func logout() async throws
    func signup(type: SocialLogin) async throws
    func reissueToken() async throws
    
    // MARK: - Profile
    func getProfile() async throws -> ProfileResponse
    func modifyProfile(nickname: String) async throws
    func checkNickname(nickname: String) async throws -> Bool
    func withdrawal() async throws
    
    // MARK: - Books
    func getBookList(keyword: String?, page: Int?, limit: Int?) async throws -> BookListResponse
    func getBookDetail(bookId: Int) async throws -> BookDetailResponse
    func addBook(bookInfo: BookInfo, historyInfo: HistoryInfo?, reason: String) async throws
    func deleteBook(bookId: Int) async throws
    func modifyBook(bookId: Int, modifyBook: ModifyBook) async throws
    func searchMyBook(query: String) async throws -> [Books]
    
    // MARK: - Reading
    func startReading(bookId: Int, startDate: String, finishDate: String?) async throws
    func getHistory(bookId: Int, page: Int, limit: Int) async throws -> HistoryResponse
}

// MARK: - Book Repository
@MainActor
final class BookRepository: BookRepositoryProtocol {
    private let apiClient: APIClient
    
    nonisolated init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    // MARK: - Auth
    
    func login(type: SocialLogin) async throws -> String {
        let endpoint = BookEndpoint.login(type: type)
        return try await apiClient.request(endpoint, responseType: String.self)
    }
    
    func login2(type: SocialLogin) async throws -> String {
        let endpoint = BookEndpoint.login2(type: type)
        return try await apiClient.request(endpoint, responseType: String.self)
    }
    
    func logout() async throws {
        let endpoint = BookEndpoint.logout
        try await apiClient.requestRaw(endpoint)
    }
    
    func signup(type: SocialLogin) async throws {
        let endpoint = BookEndpoint.signup(type: type)
        try await apiClient.requestRaw(endpoint)
    }
    
    func reissueToken() async throws {
        let endpoint = BookEndpoint.reissueToken
        try await apiClient.requestRaw(endpoint)
    }
    
    // MARK: - Profile
    
    func getProfile() async throws -> ProfileResponse {
        let endpoint = BookEndpoint.getProfile
        return try await apiClient.request(endpoint, responseType: ProfileResponse.self)
    }
    
    func modifyProfile(nickname: String) async throws {
        let endpoint = BookEndpoint.modifyProfile(nickname: nickname)
        try await apiClient.requestRaw(endpoint)
    }
    
    func checkNickname(nickname: String) async throws -> Bool {
        let endpoint = BookEndpoint.checkNickname(nickname: nickname)
        let response = try await apiClient.request(endpoint, responseType: NicknameCheckResponse.self)
        // TODO: 실제 응답 구조에 맞게 수정
        return response.isAvailable
    }
    
    func withdrawal() async throws {
        let endpoint = BookEndpoint.withdrawal
        try await apiClient.requestRaw(endpoint)
    }
    
    // MARK: - Books
    
    func getBookList(keyword: String? = nil, page: Int? = nil, limit: Int? = nil) async throws -> BookListResponse {
        let endpoint = BookEndpoint.bookList(keyword: keyword, page: page, limit: limit)
        return try await apiClient.request(endpoint, responseType: BookListResponse.self)
    }
    
    func getBookDetail(bookId: Int) async throws -> BookDetailResponse {
        let endpoint = BookEndpoint.myBook(bookId: bookId)
        return try await apiClient.request(endpoint, responseType: BookDetailResponse.self)
    }
    
    func addBook(bookInfo: BookInfo, historyInfo: HistoryInfo? = nil, reason: String) async throws {
        let endpoint = BookEndpoint.addBook(bookInfo: bookInfo, historyInfo: historyInfo, reason: reason)
        try await apiClient.requestRaw(endpoint)
    }
    
    func deleteBook(bookId: Int) async throws {
        let endpoint = BookEndpoint.deleteBook(bookId: bookId)
        try await apiClient.requestRaw(endpoint)
    }
    
    func modifyBook(bookId: Int, modifyBook: ModifyBook) async throws {
        let endpoint = BookEndpoint.modifyMyBook(bookId: bookId, modifyBook: modifyBook)
        try await apiClient.requestRaw(endpoint)
    }
    
    func searchMyBook(query: String) async throws -> [Books] {
        let endpoint = BookEndpoint.searchMyBook(query: query)
        let response = try await apiClient.request(endpoint, responseType: SearchBooksResponse.self)
        // TODO: 실제 응답 구조에 맞게 수정
        return response.books
    }
    
    // MARK: - Reading
    
    func startReading(bookId: Int, startDate: String, finishDate: String? = nil) async throws {
        let bookDate = BookDate(startDate: startDate, finishedDate: finishDate)
        let endpoint = BookEndpoint.startRead(bookId: bookId, bookDate: bookDate)
        try await apiClient.requestRaw(endpoint)
    }
    
    func getHistory(bookId: Int, page: Int, limit: Int) async throws -> HistoryResponse {
        let endpoint = BookEndpoint.history(bookId: bookId, page: page, limit: limit)
        return try await apiClient.request(endpoint, responseType: HistoryResponse.self)
    }
}

// MARK: - Placeholder Response Models (실제 모델로 교체 필요)

struct ProfileResponse: Codable {
    // TODO: 실제 프로필 응답 구조
    let nickname: String
}

struct SearchBooksResponse: Codable {
    // TODO: 실제 검색 응답 구조
    let books: [Books]
}

struct HistoryResponse: Codable {
    // TODO: 실제 히스토리 응답 구조
}
