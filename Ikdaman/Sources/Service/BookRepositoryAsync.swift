//
//  BookRepositoryAsync.swift
//  Ikdaman
//
//  Created by Soo on 1/7/26.
//

import Foundation

// MARK: - Protocol
protocol BookRepositoryAsync {
    // 책 관련
    func fetchBookList(status: String?, keyword: String?, page: Int?, limit: Int?) async throws -> MyBook
    func fetchBook(bookId: Int) async throws -> Book
    func addBook(book: AddMyBook) async throws
    func deleteBook(bookId: Int) async throws
    func fetchReadingBooks() async throws -> [Book]
    
    // 책 기록 관련
    func fetchBookHistory(bookId: Int, page: Int, limit: Int) async throws -> [BookLog]
    func addThink(bookId: Int, content: String, page: Int, createdAt: Date) async throws
    func modifyThink(bookId: Int, bookLogId: Int, content: String) async throws
    func deleteThink(bookId: Int, bookLogId: Int) async throws
    func addCompleteRead(bookId: Int, review: String, createdAt: Date) async throws
    func deleteCompleteRead(bookId: Int, bookLogId: Int) async throws
    func modifyCompleteRead(bookId: Int, bookLogId: Int) async throws
    func addFirstImpression(bookId: Int, impression: String, createdAt: Date) async throws
    
    // 프로필 관련
    func fetchProfile() async throws -> Profile
    func modifyProfile(user: User) async throws
    func checkNickname(nickname: String) async throws -> Bool
    func withdrawal() async throws
    
    // 공지사항
    func fetchNoticeList(page: Int, limit: Int) async throws -> [Notice]
    func fetchNoticeDetail(noticeId: Int) async throws -> NoticeDetail
}

// MARK: - Implementation
final class BookRepositoryAsyncImpl: BookRepositoryAsync {
    private let apiClient = APIClient.shared
    
    // MARK: - 책 관련
    
    func fetchBookList(status: String?, keyword: String?, page: Int?, limit: Int?) async throws -> MyBook {
        return try await apiClient.request(
            BookEndpoint.bookList(status: status, keyword: keyword, page: page, limit: limit),
            responseType: MyBook.self
        )
    }
    
    func fetchBook(bookId: Int) async throws -> Book {
        return try await apiClient.request(
            BookEndpoint.book(bookId: bookId),
            responseType: Book.self
        )
    }
    
    func addBook(book: AddMyBook) async throws {
        try await apiClient.requestRaw(BookEndpoint.addBook(book: book))
    }
    
    func deleteBook(bookId: Int) async throws {
        try await apiClient.requestRaw(BookEndpoint.deleteBook(bookId: bookId))
    }
    
    func fetchReadingBooks() async throws -> [Book] {
        return try await apiClient.request(
            BookEndpoint.bookListReading,
            responseType: [Book].self
        )
    }
    
    // MARK: - 책 기록 관련
    
    func fetchBookHistory(bookId: Int, page: Int, limit: Int) async throws -> [BookLog] {
        return try await apiClient.request(
            BookEndpoint.bookHistory(bookId: bookId, page: page, limit: limit),
            responseType: [BookLog].self
        )
    }
    
    func addThink(bookId: Int, content: String, page: Int, createdAt: Date) async throws {
        try await apiClient.requestRaw(
            BookEndpoint.addThink(bookId: bookId, content: content, page: page, createdAt: createdAt)
        )
    }
    
    func modifyThink(bookId: Int, bookLogId: Int, content: String) async throws {
        try await apiClient.requestRaw(
            BookEndpoint.modifyThink(bookId: bookId, content: content, bookLogId: bookLogId)
        )
    }
    
    func deleteThink(bookId: Int, bookLogId: Int) async throws {
        try await apiClient.requestRaw(
            BookEndpoint.deleteThink(bookId: bookId, bookLogId: bookLogId)
        )
    }
    
    func addCompleteRead(bookId: Int, review: String, createdAt: Date) async throws {
        try await apiClient.requestRaw(
            BookEndpoint.addCompleteRead(bookId: bookId, review: review, createdAt: createdAt)
        )
    }
    
    func deleteCompleteRead(bookId: Int, bookLogId: Int) async throws {
        try await apiClient.requestRaw(
            BookEndpoint.deleteCompleteRead(bookId: bookId, bookLogId: bookLogId)
        )
    }
    
    func modifyCompleteRead(bookId: Int, bookLogId: Int) async throws {
        try await apiClient.requestRaw(
            BookEndpoint.modifyCompleteRead(bookId: bookId, bookLogId: bookLogId)
        )
    }
    
    func addFirstImpression(bookId: Int, impression: String, createdAt: Date) async throws {
        try await apiClient.requestRaw(
            BookEndpoint.firstImpression(bookId: bookId, impression: impression, createdAt: createdAt)
        )
    }
    
    // MARK: - 프로필 관련
    
    func fetchProfile() async throws -> Profile {
        return try await apiClient.request(
            BookEndpoint.getProfile,
            responseType: Profile.self
        )
    }
    
    func modifyProfile(user: User) async throws {
        try await apiClient.requestRaw(BookEndpoint.modifyProfile(user: user))
    }
    
    func checkNickname(nickname: String) async throws -> Bool {
        // 서버 응답에 따라 수정 필요
        struct NicknameResponse: Codable {
            let available: Bool
        }
        
        let response = try await apiClient.request(
            BookEndpoint.checkNickname(nickName: nickname),
            responseType: NicknameResponse.self
        )
        return response.available
    }
    
    func withdrawal() async throws {
        try await apiClient.requestRaw(BookEndpoint.withdrawal)
    }
    
    // MARK: - 공지사항
    
    func fetchNoticeList(page: Int, limit: Int) async throws -> [Notice] {
        return try await apiClient.request(
            BookEndpoint.noticeList(page: page, limit: limit),
            responseType: [Notice].self
        )
    }
    
    func fetchNoticeDetail(noticeId: Int) async throws -> NoticeDetail {
        return try await apiClient.request(
            BookEndpoint.noticeDetail(noticeId: noticeId),
            responseType: NoticeDetail.self
        )
    }
}

