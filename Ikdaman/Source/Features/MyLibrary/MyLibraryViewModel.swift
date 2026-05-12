import Foundation
import SwiftUI

// MARK: - Sort Type

enum BookSortType {
    case latest   // 최신순 (createdDate 내림차순)
    case oldest   // 오래된순 (createdDate 오름차순)
}

// MARK: - MyLibrary ViewModel

@MainActor
final class MyLibraryViewModel: ObservableObject {

    // MARK: - Published

    @Published var books: [Books] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var sortType: BookSortType = .latest
@Published var shouldNavigateToSettings: Bool = false

    // MARK: - Pagination

    private var currentPage: Int = 0
    private let pageSize: Int = 20
    private var isLastPage: Bool = false

    // MARK: - Dependencies

    private let repository: BookRepositoryProtocol

    init(repository: BookRepositoryProtocol = BookRepository()) {
        self.repository = repository
    }

    // MARK: - Public Methods

    func onAppear() async {
        guard AuthService.shared.isLogin else {
            books = []
            return
        }
        await fetchBookList(refresh: true)
    }

    /// 서재 책 목록 조회 (페이지네이션 지원)
    func fetchBookList(refresh: Bool = false) async {
        guard !isLoading else { return }

        if refresh {
            currentPage = 0
            isLastPage = false
            books = []
        }

        guard !isLastPage else { return }

        isLoading = true
        errorMessage = nil

        do {
            let sort = sortType == .latest ? "createdAt,desc" : "createdAt,asc"
            let response = try await repository.getBookList(
                keyword: nil,
                page: currentPage,
                limit: pageSize,
                sort: sort
            )

            let newBooks = response.books.map { Books(from: $0) }
            books.append(contentsOf: newBooks)

            isLastPage = response.nowPage >= response.totalPages - 1
            currentPage = response.nowPage + 1

            applySorting()
        } catch {
            handleError(error)
        }

        isLoading = false
    }

    /// 스크롤 끝에서 추가 로드
    func loadMore() async {
        await fetchBookList()
    }

    /// 독서 시작
    func startReading(bookId: Int, startDate: String? = nil, finishDate: String? = nil) async {
        isLoading = true
        errorMessage = nil

        let date = startDate ?? Date().toISO8601String()

        do {
            try await repository.startReading(bookId: bookId, startDate: date, finishDate: finishDate)
            ToastManager.shared.show("시작한 책은 히스토리에서 볼 수 있어요.")
        } catch {
            handleError(error)
        }

        isLoading = false
    }

    /// 책 삭제
    func deleteBook(bookId: Int) async {
        isLoading = true
        errorMessage = nil

        do {
            try await repository.deleteBook(bookId: bookId)
            books.removeAll { $0.myBookId == bookId }
            ToastManager.shared.show("책을 정리했어요!")
        } catch {
            handleError(error)
        }

        isLoading = false
    }

/// 정렬 방식 변경 → API 재호출
    func changeSortType(to newSort: BookSortType) {
        guard sortType != newSort else { return }
        sortType = newSort
        Task { await fetchBookList(refresh: true) }
    }

    /// 헤더 설정 버튼
    func headerButtonTapped() {
        shouldNavigateToSettings = true
    }

    // MARK: - Private Methods

    private func applySorting() {
        switch sortType {
        case .latest:
            books.sort { $0.createdDate > $1.createdDate }
        case .oldest:
            books.sort { $0.createdDate < $1.createdDate }
        }
    }

    private func handleError(_ error: Error) {
        if let networkError = error as? NetworkError {
            errorMessage = networkError.errorDescription
        } else {
            errorMessage = error.localizedDescription
        }
        print("❌ MyLibraryViewModel Error: \(error)")
    }
}
