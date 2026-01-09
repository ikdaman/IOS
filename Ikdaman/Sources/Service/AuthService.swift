//
//  AuthService.swift
//  Ikdaman
//
//  Created by Soo on 4/22/25.
//

import Foundation
import Combine
import SwiftUI
import KakaoSDKAuth
import KakaoSDKUser
import NaverThirdPartyLogin
import AuthenticationServices
import GoogleSignIn

@MainActor
class AuthService: NSObject, ObservableObject {
    // Shared instance
    static let shared = AuthService()
    
    // 현재 로그인된 사용자 정보 (옵셔널)
    @Published private(set) var loginType: LoginType? = nil
    
    // 현재 로그인 여부
    var isLogin: Bool {
        loginType?.token != nil
    }
    
    override init() {
        super.init()
    }
    
    func login(type: SnsType) async {
        switch type {
        case .google(let viewController):
            _ = try? await googleLogin(viewController: viewController)
        case .naver:
            naverLogin()
        case .kakao:
            _ = try? await kakaoLogin()
        case .apple:
            requestAppleIdProvider()
        }
    }
        
    // 로그아웃 메서드
    func logout() async {
        switch loginType?.provider {
        case .google:
            googleLogout()
        case .naver:
            oauth20ConnectionDidFinishDeleteToken()
        case .kakao:
            try? await kakaoUnlink()
        case .apple, .none:
            break
        }
        
        loginType = nil
        UserDefaults.standard.nickName = nil
        
        let _ = KeychainService.shared.delete(forKey: .accessToken)
        let _ = KeychainService.shared.delete(forKey: .refreshToken)
    }
}

// MARK: - KakaoLogin
extension AuthService {
    /// 카카오 로그인 세션 생성 및 로그인 요청
    func kakaoLogin() async throws {
        if UserApi.isKakaoTalkLoginAvailable() {
            _ = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<OAuthToken, Error>) in
                UserApi.shared.loginWithKakaoTalk { oauthToken, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let token = oauthToken {
                        continuation.resume(returning: token)
                    } else {
                        continuation.resume(throwing: NSError(domain: "KakaoLogin", code: -1))
                    }
                }
            }
        } else {
            _ = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<OAuthToken, Error>) in
                UserApi.shared.loginWithKakaoAccount { oauthToken, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let token = oauthToken {
                        continuation.resume(returning: token)
                    } else {
                        continuation.resume(throwing: NSError(domain: "KakaoLogin", code: -1))
                    }
                }
            }
        }
        
        if AuthApi.hasToken() {
            print("hasToken success")
            try await getKakaoUser()
        } else {
            print("hasToken fail")
            throw NSError(domain: "KakaoLogin", code: -2, userInfo: [NSLocalizedDescriptionKey: "No token available"])
        }
    }

    /// 카카오 유저정보 조회
    private func getKakaoUser() async throws {
        let userInfo = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<KakaoSDKUser.User, Error>) in
            UserApi.shared.me { userInfo, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let user = userInfo {
                    continuation.resume(returning: user)
                } else {
                    continuation.resume(throwing: NSError(domain: "KakaoLogin", code: -3))
                }
            }
        }
        
        if let uid = userInfo.id {
            let token = TokenManager().getToken()?.accessToken
            self.loginType = LoginType(token: token, provider: .kakao, providerId: String(uid))
            print("UserApi.shared.me success")
        }
    }

    /// 카카오 로그아웃
    func kakaoUnlink() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            UserApi.shared.logout { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    print("kakaoUnlink() success")
                    continuation.resume()
                }
            }
        }
    }
}

// MARK: - NaverLogin
extension AuthService: NaverThirdPartyLoginConnectionDelegate {
    // 네이버 로그인 instance 생성 및 로그인시작
    func naverLogin() {
        guard let instance = NaverThirdPartyLoginConnection.getSharedInstance() else { return }
        instance.delegate = self
        instance.requestThirdPartyLogin()
    }

    // 로그인에 성공했을 경우 호출
    nonisolated func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        Task { @MainActor in
            // 토큰값 배출
            guard let instance = NaverThirdPartyLoginConnection.getSharedInstance() else { return }
            guard let accessToken = instance.accessToken else { return }
            
            do {
                let profile = try await NaverProfileAPI.requestProfile(accessToken: accessToken)
                self.loginType = LoginType(token: accessToken, provider: .naver, providerId: profile.id)
            } catch {
                print("프로필 조회 실패:", error.localizedDescription)
            }
        }
    }

    // 접근 토큰 갱신
    nonisolated func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() { }

    // 로그아웃 할 경우 호출(토큰 삭제)
    nonisolated public func oauth20ConnectionDidFinishDeleteToken() {
        Task { @MainActor in
            guard let instance = NaverThirdPartyLoginConnection.getSharedInstance() else { return }
            instance.resetToken()
        }
    }

    // 로그인에 실패했을 경우 호출, 모든 Error
    nonisolated func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        self.oauth20ConnectionDidFinishDeleteToken()
    }
    
}

// MARK: Apple Login
extension AuthService: ASAuthorizationControllerDelegate {
    /// 로그인 정보 요청
    func requestAppleIdProvider() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email] // 이메일과 이름을 반드시 제공하도록 요청

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }

    // 로그인했던 계정이 있을때 그 계정으로 로그인할 수 있도록함
    func performExistingAccountSetupFlows() {
        let requests = [ASAuthorizationAppleIDProvider().createRequest(),
                        ASAuthorizationPasswordProvider().createRequest()]

        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task { @MainActor in
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                if let identityToken = appleIDCredential.identityToken,
                   let tokenString = String(data: identityToken, encoding: .utf8) {
                    print("Apple ID Token: \(tokenString)")
                    self.loginType = LoginType(token: tokenString, provider: .apple, providerId: appleIDCredential.user)
                } else {
                    print("Unable to fetch identity token")
                }
            }
        }
    }

    /// 요청에 실패했을때 에러처리
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("##AppleLogin## -> Error: \(String(describing: error))")
    }
}

// MARK: Google Login
extension AuthService {
    func googleLogin(viewController: UIViewController) async throws -> (String, String) {
        return try await withCheckedThrowingContinuation { continuation in
            GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { result, error in
                if let error = error {
                    print("구글 로그인 실패: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let user = result?.user,
                      let idToken = user.idToken?.tokenString,
                      let userId = user.userID
                else {
                    print("구글 토큰 가져오기 실패")
                    continuation.resume(throwing: NSError(domain: "GoogleLogin", code: -1))
                    return
                }
                
                Task { @MainActor in
                    self.loginType = LoginType(token: idToken, provider: .google, providerId: userId)
                }
                
                print("구글 idToken: \(idToken)")
                print("구글 userId: \(userId)")
                continuation.resume(returning: (idToken, userId))
            }
        }
    }
    
    func googleLogout() {
        GIDSignIn.sharedInstance.signOut()
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
