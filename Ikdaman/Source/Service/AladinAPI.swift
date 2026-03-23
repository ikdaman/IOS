import Foundation

// MARK: - Response Models
struct BookSearchResponse: Decodable {
    let item: [AladinBook]
    let totalResults: Int
}

struct AladinBook: Decodable {
    let title: String
    let link: String
    let author: String
    let publisher: String
    let pubDate: String
    let cover: String
    let isbn: String
    let itemId: Int
    let priceStandard: Int
    let description: String?
    let subInfo: AladinBookSubInfo?
}

extension AladinBook {
    static let empty = AladinBook(
        title: "",
        link: "",
        author: "",
        publisher: "",
        pubDate: "",
        cover: "",
        isbn: "",
        itemId: 0,
        priceStandard: 0,
        description: nil,
        subInfo: nil
    )
}

struct AladinBookItem: Decodable {
    let subInfo: AladinBookSubInfo
}

struct AladinBookSubInfo: Decodable {
    let itemPage: Int?
}

extension AladinBookSubInfo {
    static let empty = AladinBookSubInfo(itemPage: 0)
}

// MARK: - API Error
enum AladinAPIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "잘못된 URL입니다."
        case .invalidResponse:
            return "서버 응답이 올바르지 않습니다."
        case .httpError(let statusCode):
            return "HTTP 오류: \(statusCode)"
        case .decodingError(let error):
            return "데이터 파싱 오류: \(error.localizedDescription)"
        case .networkError(let error):
            return "네트워크 오류: \(error.localizedDescription)"
        }
    }
}

// MARK: - Aladin API Service
actor AladinAPIService {
    private let baseURL = "https://www.aladin.co.kr/ttb/api"
    private let apiKey = "ttbgju060611831003"
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    // MARK: - Search Books
    /// 도서 검색
    /// - Parameters:
    ///   - query: 검색어
    ///   - page: 페이지 번호 (기본값: 1)
    ///   - maxResults: 최대 결과 수 (기본값: 10)
    /// - Returns: BookSearchResponse
    func searchBooks(
        query: String,
        page: Int = 1,
        maxResults: Int = 10
    ) async throws -> BookSearchResponse {
        let endpoint = "\(baseURL)/ItemSearch.aspx"
        
        var components = URLComponents(string: endpoint)
        components?.queryItems = [
            URLQueryItem(name: "ttbkey", value: apiKey),
            URLQueryItem(name: "Query", value: query),
            URLQueryItem(name: "QueryType", value: "Title"),
            URLQueryItem(name: "MaxResults", value: "\(maxResults)"),
            URLQueryItem(name: "start", value: "\(page)"),
            URLQueryItem(name: "SearchTarget", value: "Book"),
            URLQueryItem(name: "output", value: "js"),
            URLQueryItem(name: "Version", value: "20131101")
        ]
        
        guard let url = components?.url else {
            throw AladinAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("📤 [GET] \(url.absoluteString)")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AladinAPIError.invalidResponse
            }
            
            print("📥 [Response] Status: \(httpResponse.statusCode)")
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw AladinAPIError.httpError(statusCode: httpResponse.statusCode)
            }
            
            // 응답 데이터 디버깅 (필요시)
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📋 Response: \(jsonString.prefix(200))...")
            }
            
            let decoder = JSONDecoder()
            do {
                let result = try decoder.decode(BookSearchResponse.self, from: data)
                return result
            } catch {
                throw AladinAPIError.decodingError(error)
            }
        } catch let error as AladinAPIError {
            throw error
        } catch {
            throw AladinAPIError.networkError(error)
        }
    }
    
    // MARK: - Get Book Detail
    /// 도서 상세 정보 조회
    /// - Parameter isbn: ISBN 번호
    /// - Returns: AladinBook
    func getBook(isbn: String) async throws -> AladinBook {
        let endpoint = "\(baseURL)/ItemLookUp.aspx"
        
        var components = URLComponents(string: endpoint)
        components?.queryItems = [
            URLQueryItem(name: "ttbkey", value: apiKey),
            URLQueryItem(name: "itemIdType", value: "ISBN"),
            URLQueryItem(name: "ItemId", value: isbn),
            URLQueryItem(name: "output", value: "js"),
            URLQueryItem(name: "Version", value: "20131101"),
            URLQueryItem(name: "OptResult", value: "ebookList,usedList,reviewList")
        ]
        
        guard let url = components?.url else {
            throw AladinAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("📤 [GET] \(url.absoluteString)")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AladinAPIError.invalidResponse
            }
            
            print("📥 [Response] Status: \(httpResponse.statusCode)")
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw AladinAPIError.httpError(statusCode: httpResponse.statusCode)
            }
            
            // 응답 데이터 디버깅 (필요시)
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📋 Response: \(jsonString.prefix(200))...")
            }
            
            let decoder = JSONDecoder()
            
            // 응답이 배열로 오는 경우 처리
            struct BookDetailResponse: Decodable {
                let item: [AladinBook]
            }
            
            do {
                let result = try decoder.decode(BookDetailResponse.self, from: data)
                guard let book = result.item.first else {
                    throw AladinAPIError.invalidResponse
                }
                return book
            } catch {
                throw AladinAPIError.decodingError(error)
            }
        } catch let error as AladinAPIError {
            throw error
        } catch {
            throw AladinAPIError.networkError(error)
        }
    }
}

// MARK: - Usage Example
/*
 
 // ViewModel 또는 Service에서 사용 예시
 
 class BookSearchViewModel: ObservableObject {
     @Published var books: [AladinBook] = []
     @Published var isLoading = false
     @Published var errorMessage: String?
     
     private let apiService = AladinAPIService()
     
     func searchBooks(query: String) async {
         await MainActor.run {
             isLoading = true
             errorMessage = nil
         }
         
         do {
             let response = try await apiService.searchBooks(
                 query: query,
                 page: 1,
                 maxResults: 20
             )
             
             await MainActor.run {
                 self.books = response.item
                 self.isLoading = false
             }
         } catch {
             await MainActor.run {
                 self.errorMessage = error.localizedDescription
                 self.isLoading = false
             }
         }
     }
     
     func loadBookDetail(isbn: String) async {
         do {
             let book = try await apiService.getBook(isbn: isbn)
             // book 사용
             print("책 제목: \(book.title)")
         } catch {
             await MainActor.run {
                 self.errorMessage = error.localizedDescription
             }
         }
     }
 }
 
 // SwiftUI View에서 사용 예시
 
 struct BookSearchView: View {
     @StateObject private var viewModel = BookSearchViewModel()
     @State private var searchText = ""
     
     var body: some View {
         VStack {
             TextField("도서 검색", text: $searchText)
                 .textFieldStyle(.roundedBorder)
                 .padding()
                 .onSubmit {
                     Task {
                         await viewModel.searchBooks(query: searchText)
                     }
                 }
             
             if viewModel.isLoading {
                 ProgressView("검색 중...")
             } else if let error = viewModel.errorMessage {
                 Text("오류: \(error)")
                     .foregroundColor(.red)
             } else {
                 List(viewModel.books, id: \.isbn) { book in
                     VStack(alignment: .leading) {
                         Text(book.title)
                             .font(.headline)
                         Text(book.author)
                             .font(.subheadline)
                             .foregroundColor(.gray)
                     }
                 }
             }
         }
     }
 }
 
 */
