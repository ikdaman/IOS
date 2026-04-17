import Foundation

// MARK: - Book Repository Protocol

protocol BookRepositoryProtocol {
    // MARK: - Auth
    func login(type: SocialLogin) async throws -> LoginAPIResponse
    func login2(type: SocialLogin) async throws -> LoginAPIResponse
    func logout() async throws
    func signup(type: SocialLogin) async throws -> LoginAPIResponse
    func reissueToken() async throws

    // MARK: - Profile
    func getProfile() async throws -> MemberResponse
    func modifyProfile(nickname: String) async throws -> MemberResponse
    func checkNickname(nickname: String) async throws -> Bool
    func withdrawal() async throws

    // MARK: - Books
    func getBookList(keyword: String?, page: Int?, limit: Int?, sort: String?) async throws -> StoreBookResponse
    func getBookDetail(bookId: Int) async throws -> MyBookDetailResponse
    func addBook(bookInfo: BookInfo, historyInfo: HistoryInfo?, reason: String) async throws
    func deleteBook(bookId: Int) async throws
    func modifyBook(bookId: Int, modifyBook: ModifyBook) async throws
    func searchMyBook(query: String) async throws -> MyBookSearchResponse

    // MARK: - Reading
    func startReading(bookId: Int, startDate: String, finishDate: String?) async throws
    func getHistory(page: Int, limit: Int) async throws -> HistoryPageResponse
}

// MARK: - Book Repository

@MainActor
final class BookRepository: BookRepositoryProtocol {
    private let apiClient: APIClient

    nonisolated init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    // MARK: - Auth

    func login(type: SocialLogin) async throws -> LoginAPIResponse {
        try await apiClient.request(BookEndpoint.login(type: type), responseType: LoginAPIResponse.self)
    }

    func login2(type: SocialLogin) async throws -> LoginAPIResponse {
        try await apiClient.request(BookEndpoint.login2(type: type), responseType: LoginAPIResponse.self)
    }

    func logout() async throws {
        try await apiClient.requestRaw(BookEndpoint.logout)
    }

    func signup(type: SocialLogin) async throws -> LoginAPIResponse {
        try await apiClient.request(BookEndpoint.signup(type: type), responseType: LoginAPIResponse.self)
    }

    func reissueToken() async throws {
        try await apiClient.requestRaw(BookEndpoint.reissueToken)
    }

    // MARK: - Profile

    func getProfile() async throws -> MemberResponse {
        try await apiClient.request(BookEndpoint.getProfile, responseType: MemberResponse.self)
    }

    func modifyProfile(nickname: String) async throws -> MemberResponse {
        try await apiClient.request(BookEndpoint.modifyProfile(nickname: nickname), responseType: MemberResponse.self)
    }

    func checkNickname(nickname: String) async throws -> Bool {
        let response = try await apiClient.request(
            BookEndpoint.checkNickname(nickname: nickname),
            responseType: NicknameAvailableResponse.self
        )
        return response.available
    }

    func withdrawal() async throws {
        try await apiClient.requestRaw(BookEndpoint.withdrawal)
    }

    // MARK: - Books

    func getBookList(keyword: String? = nil, page: Int? = nil, limit: Int? = nil, sort: String? = nil) async throws -> StoreBookResponse {
        try await apiClient.request(
            BookEndpoint.bookList(keyword: keyword, page: page, limit: limit, sort: sort),
            responseType: StoreBookResponse.self
        )
    }

    func getBookDetail(bookId: Int) async throws -> MyBookDetailResponse {
        try await apiClient.request(
            BookEndpoint.myBook(bookId: bookId),
            responseType: MyBookDetailResponse.self
        )
    }

    func addBook(bookInfo: BookInfo, historyInfo: HistoryInfo? = nil, reason: String) async throws {
        try await apiClient.requestRaw(
            BookEndpoint.addBook(bookInfo: bookInfo, historyInfo: historyInfo, reason: reason)
        )
    }

    func deleteBook(bookId: Int) async throws {
        try await apiClient.requestRaw(BookEndpoint.deleteBook(bookId: bookId))
    }

    func modifyBook(bookId: Int, modifyBook: ModifyBook) async throws {
        try await apiClient.requestRaw(
            BookEndpoint.modifyMyBook(bookId: bookId, modifyBook: modifyBook)
        )
    }

    func searchMyBook(query: String) async throws -> MyBookSearchResponse {
        try await apiClient.request(
            BookEndpoint.searchMyBook(query: query),
            responseType: MyBookSearchResponse.self
        )
    }

    // MARK: - Reading

    func startReading(bookId: Int, startDate: String, finishDate: String? = nil) async throws {
        let bookDate = BookDate(startDate: startDate, finishedDate: finishDate)
        try await apiClient.requestRaw(BookEndpoint.startRead(bookId: bookId, bookDate: bookDate))
    }

    func getHistory(page: Int, limit: Int) async throws -> HistoryPageResponse {
        try await apiClient.request(
            BookEndpoint.history(page: page, limit: limit),
            responseType: HistoryPageResponse.self
        )
    }
}
