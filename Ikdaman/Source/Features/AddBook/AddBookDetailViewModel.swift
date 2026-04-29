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
            // publishDate: aladin pubDate 값을 "yyyy-MM-dd" 형식 그대로 전송
            let resolvedPublishDate = publishDate.isEmpty
                ? Date().toDateOnlyString()
                : publishDate

            let bookInfo = BookInfo(
                source: bookData != nil ? "ALADIN" : "CUSTOM",
                aladinId: bookData?.bookInfo.aladinId,
                isbn: isbn.isEmpty ? nil : isbn,
                title: title,
                author: author,
                publisher: publisher,
                description: description.isEmpty ? nil : description,
                totalPage: Int(pageCount) ?? bookData?.bookInfo.totalPage ?? 0,
                publishDate: resolvedPublishDate,
                coverImage: bookData?.bookInfo.coverImage,
                link: bookData?.bookInfo.link
            )
            try await repository.addBook(bookInfo: bookInfo, historyInfo: nil, reason: nil)
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
    /// ISO8601 UTC "yyyy-MM-dd'T'HH:mm:ss'Z'" 형식
    func toISO8601String() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: self)
    }
}

extension String {
    /// "yyyy-MM-dd" 형식 여부 확인
    func isYearMonthDayFormat() -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: self) != nil
    }
}

extension Date {
    /// "오늘 날짜"를 "yyyy-MM-dd" 형식으로 반환 (publishDate fallback용)
    func toDateOnlyString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: self)
    }
}
