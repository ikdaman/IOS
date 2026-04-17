import Foundation

// MARK: - Auth

struct LoginAPIResponse: Decodable {
    let authorization: String?
    let refreshToken: String?
    let nickname: String?
}

// MARK: - Member

struct MemberResponse: Decodable {
    let nickname: String
}

struct NicknameAvailableResponse: Decodable {
    let available: Bool
}

// MARK: - MyBook Detail (GET /mybooks/{id})

struct MyBookDetailResponse: Decodable {
    let mybookId: String
    let readingStatus: String
    let shelfType: String
    let createdDate: String
    let reason: String?
    let bookInfo: BookInfoDetailResponse
    let historyInfo: HistoryInfoDetailResponse
}

struct BookInfoDetailResponse: Decodable {
    let bookId: String
    let source: String
    let title: String
    let author: String
    let coverImage: String?
    let publisher: String?
    let totalPage: Int?
    let publishDate: String?
    let isbn: String?
    let aladinId: String?
    let description: String?
}

struct HistoryInfoDetailResponse: Decodable {
    let startedDate: String?
    let finishedDate: String?
}

// MARK: - Store Book List (GET /mybooks/store)

struct StoreBookResponse: Decodable {
    let books: [StoreBookItemResponse]
    let totalPages: Int
    let nowPage: Int
    let totalElements: Int
}

struct StoreBookItemResponse: Decodable {
    let mybookId: Int
    let createdDate: String
    let bookInfo: SearchBookInfoResponse
    let reason: String?
}

struct SearchBookInfoResponse: Decodable {
    let title: String
    let author: [String]
    let coverImage: String?
    let description: String?
}

// MARK: - MyBook Search (GET /mybooks?query=)

struct MyBookSearchResponse: Decodable {
    let totalPages: Int
    let nowPage: Int
    let totalElements: Int
    let books: [MyBookSearchItemResponse]
}

struct MyBookSearchItemResponse: Decodable {
    let mybookId: Int
    let readingStatus: String
    let createdDate: String
    let startedDate: String?
    let finishedDate: String?
    let bookInfo: SearchBookInfoResponse
}

// MARK: - MyBook ID (POST /mybooks 응답)

struct MyBookIdResponse: Decodable {
    let mybookId: Int
}

// MARK: - History (GET /mybooks/history)

struct HistoryPageResponse: Decodable {
    let totalPages: Int
    let nowPage: Int
    let books: [HistoryBookItem]
}

struct HistoryBookItem: Decodable {
    let mybookId: Int
    let startedDate: String
    let finishedDate: String?
    let bookInfo: HistoryBookInfoItem
}

struct HistoryBookInfoItem: Decodable {
    let title: String
    let author: [String]?
    let coverImage: String?
    let description: String?
}
