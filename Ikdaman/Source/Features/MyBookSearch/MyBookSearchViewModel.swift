import Foundation

@MainActor
final class MyBookSearchViewModel: ObservableObject {

    @Published var query: String = ""
    @Published var results: [MyBookSearchItemResponse] = []
    @Published var isLoading: Bool = false

    private let repository: BookRepositoryProtocol

    init(repository: BookRepositoryProtocol = BookRepository()) {
        self.repository = repository
    }

    func search() async {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            results = []
            return
        }
        isLoading = true
        do {
            let response = try await repository.searchMyBook(query: trimmed)
            results = response.books
        } catch {
            print("❌ MyBookSearchViewModel: \(error)")
        }
        isLoading = false
    }

    func statusLabel(_ status: String) -> String {
        switch status.uppercased() {
        case let s where s.contains("WISH"):   return "읽고 싶은 책"
        case let s where s.contains("READING"): return "읽는 중"
        case let s where s.contains("COMPLET"): return "완독"
        default: return status
        }
    }
}
