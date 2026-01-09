//
//  ExampleUsageViewModel.swift
//  Ikdaman
//
//  Created by Soo on 1/7/26.
//

import SwiftUI

// MARK: - SwiftUI에서 AuthService와 APIClient 사용 예시

/// 로그인 화면 예시
//@MainActor
//class LoginViewModel: ObservableObject {
//    @Published var isLoading = false
//    @Published var errorMessage: String?
//    
//    private let authService: AuthService
//    private let apiClient: APIClient
//    
//    init(authService: AuthService, apiClient: APIClient) {
//        self.authService = authService
//        self.apiClient = apiClient
//    }
//    
//    /// 구글 로그인
//    func googleLogin(viewController: UIViewController) async {
//        isLoading = true
//        defer { isLoading = false }
//        
//        do {
//            let (idToken, userId) = try await authService.googleLogin(viewController: viewController)
//            print("구글 로그인 성공: \(userId)")
//            
//            // 서버에 로그인 요청
//            let endpoint = BookEndpoint.login(type: LoginType(
//                token: idToken,
//                provider: .google,
//                providerId: userId
//            ))
//            
//            let profile: Profile = try await apiClient.request(endpoint, responseType: Profile.self)
//            print("서버 로그인 성공: \(profile.nickname ?? "")")
//            
//        } catch {
//            errorMessage = error.localizedDescription
//            print("로그인 실패: \(error)")
//        }
//    }
//    
//    /// 카카오 로그인
//    func kakaoLogin() async {
//        isLoading = true
//        defer { isLoading = false }
//        
//        do {
//            try await authService.kakaoLogin()
//            print("카카오 로그인 성공")
//            
//            // authService.loginType에 정보가 저장되어 있음
//            if let loginType = authService.loginType {
//                let endpoint = BookEndpoint.login(type: loginType)
//                let profile: Profile = try await apiClient.request(endpoint, responseType: Profile.self)
//                print("서버 로그인 성공: \(profile.nickname ?? "")")
//            }
//            
//        } catch {
//            errorMessage = error.localizedDescription
//            print("로그인 실패: \(error)")
//        }
//    }
//    
//    /// 로그아웃
//    func logout() async {
//        isLoading = true
//        defer { isLoading = false }
//        
//        do {
//            let endpoint = BookEndpoint.logout
//            try await apiClient.requestRaw(endpoint)
//            await authService.logout()
//            print("로그아웃 성공")
//        } catch {
//            errorMessage = error.localizedDescription
//            print("로그아웃 실패: \(error)")
//        }
//    }
//}
//
//// MARK: - SwiftUI View 예시
//struct LoginView: View {
//    @EnvironmentObject var authService: AuthService
//    @EnvironmentObject var apiClient: APIClient
//    @StateObject private var viewModel: LoginViewModel
//    
//    init() {
//        // 초기화 시점에는 Environment 접근 불가
//        // onAppear에서 설정하거나, 다른 방식 사용
//        let tempAuth = AuthService()
//        let tempClient = APIClient.shared
//        _viewModel = StateObject(wrappedValue: LoginViewModel(
//            authService: tempAuth,
//            apiClient: tempClient
//        ))
//    }
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            if viewModel.isLoading {
//                ProgressView("로그인 중...")
//            } else {
//                Button("카카오 로그인") {
//                    Task {
//                        await viewModel.kakaoLogin()
//                    }
//                }
//                .buttonStyle(.borderedProminent)
//                
//                Button("로그아웃") {
//                    Task {
//                        await viewModel.logout()
//                    }
//                }
//                .buttonStyle(.bordered)
//            }
//            
//            if let error = viewModel.errorMessage {
//                Text(error)
//                    .foregroundColor(.red)
//                    .font(.caption)
//            }
//        }
//        .padding()
//        .onAppear {
//            // ViewModel에 정확한 인스턴스 주입
//            // 더 나은 방법: ViewModelFactory 패턴 사용
//        }
//    }
//}
//
//// MARK: - 더 나은 패턴: ViewModelFactory
//
///// ViewModel을 생성하는 팩토리 (Environment에서 주입)
//@MainActor
//class ViewModelFactory: ObservableObject {
//    let authService: AuthService
//    let apiClient: APIClient
//    
//    init(authService: AuthService, apiClient: APIClient) {
//        self.authService = authService
//        self.apiClient = apiClient
//    }
//    
//    func makeLoginViewModel() -> LoginViewModel {
//        LoginViewModel(authService: authService, apiClient: apiClient)
//    }
//}
//
//// MARK: - 개선된 App 구조
//struct ImprovedIkdamanApp: App {
//    @StateObject private var authService = AuthService()
//    @StateObject private var apiClient = APIClient.shared
//    @StateObject private var viewModelFactory: ViewModelFactory
//    
//    init() {
//        let auth = AuthService()
//        let client = APIClient.shared
//        
//        _authService = StateObject(wrappedValue: auth)
//        _apiClient = StateObject(wrappedValue: client)
//        _viewModelFactory = StateObject(wrappedValue: ViewModelFactory(
//            authService: auth,
//            apiClient: client
//        ))
//        
//        // APIClient에 AuthService 연결
//        Task { @MainActor in
//            client.authService = auth
//        }
//    }
//    
//    var body: some Scene {
//        WindowGroup {
//            ImprovedContentView()
//                .environmentObject(authService)
//                .environmentObject(apiClient)
//                .environmentObject(viewModelFactory)
//        }
//    }
//}
//
//struct ImprovedContentView: View {
//    @EnvironmentObject var authService: AuthService
//    @EnvironmentObject var viewModelFactory: ViewModelFactory
//    
//    var body: some View {
//        Group {
//            if authService.isLogin {
//                Text("로그인됨")
//            } else {
//                ImprovedLoginView()
//            }
//        }
//    }
//}
//
//struct ImprovedLoginView: View {
//    @EnvironmentObject var viewModelFactory: ViewModelFactory
//    @StateObject private var viewModel: LoginViewModel
//    
//    init() {
//        // 임시 인스턴스 - onAppear에서 교체
//        _viewModel = StateObject(wrappedValue: LoginViewModel(
//            authService: AuthService(),
//            apiClient: APIClient.shared
//        ))
//    }
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            if viewModel.isLoading {
//                ProgressView("로그인 중...")
//            } else {
//                Button("카카오 로그인") {
//                    Task {
//                        await viewModel.kakaoLogin()
//                    }
//                }
//                .buttonStyle(.borderedProminent)
//            }
//            
//            if let error = viewModel.errorMessage {
//                Text(error)
//                    .foregroundColor(.red)
//            }
//        }
//    }
//}
//
//// MARK: - API 사용 예시 (다른 기능들)
//
//@MainActor
//class BookViewModel: ObservableObject {
//    @Published var books: [BookItem] = []
//    @Published var isLoading = false
//    @Published var errorMessage: String?
//    
//    private let apiClient: APIClient
//    
//    init(apiClient: APIClient) {
//        self.apiClient = apiClient
//    }
//    
//    /// 책 목록 조회
//    func fetchBooks(status: String? = nil, keyword: String? = nil) async {
//        isLoading = true
//        defer { isLoading = false }
//        
//        do {
//            let endpoint = BookEndpoint.bookList(
//                status: status,
//                keyword: keyword,
//                page: 1,
//                limit: 20
//            )
//            
//            let response: BookListResponse = try await apiClient.request(
//                endpoint,
//                responseType: BookListResponse.self
//            )
//            
//            books = response.items
//            print("책 목록 조회 성공: \(books.count)개")
//            
//        } catch {
//            errorMessage = error.localizedDescription
//            print("책 목록 조회 실패: \(error)")
//        }
//    }
//    
//    /// 책 추가
//    func addBook(_ book: AddMyBook) async {
//        isLoading = true
//        defer { isLoading = false }
//        
//        do {
//            let endpoint = BookEndpoint.addBook(book: book)
//            try await apiClient.requestRaw(endpoint)
//            print("책 추가 성공")
//            
//            // 목록 새로고침
//            await fetchBooks()
//            
//        } catch {
//            errorMessage = error.localizedDescription
//            print("책 추가 실패: \(error)")
//        }
//    }
//}
//
//// MARK: - 필요한 모델 타입들 (예시)
//
//struct Profile: Codable {
//    let nickname: String?
//    let email: String?
//}
//
//struct BookItem: Codable, Identifiable {
//    let id: Int
//    let title: String
//    let writer: String
//}
//
//struct BookListResponse: Codable {
//    let items: [BookItem]
//    let total: Int
//}
//
//struct AddMyBook: Codable {
//    let title: String
//    let writer: String
//    let publisher: String
//    let isbn: String
//    let page: Int
//    let coverImage: String
//    let itemId: String
//    let impression: String
//    let createdAt: String
//}
