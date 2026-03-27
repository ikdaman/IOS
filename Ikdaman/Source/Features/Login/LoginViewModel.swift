import SwiftUI
import Combine
import AuthenticationServices

@MainActor
class LoginViewModel: ObservableObject {
    // View에서 관찰할 상태 변수들
    @Published var authState: AuthState = .loggedOut
    @Published var showSignup = false
    @Published var shouldDismiss = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let authService = AuthService.shared
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        // AuthService의 authState를 구독하여 ViewModel의 상태를 업데이트합니다.
        authService.$authState
            .receive(on: RunLoop.main)
            .sink { [weak self] newState in
                guard let self = self else { return }
                self.authState = newState
                
                if newState == .loggedIn {
                    self.shouldDismiss = true
                }
            }
            .store(in: &cancellables)
            
        // 회원가입 필요 상태 구독
        authService.$requestSignup
            .receive(on: RunLoop.main)
            .assign(to: \.showSignup, on: self)
            .store(in: &cancellables)
            
        // 에러 메시지 바인딩
        authService.$errorMessage
            .receive(on: RunLoop.main)
            .assign(to: \.errorMessage, on: self)
            .store(in: &cancellables)
    }
    
    var authStateDescription: String {
        switch authState {
        case .loggedOut: return "로그아웃"
        case .loggedIn: return "로그인 완료"
        }
    }
    
    func login(type: SnsType) {
        Task {
            await authService.login(type: type)
        }
    }
    
    func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
               let identityToken = appleIDCredential.identityToken,
               let tokenString = String(data: identityToken, encoding: .utf8) {
                authService.loginType = LoginType(token: tokenString, provider: .apple, providerId: appleIDCredential.user)
                Task { await authService.authenticateWithServer() }
            }
        case .failure(let error):
            self.errorMessage = error.localizedDescription
        }
    }
}
