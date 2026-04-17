import Foundation

@MainActor
final class HistoryViewModel: ObservableObject {

    // MARK: - Published

    @Published var displayMode: DisplayMode = .list
    @Published var historyItems: [HistoryBook] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var sortDescending: Bool = true   // true = 최신순, false = 오래된순

    // MARK: - Pagination

    private var currentPage: Int = 0
    private var isLastPage: Bool = false
    private let pageSize: Int = 20

    // MARK: - Dependencies

    private let repository: BookRepositoryProtocol

    init(repository: BookRepositoryProtocol = BookRepository()) {
        self.repository = repository
    }

    // MARK: - Public Methods

    func onAppear() async {
        await fetchHistory(refresh: true)
    }

    /// 히스토리 목록 조회
    func fetchHistory(refresh: Bool = false) async {
        guard !isLoading else { return }

        if refresh {
            currentPage = 0
            isLastPage = false
            historyItems = []
        }

        guard !isLastPage else { return }

        isLoading = true
        errorMessage = nil

        do {
            let response = try await repository.getHistory(page: currentPage, limit: pageSize)

            let newItems = response.books.map { item in
                HistoryBook(
                    start: item.startedDate,
                    finish: item.finishedDate ?? "",
                    title: item.bookInfo.title
                )
            }

            if sortDescending {
                historyItems.append(contentsOf: newItems)
            } else {
                historyItems.append(contentsOf: newItems.reversed())
            }

            isLastPage = response.nowPage >= response.totalPages - 1
            currentPage = response.nowPage + 1
        } catch {
            if let networkError = error as? NetworkError {
                errorMessage = networkError.errorDescription
            } else {
                errorMessage = error.localizedDescription
            }
            print("❌ HistoryViewModel Error: \(error)")
        }

        isLoading = false
    }

    /// 스크롤 끝에서 추가 로드
    func loadMore() {
        guard !isLastPage && !isLoading else { return }
        Task { await fetchHistory() }
    }

    /// 뷰 타입 전환 (리스트 ↔ 그리드)
    func toggleViewType() {
        displayMode = displayMode == .list ? .grid : .list
    }

    /// 정렬 방식 전환 (최신순 ↔ 오래된순)
    func toggleSort() {
        sortDescending.toggle()
        Task { await fetchHistory(refresh: true) }
    }
}
