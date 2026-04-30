import Foundation

@MainActor
final class BookDetailViewModel: ObservableObject {

    // MARK: - Published

    @Published var book: Books
    @Published var readingStatus: String = ""
    @Published var shelfType: String = ""
    @Published var savedDate: String = ""
    @Published var startedDate: String = ""
    @Published var finishedDate: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var shouldDismiss: Bool = false

    // MARK: - Dependencies

    private let repository: BookRepositoryProtocol

    init(book: Books, repository: BookRepositoryProtocol = BookRepository()) {
        self.book = book
        self.repository = repository
    }

    // MARK: - Public Methods

    func onAppear() async {
        await fetchDetail()
    }

    /// 책 상세 정보 조회 (readingStatus, historyInfo 등 포함)
    func fetchDetail() async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await repository.getBookDetail(bookId: book.myBookId)
            book = Books(from: response)
            readingStatus = response.readingStatus
            shelfType = response.shelfType
            savedDate = formatDate(response.createdDate)
            startedDate = formatDate(response.historyInfo.startedDate ?? "")
            finishedDate = formatDate(response.historyInfo.finishedDate ?? "")
        } catch {
            handleError(error)
        }

        isLoading = false
    }

    /// 책 삭제
    func deleteBook() async {
        isLoading = true
        errorMessage = nil

        do {
            try await repository.deleteBook(bookId: book.myBookId)
            shouldDismiss = true
        } catch {
            handleError(error)
        }

        isLoading = false
    }

    /// 독서 이력 수정 (startedDate, finishedDate)
    func updateReadingHistory(startedDate: String?, finishedDate: String?) async {
        isLoading = true
        errorMessage = nil

        do {
            let modify = ModifyBook(
                shelfType: nil,
                reason: nil,
                historyInfo: HistoryInfo(startedDate: startedDate, finishedDate: finishedDate),
                bookInfo: nil
            )
            try await repository.modifyBook(bookId: book.myBookId, modifyBook: modify)
            await fetchDetail()
        } catch {
            handleError(error)
        }

        isLoading = false
    }

    /// 읽고 싶은 이유 수정
    func updateReason(_ reason: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let modify = ModifyBook(
                shelfType: nil,
                reason: reason,
                historyInfo: nil,
                bookInfo: nil
            )
            try await repository.modifyBook(bookId: book.myBookId, modifyBook: modify)
            await fetchDetail()
        } catch {
            handleError(error)
        }

        isLoading = false
    }

    // MARK: - Private

    private func formatDate(_ raw: String) -> String {
        guard !raw.isEmpty else { return "" }
        let input = DateFormatter()
        input.locale = Locale(identifier: "en_US_POSIX")
        let output = DateFormatter()
        output.dateFormat = "yyyy - MM - dd"
        for fmt in ["yyyy-MM-dd'T'HH:mm:ss.SSSSSS", "yyyy-MM-dd'T'HH:mm:ss", "yyyy-MM-dd"] {
            input.dateFormat = fmt
            if let date = input.date(from: raw) { return output.string(from: date) }
        }
        return raw
    }

    private func handleError(_ error: Error) {
        if let networkError = error as? NetworkError {
            errorMessage = networkError.errorDescription
        } else {
            errorMessage = error.localizedDescription
        }
        print("❌ BookDetailViewModel Error: \(error)")
    }
}
