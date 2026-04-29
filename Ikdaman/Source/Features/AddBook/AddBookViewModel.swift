import Foundation
import SwiftUI

@MainActor
class AddBookViewModel: ObservableObject {
    @Published var searchResults: [Books] = []
    @Published var isSearching = false
    @Published var errorMessage: String?
    
    private let apiService = AladinAPIService()
    private var searchTask: Task<Void, Never>?
    
    /// 도서 검색
    /// - Parameter query: 검색어
    func searchBooks(query: String) {
        // 이전 검색 작업 취소
        searchTask?.cancel()
        
        // 빈 검색어는 결과 초기화
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            searchResults = []
            return
        }
        
        searchTask = Task {
            isSearching = true
            errorMessage = nil
            
            do {
                // 디바운싱: 0.5초 대기
                try await Task.sleep(nanoseconds: 500_000_000)
                
                // Task가 취소되었는지 확인
                if Task.isCancelled { return }
                
                let response = try await apiService.searchBooks(
                    query: query,
                    page: 1,
                    maxResults: 20
                )
                
                if Task.isCancelled { return }
                
                // AladinBook을 Books로 변환
                searchResults = response.item.map { convertToBooks(from: $0) }
                isSearching = false
                
                print("✅ 검색 완료: \(searchResults.count)개 결과")
                
            } catch is CancellationError {
                // 취소된 경우 무시
                print("🔄 검색 취소됨")
            } catch {
                isSearching = false
                errorMessage = "검색 중 오류가 발생했습니다."
                print("❌ 검색 오류: \(error)")
            }
        }
    }
    
    /// 알라딘 API 응답을 Books 모델로 변환
    private func convertToBooks(from aladinBook: AladinBook) -> Books {
        return Books(
            myBookId: aladinBook.itemId,
            createdDate: ISO8601DateFormatter().string(from: Date()),
            reason: "",
            bookInfo: BookInfo(
                source: "ALADIN",
                aladinId: aladinBook.itemId,           // Int?
                isbn: [aladinBook.isbn13, aladinBook.isbn].compactMap { $0 }.first { !$0.isEmpty }, // String?
                title: aladinBook.title,
                author: aladinBook.author,
                publisher: aladinBook.publisher,       // String (required)
                description: aladinBook.description,
                totalPage: Int(aladinBook.subInfo?.itemPage ?? 0),
                publishDate: aladinBook.pubDate,       // "yyyy-MM-dd" → saveBook에서 변환
                coverImage: aladinBook.cover,          // String?
                link: aladinBook.link
            )
        )
    }
    
    /// ISBN으로 도서 상세 정보 조회
    func loadBookDetail(isbn: String) async -> Books? {
        do {
            let aladinBook = try await apiService.getBook(isbn: isbn)
            return convertToBooks(from: aladinBook)
        } catch {
            errorMessage = "도서 정보를 불러올 수 없습니다."
            print("❌ 도서 상세 조회 오류: \(error)")
            return nil
        }
    }
    
    /// 검색 결과 초기화
    func clearResults() {
        searchTask?.cancel()
        searchResults = []
        errorMessage = nil
    }
}
