//
//  AuthService.swift
//  Ikdaman
//
//  Created by Soo on 3/16/26.
//

import Foundation
import Combine
import KakaoSDKAuth
import KakaoSDKUser
import NaverThirdPartyLogin
import AuthenticationServices
import GoogleSignIn

struct LoginType {
    var token: String
    var provider: SnsType
    var providerId: String
}

enum SnsType: String {
    case google = "GOOGLE"
    case naver = "NAVER"
    case kakao = "KAKAO"
    case apple = "APPLE"
}

enum AuthState: Equatable {
    case loggedOut           // 로그아웃 상태
    case loggedIn            // 로그인 완료
}

@MainActor
class AuthService: NSObject, ObservableObject {
    static let shared = AuthService()
    
    @Published var loginType: LoginType? = nil
    @Published var errorMessage: String? = nil
    @Published var authState: AuthState = .loggedOut
    @Published var requestSignup: Bool = false
    @Published var didJustSignup: Bool = false
    
    private let repository: BookRepositoryProtocol
    
    var isLogin: Bool {
        authState == .loggedIn
    }
    
    private override init() {
        self.repository = BookRepository()
        super.init()
        checkLoginStatus()
        APIClient.shared.authService = self
    }
    
    /// 앱 시작 시 로그인 상태 확인
    private func checkLoginStatus() {
        let hasAccess = KeychainService.shared.load(forKey: .accessToken) != nil
        let hasRefresh = KeychainService.shared.load(forKey: .refreshToken) != nil

        if hasAccess && hasRefresh {
            authState = .loggedIn
        } else {
            // 둘 중 하나만 있는 비정상 상태도 로그아웃 처리
            let _ = KeychainService.shared.delete(forKey: .accessToken)
            let _ = KeychainService.shared.delete(forKey: .refreshToken)
            UserDefaults.standard.removeObject(forKey: "nickname")
            authState = .loggedOut
        }
    }
    
    /// 소셜 로그인
    func login(type: SnsType) async {
        do {
            switch type {
            case .google:
                try await googleLogin()
            case .naver:
                naverLogin()
            case .kakao:
                try await kakaoLogin()
            case .apple:
                requestAppleIdProvider()
            }
        } catch {
            self.errorMessage = error.localizedDescription
            print("\(type.rawValue) 로그인 에러: \(error)")
        }
    }
    
    /// 소셜 로그인 후 서버 인증 처리
    func authenticateWithServer() async {
        guard let loginType = loginType else {
            errorMessage = "로그인 정보가 없습니다."
            return
        }

        do {
            let socialLogin = SocialLogin(
                provider: loginType.provider.rawValue,
                providerId: loginType.providerId,
                socialToken: loginType.token
            )

            let response = try await repository.login(type: socialLogin)
            // 토큰 저장
            if let accessToken = response.authorization {
                let _ = KeychainService.shared.save(accessToken, forKey: .accessToken)
            }
            if let refreshToken = response.refreshToken {
                let _ = KeychainService.shared.save(refreshToken, forKey: .refreshToken)
            }
            if let nickname = response.nickname {
                UserDefaults.standard.set(nickname, forKey: "nickname")
            }
            // 기존 회원 → 바로 로그인 완료
            authState = .loggedIn
            errorMessage = nil

        } catch let error as NetworkError {
            // 404 = 미가입 회원 → 회원가입 화면
            if case .httpError(let code) = error, code == 404 {
                requestSignup = true
            } else {
                errorMessage = error.errorDescription
                authState = .loggedOut
                self.loginType = nil
            }
        } catch {
            errorMessage = error.localizedDescription
            authState = .loggedOut
            self.loginType = nil
        }
    }
    
    /// 회원가입
    func signup(nickname: String) async {
        guard let loginType = loginType else {
            errorMessage = "로그인 정보가 없습니다."
            return
        }

        do {
            var socialLogin = SocialLogin(
                provider: loginType.provider.rawValue,
                providerId: loginType.providerId,
                socialToken: loginType.token
            )
            socialLogin.nickname = nickname

            let response = try await repository.signup(type: socialLogin)
            // 토큰 저장
            if let accessToken = response.authorization {
                let _ = KeychainService.shared.save(accessToken, forKey: .accessToken)
            }
            if let refreshToken = response.refreshToken {
                let _ = KeychainService.shared.save(refreshToken, forKey: .refreshToken)
            }
            if let nick = response.nickname {
                UserDefaults.standard.set(nick, forKey: "nickname")
            }

            authState = .loggedIn
            requestSignup = false
            errorMessage = nil
            didJustSignup = true

        } catch {
            errorMessage = "회원가입에 실패했습니다."
            print("회원가입 실패: \(error)")
        }
    }
    
    /// 로그아웃
    func logout() async {
        // 토큰 먼저 삭제
        let _ = KeychainService.shared.delete(forKey: .accessToken)
        let _ = KeychainService.shared.delete(forKey: .refreshToken)
        UserDefaults.standard.removeObject(forKey: "nickname")

        // loginType과 무관하게 모든 소셜 SDK 세션 초기화
        // (앱 재시작 후 loginType이 nil이어도 SDK 토큰이 남아있을 수 있음)
        GIDSignIn.sharedInstance.signOut()
        NaverThirdPartyLoginConnection.getSharedInstance()?.resetToken()
        if loginType?.provider == .kakao {
            try? await kakaoUnlink()
        }

        loginType = nil
        authState = .loggedOut
        requestSignup = false
    }
}

// MARK: - Kakao Login
extension AuthService {
    func kakaoLogin() async throws {
        // 기존 유효 토큰이 있으면 me()로 검증만 하고, 없으면 신규 로그인
        // (Kakao SDK는 loginWithKakaoTalk/Account가 내부적으로 기존 세션을 재사용함)
        if AuthApi.hasToken() {
            let isValid = await withCheckedContinuation { continuation in
                UserApi.shared.accessTokenInfo { _, error in
                    continuation.resume(returning: error == nil)
                }
            }
            if !isValid {
                // 토큰 만료 → 로컬 토큰 초기화 후 신규 로그인 진행
                try? await kakaoUnlink()
            }
        }

        let oauthToken: OAuthToken = try await withCheckedThrowingContinuation { continuation in
            let completion: (OAuthToken?, Error?) -> Void = { token, error in
                if let error = error { continuation.resume(throwing: error) }
                else if let token = token { continuation.resume(returning: token) }
                else { continuation.resume(throwing: NSError(domain: "Kakao", code: -1)) }
            }
            if UserApi.isKakaoTalkLoginAvailable() {
                UserApi.shared.loginWithKakaoTalk(completion: completion)
            } else {
                UserApi.shared.loginWithKakaoAccount(completion: completion)
            }
        }

        let user: KakaoSDKUser.User = try await withCheckedThrowingContinuation { continuation in
            UserApi.shared.me { user, error in
                if let error = error { continuation.resume(throwing: error) }
                else if let user = user { continuation.resume(returning: user) }
                else { continuation.resume(throwing: NSError(domain: "Kakao", code: -1)) }
            }
        }

        if let uid = user.id {
            self.loginType = LoginType(token: oauthToken.accessToken, provider: .kakao, providerId: String(uid))
            await authenticateWithServer()
        }
    }

    func kakaoUnlink() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            UserApi.shared.logout { error in
                if let error = error { continuation.resume(throwing: error) }
                else { continuation.resume() }
            }
        }
    }
}

// MARK: - Naver Login
extension AuthService: NaverThirdPartyLoginConnectionDelegate {
    func naverLogin() {
        guard let instance = NaverThirdPartyLoginConnection.getSharedInstance() else { return }
        instance.delegate = self

        // 기존 유효 토큰이 있으면 재사용
        if instance.isValidAccessTokenExpireTimeNow(), let accessToken = instance.accessToken {
            Task {
                do {
                    let profile = try await NaverProfileAPI.requestProfile(accessToken: accessToken)
                    await MainActor.run {
                        self.loginType = LoginType(token: accessToken, provider: .naver, providerId: profile.id)
                    }
                    await authenticateWithServer()
                } catch {
                    // 토큰 유효하지만 프로필 조회 실패 → 신규 로그인
                    instance.requestThirdPartyLogin()
                }
            }
            return
        }

        instance.requestThirdPartyLogin()
    }

    nonisolated func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        Task { @MainActor in
            guard let instance = NaverThirdPartyLoginConnection.getSharedInstance(),
                  let accessToken = instance.accessToken else { return }
            do {
                let profile = try await NaverProfileAPI.requestProfile(accessToken: accessToken)
                AuthService.shared.loginType = LoginType(token: accessToken, provider: .naver, providerId: profile.id)
                await AuthService.shared.authenticateWithServer()
            } catch {
                AuthService.shared.errorMessage = "네이버 프로필 조회 실패"
            }
        }
    }

    // 토큰 자동 갱신 완료 시에도 동일하게 서버 인증 처리
    nonisolated func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        Task { @MainActor in
            guard let instance = NaverThirdPartyLoginConnection.getSharedInstance(),
                  let accessToken = instance.accessToken else { return }
            do {
                let profile = try await NaverProfileAPI.requestProfile(accessToken: accessToken)
                AuthService.shared.loginType = LoginType(token: accessToken, provider: .naver, providerId: profile.id)
                await AuthService.shared.authenticateWithServer()
            } catch {
                AuthService.shared.errorMessage = "네이버 프로필 조회 실패"
            }
        }
    }

    nonisolated public func oauth20ConnectionDidFinishDeleteToken() {
        Task { @MainActor in
            NaverThirdPartyLoginConnection.getSharedInstance()?.resetToken()
        }
    }

    nonisolated func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        Task { @MainActor in
            AuthService.shared.errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Apple Login
extension AuthService: ASAuthorizationControllerDelegate {
    func requestAppleIdProvider() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }

    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task { @MainActor in
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
               let identityToken = appleIDCredential.identityToken,
               let tokenString = String(data: identityToken, encoding: .utf8) {
                AuthService.shared.loginType = LoginType(token: tokenString, provider: .apple, providerId: appleIDCredential.user)
                // 서버 인증 시도
                await AuthService.shared.authenticateWithServer()
            }
        }
    }

    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        Task { @MainActor in
            AuthService.shared.errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Google Login
extension AuthService {
    func googleLogin() async throws {
        // 기존 세션 복원 시도 (signIn 대신 restore → 불필요한 UI 없이 재사용)
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            do {
                let user = try await GIDSignIn.sharedInstance.restorePreviousSignIn()
                let refreshed = try await user.refreshTokensIfNeeded()
                guard let idToken = refreshed.idToken?.tokenString,
                      let userId = refreshed.userID else {
                    throw NSError(domain: "GoogleLogin", code: -1)
                }
                self.loginType = LoginType(token: idToken, provider: .google, providerId: userId)
                await authenticateWithServer()
                return
            } catch {
                // 복원 실패(토큰 만료 등) → 신규 로그인 UI 표시
            }
        }

        guard let viewController = await getRootViewController() else { return }
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController)
        guard let idToken = result.user.idToken?.tokenString,
              let userId = result.user.userID else {
            throw NSError(domain: "GoogleLogin", code: -1)
        }
        self.loginType = LoginType(token: idToken, provider: .google, providerId: userId)
        await authenticateWithServer()
    }

    func googleLogout() {
        GIDSignIn.sharedInstance.signOut()
    }
    
    private func getRootViewController() async -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return nil
        }
        
        var currentViewController = rootViewController
        while let presentedViewController = currentViewController.presentedViewController {
            currentViewController = presentedViewController
        }
        return currentViewController
    }
}

struct NaverProfileResponse: Decodable {
    struct Response: Decodable {
        let id: String?
        let nickname: String?
        let name: String?
        let email: String?
        let gender: String?
        let age: String?
        let birthday: String?
        let birthyear: String?
        let mobile: String?
        let profile_image: String?
    }
    let resultcode: String
    let message: String
    let response: Response?
}

enum NaverAPIError: Error {
    case invalidURL
    case noData
    case http(Int)
}

enum NaverProfile {
    struct Model {
        let id: String
        let nickname: String?
        let email: String?
        let profileImage: String?
    }
}

enum NaverProfileAPI {
    static func requestProfile(accessToken: String) async throws -> NaverProfile.Model {
        guard let url = URL(string: "https://openapi.naver.com/v1/nid/me") else {
            throw NaverAPIError.invalidURL
        }
        
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: req)
        
        guard let http = response as? HTTPURLResponse else {
            throw NaverAPIError.noData
        }
        
        guard (200...299).contains(http.statusCode) else {
            throw NaverAPIError.http(http.statusCode)
        }
        
        let decoded = try JSONDecoder().decode(NaverProfileResponse.self, from: data)
        let r = decoded.response
        return NaverProfile.Model(
            id: r?.id ?? "",
            nickname: r?.nickname,
            email: r?.email,
            profileImage: r?.profile_image
        )
    }
}
