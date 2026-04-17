import Foundation

struct SocialLogin: Codable {
    var provider: String
    var providerId: String
    var socialToken: String
    var nickname: String?
}

// MARK: - 책 수정 요청 (PATCH /mybooks/{id})

struct ModifyBook: Encodable {
    var shelfType: String?
    var reason: String?
    var historyInfo: HistoryInfo?
    var bookInfo: BookInfoRequest?
}

struct BookInfoRequest: Encodable {
    var title: String?
    var author: String?
    var publisher: String?
    var publishDate: String?
    var isbn: String?
    var totalPage: Int?

    enum CodingKeys: String, CodingKey {
        case title, author, publisher, publishDate, totalPage
        case isbn = "ISBN"
    }
}

// MARK: - 공통 모델

struct HistoryInfo: Codable {
    var startedDate: String?
    var finishedDate: String?
}

struct BookInfo: Codable {
    var source: String
    var aladinId: Int
    var isbn: String
    var title: String
    var author: String
    var publisher: String?
    var description: String?
    var totalPage: Int
    var publishDate: String?   // ISO8601 문자열 (Date? → String? 변경)
    var coverImage: String
    var link: String?
}
