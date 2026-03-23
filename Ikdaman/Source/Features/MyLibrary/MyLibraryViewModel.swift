//
//  MyLibraryViewModel.swift
//  Ikdaman
//
//  Created by Soo on 3/16/26.
//

import Foundation
import SwiftUI

// MARK: - Sort Type
enum BookSortType {
    case latest      // 최신순
    case oldest      // 오래된 순
}

// MARK: - MyLibrary ViewModel
@MainActor
final class MyLibraryViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var books: [Books] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var sortType: BookSortType = .latest
    @Published var selectedBook: Books?
    @Published var showBookDetail: Bool = false
    @Published var showSettings: Bool = false
    
    // MARK: - Private Properties
    private let repository: BookRepositoryProtocol
    private var currentPage: Int = 1
    private let pageLimit: Int = 20
    private var hasMorePages: Bool = true
    
    // MARK: - Initialization
    init(repository: BookRepositoryProtocol = BookRepository()) {
        self.repository = repository
    }
    
    // MARK: - Public Methods
    
    /// 내 서점 책 목록 조회
    func fetchBookList(status: String? = nil, keyword: String? = nil, refresh: Bool = false) async {
        guard !isLoading else { return }
        
        if refresh {
            currentPage = 1
            hasMorePages = true
            books = []
        }
        
        guard hasMorePages else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await repository.getBookList(
                keyword: keyword,
                page: currentPage,
                limit: pageLimit
            )
            
            // TODO: Response에서 실제 데이터 추출
            let newBooks = response.books
             books.append(contentsOf: newBooks)
            
            // TODO: 페이지네이션 처리
            // hasMorePages = response.data.hasNext
            // currentPage += 1
            
            // 정렬 적용
            applySorting()
            
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    /// 독서 시작
    func startReading(bookId: Int, startDate: String, finishDate: String? = nil) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await repository.startReading(
                bookId: bookId,
                startDate: startDate,
                finishDate: finishDate
            )
            
            // 성공 후 목록 새로고침
            await fetchBookList(refresh: true)
            
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    /// 나의 책 삭제
    func deleteBook(bookId: Int) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await repository.deleteBook(bookId: bookId)
            
            // 로컬에서 삭제
            books.removeAll { $0.myBookId == bookId }
            
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    /// 나의 책 상세 조회
    func fetchBookDetail(bookId: Int) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await repository.getBookDetail(bookId: bookId)
            
            // TODO: Response에서 실제 데이터 추출
//             selectedBook = response.data
            
            showBookDetail = true
            
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    /// 설정 버튼 누르기
    func openSettings() {
        showSettings = true
    }
    
    /// 정렬 방식 변경
    func changeSortType(to sortType: BookSortType) {
        self.sortType = sortType
        applySorting()
    }
    
    /// 해당 책 보기
    func viewBookDetail(_ book: Books) {
        Task {
            await fetchBookDetail(bookId: book.myBookId)
        }
    }
    
    // MARK: - Private Methods
    
    /// 정렬 적용
    private func applySorting() {
//        switch sortType {
//        case .latest:
//            // TODO: 실제 날짜 필드로 변경
//            books.sort { $0.book.createdDate > $1.book.createdDate }
////            books.sort { $0.id > $1.id }
//        case .oldest:
//            // TODO: 실제 날짜 필드로 변경
//             books.sort { $0.createdAt < $1.createdAt }
////            books.sort { $0.id < $1.id }
//        }
    }
    
    /// 에러 처리
    private func handleError(_ error: Error) {
        if let networkError = error as? NetworkError {
            errorMessage = networkError.errorDescription
        } else {
            errorMessage = error.localizedDescription
        }
        print("❌ MyLibraryViewModel Error: \(error)")
    }
}


/// TODO: 실제 BookList Response 모델로 교체
struct BookListResponse: Codable {
    var totalPages: Int
    var nowPage: Int
    var totalElements: Int
    var books: [Books]
}

/// TODO: 실제 BookDetail Response 모델로 교체
struct BookDetailResponse: Codable {
    // TODO: 실제 응답 구조에 맞게 수정
}

/// 독서 날짜
struct BookDate: Codable {
    let startDate: String
    let finishedDate: String?
}

