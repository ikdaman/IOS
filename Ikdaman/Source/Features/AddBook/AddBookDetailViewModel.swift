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
        isbn = book.bookInfo.isbn
        pageCount = String(book.bookInfo.totalPage)
        description = book.bookInfo.description ?? ""
    }

    // MARK: - Save
    func saveBook() async {
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
                publisher: publisher.isEmpty ? nil : publisher,
                totalPage: 100,
                publishDate: Date().toString(),
                coverImage: bookData?.bookInfo.coverImage ?? ""
            )
            let historyInfo = HistoryInfo(startedDate: nil, finishedDate: nil)
            try await repository.addBook(bookInfo: bookInfo, historyInfo: historyInfo, reason: "테스트")
            shouldDismiss = true
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
