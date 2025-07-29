//
//  AuthService.swift
//  Ikdaman
//
//  Created by Soo on 4/22/25.
//

import Foundation
import RxSwift
import KakaoSDKAuth
import KakaoSDKUser
import NaverThirdPartyLogin
import AuthenticationServices
import GoogleSignIn
import RxRelay

class AuthService: NSObject {
    // 싱글톤 인스턴스
    static let shared = AuthService()
    
    let disposeBag = DisposeBag()
    
    // 현재 로그인된 사용자 정보 (옵셔널)
    private(set) var loginType = BehaviorRelay<LoginType?>(value: nil)
        
    // 로그아웃 메서드
    func logout() {
        loginType.accept(nil)
        UserDefaults.standard.nickName = nil
        
        KeychainService.shared.delete(forKey: .accessToken)
        KeychainService.shared.delete(forKey: .refreshToken)
    }
    
    // 로그인 여부 확인
    func isLoggedIn() -> Bool {
        return loginType.value?.token != nil
    }
}

// MARK: - KakaoLogin
extension AuthService {
    /// 카카오 로그인 세션 생성 및 로그인 요청
    func kakaoLogin() {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { [weak self] oauthToken, error in
                guard let `self` = self else { return }
                if error == nil {
                    if AuthApi.hasToken() {
                        // 로그인 성공시 유저정보 조회
                        print("hasToken success")
                        self.getKakaoUser()
                    } else {
                        print("hasToken fail")
                    }
                } else {
                    print("로그인 실패")
                }
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { oauthToken, error in
                    if let error = error {
                        print("loginWithKakaoAccount fail")
                    } else {
                        print("loginWithKakaoAccount success")
                        self.getKakaoUser()
                    }
            }
        }
    }

    /// 카카오 유저정보 조회
    func getKakaoUser() {
        UserApi.shared.me { [weak self] userInfo, error in
            guard let `self` = self else { return }
            if error != nil {
                print("UserApi.shared.me fail")
            } else {
                if let uid = userInfo?.id {
                    let token = TokenManager().getToken()?.accessToken
                    self.loginType.accept(LoginType(token: token, provider: "KAKAO", providerId: String(uid)))
                    print("UserApi.shared.me success")
                }
            }
        }
    }

    /// 카카오 로그아웃
    func kakaoUnlink() {
        UserApi.shared.logout { error in
            if let error = error {
                print(error)
            } else {
                print("kakaoUnlink() success")
            }
        }
    }
}

// MARK: - NaverLogin
extension AuthService: NaverThirdPartyLoginConnectionDelegate {
    // 네이버 로그인 instance 생성 및 로그인시작
    func getInstance() {
        guard let instance = NaverThirdPartyLoginConnection.getSharedInstance() else { return }
        instance.delegate = self
        instance.requestThirdPartyLogin()
    }

    // 로그인에 성공했을 경우 호출
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        // 토큰값 배출
        guard let instance = NaverThirdPartyLoginConnection.getSharedInstance() else { return }
        guard let tokenType = instance.tokenType else { return }
        guard let accessToken = instance.accessToken else { return }

        let token = "\(tokenType) \(accessToken)"
        self.loginType.accept(LoginType(token: accessToken, provider: "NAVER", providerId: instance.consumerKey))
        
    }

    // 접근 토큰 갱신
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() { }

    // 로그아웃 할 경우 호출(토큰 삭제)
    public func oauth20ConnectionDidFinishDeleteToken() {
        guard let instance = NaverThirdPartyLoginConnection.getSharedInstance() else { return }
        instance.resetToken()
    }

    // 로그인에 실패했을 경우 호출, 모든 Error
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
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
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {

                // 🛑 여기서 ID Token 가져옴
                if let identityToken = appleIDCredential.identityToken,
                   let tokenString = String(data: identityToken, encoding: .utf8) {
                    print("Apple ID Token: \(tokenString)")
                    self.loginType.accept(LoginType(token: tokenString, provider: "APPLE", providerId: appleIDCredential.user))
                    // 👉 서버에 토큰 보내거나 저장하거나 등등
                } else {
                    print("Unable to fetch identity token")
                }
            }
        }

    /// 요청에 실패했을때 에러처리
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("##AppleLogin## -> Error: \(String(describing: error))")
    }
}

// MARK: Google Login
extension AuthService {
    func googleLogin(viewController: UIViewController, completion: @escaping (String?, String?) -> Void) {
        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { result, error in
            if let error = error {
                print("❌ 로그인 실패: \(error.localizedDescription)")
                completion(nil, nil)
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString,
                  let userId = user.userID
            else {
                print("❌ 토큰 가져오기 실패")
                completion(nil, nil)
                return
            }
            self.loginType.accept(LoginType(token: idToken, provider: "GOOGLE", providerId: userId))

            print("✅ idToken: \(idToken)")
            print("✅ userId: \(userId)")
            completion(idToken, userId)
        }
    }
}
