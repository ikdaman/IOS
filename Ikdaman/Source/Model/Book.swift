import Foundation

struct Books: Codable, Identifiable {
    let id = UUID()
    let myBookId: Int
    let createdDate: String
    let reason: String
    let bookInfo: BookInfo

    // id는 로컬 UUID이므로 Codable에서 제외
    enum CodingKeys: String, CodingKey {
        case myBookId, createdDate, reason, bookInfo
    }
}

// MARK: - Factory Inits (서버 응답 → 표시 모델 변환)

extension Books {
    /// 서재 목록 응답 (GET /mybooks/store)
    init(from item: StoreBookItemResponse) {
        self.myBookId = item.mybookId
        self.createdDate = item.createdDate
        self.reason = item.reason ?? ""
        self.bookInfo = BookInfo(
            source: "",
            aladinId: 0,
            isbn: "",
            title: item.bookInfo.title,
            author: item.bookInfo.author.joined(separator: ", "),
            publisher: nil,
            description: item.bookInfo.description,
            totalPage: 0,
            publishDate: nil,
            coverImage: item.bookInfo.coverImage ?? "",
            link: nil
        )
    }

    /// 책 상세 응답 (GET /mybooks/{id})
    init(from detail: MyBookDetailResponse) {
        self.myBookId = Int(detail.mybookId) ?? 0
        self.createdDate = detail.createdDate
        self.reason = detail.reason ?? ""
        self.bookInfo = BookInfo(
            source: detail.bookInfo.source,
            aladinId: Int(detail.bookInfo.aladinId ?? "0") ?? 0,
            isbn: detail.bookInfo.isbn ?? "",
            title: detail.bookInfo.title,
            author: detail.bookInfo.author,
            publisher: detail.bookInfo.publisher,
            description: detail.bookInfo.description,
            totalPage: detail.bookInfo.totalPage ?? 0,
            publishDate: detail.bookInfo.publishDate,
            coverImage: detail.bookInfo.coverImage ?? "",
            link: nil
        )
    }

    /// 검색 결과 응답 (GET /mybooks?query=)
    init(from item: MyBookSearchItemResponse) {
        self.myBookId = item.mybookId
        self.createdDate = item.createdDate
        self.reason = ""
        self.bookInfo = BookInfo(
            source: "",
            aladinId: 0,
            isbn: "",
            title: item.bookInfo.title,
            author: item.bookInfo.author.joined(separator: ", "),
            publisher: nil,
            description: item.bookInfo.description,
            totalPage: 0,
            publishDate: nil,
            coverImage: item.bookInfo.coverImage ?? "",
            link: nil
        )
    }
}
