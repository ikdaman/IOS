# Network Architecture - URLSession + Async/Await

SwiftUI MVVM 패턴을 위한 네트워크 아키텍처 설계 문서입니다.

## 📁 프로젝트 구조

```
RefactoringSource/
├── Source/
│   ├── Network/
│   │   ├── NetworkService.swift          // 네트워크 서비스 (URLSession 기반)
│   │   ├── APIEndpoints.swift            // API 엔드포인트 정의
│   │   └── NetworkError.swift            // 에러 타입 (NetworkService.swift에 포함)
│   │
│   ├── Repository/
│   │   ├── BookRepositoryProtocol.swift  // Repository 프로토콜 및 구현
│   │   └── (Other Repositories...)
│   │
│   ├── ViewModel/
│   │   ├── BookListViewModel.swift       // ViewModel 예시
│   │   └── (Other ViewModels...)
│   │
│   └── View/
│       ├── BookListView.swift            // SwiftUI View 예시
│       └── (Other Views...)
```

## 🏗️ 아키텍처 레이어

### 1. Network Layer (NetworkService)

**역할**: URLSession을 사용한 HTTP 통신 처리
- ✅ async/await 기반 비동기 처리
- ✅ 자동 토큰 리프레시
- ✅ 에러 핸들링
- ✅ Request/Response 로깅
- ✅ JSON 인코딩/디코딩

```swift
// 사용 예시
let response = try await NetworkService.shared.request(
    endpoint,
    responseType: BookListResponse.self
)
```

### 2. Endpoint Layer (APIEndpoints)

**역할**: API 엔드포인트 정의
- ✅ URL 구성 (baseURL + path)
- ✅ HTTP Method 설정
- ✅ Query Parameters
- ✅ Request Body
- ✅ Custom Headers

```swift
enum BookEndpoint: APIEndpoint {
    case bookList(status: String?, keyword: String?, page: Int, limit: Int)
    case book(bookId: Int)
    case addBook(book: AddMyBook)
    // ...
}
```

### 3. Repository Layer

**역할**: 비즈니스 로직과 데이터 소스 분리
- ✅ Protocol 기반 추상화 (테스트 용이)
- ✅ NetworkService를 사용한 API 호출
- ✅ 도메인 모델 변환

```swift
protocol BookRepositoryProtocol {
    func fetchBookList(...) async throws -> BookListResponse
    func addBook(...) async throws -> BookDetailResponse
}
```

### 4. ViewModel Layer

**역할**: View와 Repository 사이 비즈니스 로직
- ✅ @MainActor로 UI 스레드 보장
- ✅ @Published 속성으로 상태 관리
- ✅ async 메서드로 비동기 작업 처리
- ✅ 에러 핸들링 및 로딩 상태 관리

```swift
@MainActor
final class BookListViewModel: ObservableObject {
    @Published var books: [Book] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadBooks() async { ... }
}
```

### 5. View Layer (SwiftUI)

**역할**: UI 표시 및 사용자 인터랙션
- ✅ @StateObject로 ViewModel 관리
- ✅ Task { } 블록으로 async 메서드 호출
- ✅ Combine을 통한 반응형 UI

```swift
struct BookListView: View {
    @StateObject private var viewModel = BookListViewModel()
    
    var body: some View {
        // UI 구성
    }
    .task {
        await viewModel.loadBooks()
    }
}
```

## 🔑 핵심 기능

### 1. NetworkService

#### 주요 메서드

```swift
// Response를 디코딩하여 반환
func request<T: Decodable>(
    _ endpoint: APIEndpoint,
    responseType: T.Type
) async throws -> T

// Response Body가 없는 요청 (204 No Content)
func requestWithoutResponse(_ endpoint: APIEndpoint) async throws

// Raw Data 요청
func requestData(_ endpoint: APIEndpoint) async throws -> Data
```

#### 자동 토큰 리프레시

401 Unauthorized 응답 시 자동으로:
1. Refresh Token으로 재발급 시도
2. 성공하면 원래 요청 재시도
3. 실패하면 로그아웃 처리

```swift
catch let error as NetworkError where error == .unauthorized {
    let success = await refreshTokenIfNeeded()
    if success {
        return try await performRequest(request, transform: transform)
    } else {
        await authService?.logout()
        throw NetworkError.unauthorized
    }
}
```

### 2. APIEndpoint Protocol

모든 엔드포인트가 구현해야 하는 프로토콜:

```swift
protocol APIEndpoint {
    var baseURL: String { get }           // 기본 URL
    var path: String { get }              // 경로
    var method: HTTPMethod { get }        // HTTP 메서드
    var headers: [String: String]? { get } // 헤더
    var queryParameters: [String: String]? { get } // 쿼리 파라미터
    var body: Data? { get }               // 요청 본문
}
```

### 3. Error Handling

```swift
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(String)
    case encodingError
    case httpError(statusCode: Int, message: String?)
    case unauthorized
    case serverError(String)
    case networkFailure(Error)
}
```

## 📝 사용 예시

### 1. 새로운 API 추가하기

#### Step 1: Request/Response 모델 정의

```swift
// Request
struct CreateBookRequest: Codable {
    let title: String
    let author: String
    let isbn: String
}

// Response
struct BookResponse: Codable {
    let id: Int
    let title: String
    let author: String
}
```

#### Step 2: Endpoint 추가

```swift
enum BookEndpoint: APIEndpoint {
    case createBook(request: CreateBookRequest)
    
    var path: String {
        switch self {
        case .createBook:
            return "/books"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .createBook:
            return .post
        }
    }
    
    var body: Data? {
        switch self {
        case .createBook(let request):
            return try? request.toJSONData()
        }
    }
}
```

#### Step 3: Repository에 메서드 추가

```swift
protocol BookRepositoryProtocol {
    func createBook(_ request: CreateBookRequest) async throws -> BookResponse
}

final class BookRepositoryImpl: BookRepositoryProtocol {
    func createBook(_ request: CreateBookRequest) async throws -> BookResponse {
        let endpoint = BookEndpoint.createBook(request: request)
        return try await networkService.request(
            endpoint,
            responseType: BookResponse.self
        )
    }
}
```

#### Step 4: ViewModel에서 사용

```swift
@MainActor
final class BookViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repository: BookRepositoryProtocol
    
    func createBook(title: String, author: String, isbn: String) async {
        isLoading = true
        
        do {
            let request = CreateBookRequest(
                title: title,
                author: author,
                isbn: isbn
            )
            
            let response = try await repository.createBook(request)
            print("책 생성 성공: \(response)")
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
```

#### Step 5: SwiftUI View에서 호출

```swift
struct CreateBookView: View {
    @StateObject private var viewModel = BookViewModel()
    @State private var title = ""
    @State private var author = ""
    
    var body: some View {
        Form {
            TextField("제목", text: $title)
            TextField("저자", text: $author)
            
            Button("책 추가") {
                Task {
                    await viewModel.createBook(
                        title: title,
                        author: author,
                        isbn: ""
                    )
                }
            }
            .disabled(viewModel.isLoading)
        }
    }
}
```

## 🧪 테스트하기

### Mock Repository 만들기

```swift
final class MockBookRepository: BookRepositoryProtocol {
    var shouldFail = false
    var mockBooks: [Book] = []
    
    func fetchBookList(
        status: String?,
        keyword: String?,
        page: Int,
        limit: Int
    ) async throws -> BookListResponse {
        if shouldFail {
            throw NetworkError.serverError("Mock Error")
        }
        
        return BookListResponse(
            books: mockBooks,
            totalPage: 1,
            nowPage: 1
        )
    }
}
```

### ViewModel 테스트

```swift
@MainActor
final class BookListViewModelTests: XCTestCase {
    func testLoadBooks_Success() async {
        // Given
        let mockRepository = MockBookRepository()
        mockRepository.mockBooks = [
            Book(mybookId: 1, title: "Test Book", ...)
        ]
        let viewModel = BookListViewModel(repository: mockRepository)
        
        // When
        await viewModel.loadBooks()
        
        // Then
        XCTAssertEqual(viewModel.books.count, 1)
        XCTAssertEqual(viewModel.books.first?.title, "Test Book")
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testLoadBooks_Failure() async {
        // Given
        let mockRepository = MockBookRepository()
        mockRepository.shouldFail = true
        let viewModel = BookListViewModel(repository: mockRepository)
        
        // When
        await viewModel.loadBooks()
        
        // Then
        XCTAssertTrue(viewModel.books.isEmpty)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }
}
```

## 🎯 Best Practices

### 1. async/await 사용

❌ **나쁜 예**
```swift
func loadBooks() {
    Task {
        do {
            let books = try await repository.fetchBookList(...)
            self.books = books
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
```

✅ **좋은 예**
```swift
func loadBooks() async {
    do {
        let response = try await repository.fetchBookList(...)
        books = response.books
    } catch {
        errorMessage = error.localizedDescription
    }
}
```

### 2. @MainActor 사용

ViewModel을 `@MainActor`로 선언하여 모든 UI 업데이트가 메인 스레드에서 실행되도록 보장:

```swift
@MainActor
final class BookListViewModel: ObservableObject {
    @Published var books: [Book] = []
    // ...
}
```

### 3. 로딩 상태 관리

```swift
func loadBooks() async {
    guard !isLoading else { return } // 중복 호출 방지
    
    isLoading = true
    defer { isLoading = false } // 항상 로딩 종료
    
    do {
        // API 호출
    } catch {
        // 에러 처리
    }
}
```

### 4. Pagination 처리

```swift
func loadMoreIfNeeded(currentItem: Book) async {
    guard let lastItem = books.last else { return }
    
    if currentItem.id == lastItem.id && hasMorePages {
        currentPage += 1
        await loadBooks()
    }
}
```

### 5. Pull-to-Refresh

```swift
.refreshable {
    await viewModel.refresh()
}
```

## 🔒 보안

### 1. Keychain에 토큰 저장

```swift
// Access Token 저장
KeychainService.shared.save(accessToken, forKey: .accessToken)

// Access Token 읽기
let token = KeychainService.shared.load(forKey: .accessToken)
```

### 2. HTTPS 사용

```swift
enum APIConfiguration {
    static let baseURL = "https://api.example.com" // ✅ HTTPS
}
```

### 3. 민감한 정보 로깅 제외

```swift
#if DEBUG
private func logRequest(_ request: URLRequest) {
    print("📤 [\(request.httpMethod ?? "")] \(request.url?.absoluteString ?? "")")
    // 헤더에서 Authorization 제외
}
#endif
```

## 🚀 성능 최적화

### 1. URLSession Configuration

```swift
let configuration = URLSessionConfiguration.default
configuration.timeoutIntervalForRequest = 30
configuration.timeoutIntervalForResource = 300
configuration.waitsForConnectivity = true
configuration.requestCachePolicy = .returnCacheDataElseLoad
```

### 2. JSON Decoder 재사용

```swift
private let decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
}()
```

### 3. Task Cancellation

```swift
private var loadTask: Task<Void, Never>?

func loadBooks() {
    loadTask?.cancel() // 이전 작업 취소
    
    loadTask = Task {
        // API 호출
    }
}
```

## 📚 추가 참고 자료

- [Apple Docs: Fetching Website Data into Memory](https://developer.apple.com/documentation/foundation/url_loading_system/fetching_website_data_into_memory)
- [Apple Docs: Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
- [WWDC: Meet async/await in Swift](https://developer.apple.com/videos/play/wwdc2021/10132/)
