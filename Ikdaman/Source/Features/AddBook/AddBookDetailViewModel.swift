//
//  AddBookDetailViewModel.swift
//  Ikdaman
//
//  Created by Soo on 3/27/26.
//

import Foundation

@MainActor
final class AddBookDetailViewModel: ObservableObject {
    // MARK: - Form State
    @Published var title: String = ""
    @Published var author: String = ""
    @Published var publisher: String = ""
    @Published var publishDate: String = ""
    @Published var isbn: String = ""
    @Published var pageCount: String = ""
    @Published var description: String = ""

    // MARK: - UI State
    @Published var isManualEntry: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var shouldDismiss: Bool = false
    @Published var showAddPopup: Bool = false
    @Published var showDuplicatePopup: Bool = false

    let bookData: Books?
    private let repository: BookRepositoryProtocol

    init(bookData: Books? = nil, repository: BookRepositoryProtocol = BookRepository()) {
        self.bookData = bookData
        self.repository = repository
        loadBookData()
    }

    var isValid: Bool {
        !title.isEmpty && !author.isEmpty
    }

    // MARK: - Load Data
    private func loadBookData() {
        guard let book = bookData else {
            isManualEntry = true
            return
        }
        isManualEntry = false
        title = book.bookInfo.title
        author = book.bookInfo.author
        publisher = book.bookInfo.publisher ?? ""
        publishDate = book.bookInfo.publishDate ?? ""
        isbn = book.bookInfo.isbn ?? ""
        pageCount = book.bookInfo.totalPage == 0 ? "" : String(book.bookInfo.totalPage)
        description = book.bookInfo.description ?? ""
        
        // 검색 결과(ItemSearch)에는 totalPage가 없으므로 ISBN으로 상세 정보(ItemLookUp)를 비동기로 조회하여 보완
        if book.bookInfo.totalPage == 0, let validIsbn = book.bookInfo.isbn, !validIsbn.isEmpty {
            Task {
                do {
                    let apiService = AladinAPIService()
                    let aladinBook = try await apiService.getBook(isbn: validIsbn)
                    if let itemPage = aladinBook.subInfo?.itemPage, itemPage > 0 {
                        self.pageCount = String(itemPage)
                    }
                } catch {
                    print("❌ 추가 도서 상세 정보(totalPage) 조회 실패: \(error)")
                }
            }
        }
    }

    // MARK: - Save
    func saveBook(reason: String, startDate: String? = nil, finishDate: String? = nil) async {
        guard isValid else {
            errorMessage = "제목과 작가는 필수 입력 항목입니다."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let bookInfo = BookInfo(
                source: "ALADIN",
                aladinId: bookData?.bookInfo.aladinId ?? 0,
                isbn: isbn,
                title: title,
                author: author,
                publisher: publisher,
                totalPage: Int(pageCount) ?? bookData?.bookInfo.totalPage ?? 0,
                publishDate: Date().toString(),
                coverImage: bookData?.bookInfo.coverImage ?? ""
            )
            let historyInfo = HistoryInfo(startedDate: startDate, finishedDate: finishDate)
            try await repository.addBook(bookInfo: bookInfo, historyInfo: historyInfo, reason: reason)
            shouldDismiss = true
        } catch NetworkError.httpError(statusCode: 409) {
            showAddPopup = false
            showDuplicatePopup = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

extension Date {
    func toISO8601String() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: self)
    }

    /// "yyyy-MM-dd'T'HH:mm:ss'Z'" 형식 (서버 전송용)
    func toString() -> String {
        toISO8601String()
    }
}
