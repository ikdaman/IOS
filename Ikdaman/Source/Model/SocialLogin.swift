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
    var source: String       // "ALADIN" or "CUSTOM"
    var aladinId: Int?       // Optional: 직접 추가인 경우 nil
    var isbn: String?        // Optional: 직접 추가인 경우 nil
    var title: String
    var author: String
    var publisher: String    // Necessary
    var description: String?
    var totalPage: Int
    var publishDate: String  // "yyyy-MM-dd" 형식
    var coverImage: String?  // Optional: 직접 추가인 경우 nil
    var link: String?        // 로컴 UI 표시용 - 서버 전송 제외

    // link는 서버 스펙에 없는 필드이므로 Encoding 시 제외
    enum CodingKeys: String, CodingKey {
        case source, aladinId, isbn, title, author, publisher
        case description, totalPage, publishDate, coverImage
        // link 제외 → JSON Body에 포함되지 않음
    }
}
