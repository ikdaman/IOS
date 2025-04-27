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
    private(set) var token = BehaviorRelay<String?>(value: nil)
//    var authToken = String
    
    
//    private override init() {} // 외부에서 생성 불가능하게 private 생성자
    
    // 로그인 메서드
    func login(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        // 예제: 네트워크 요청 또는 로컬 인증 처리 (실제 구현 필요)
//        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
//            if email == "test@example.com" && password == "password123" {
//                self.currentUser = User(id: UUID().uuidString, email: email)
//                completion(true, nil)
//            } else {
//                completion(false, "Invalid email or password")
//            }
//        }
    }
    
    // 로그아웃 메서드
    func logout() {
        token.accept(nil)
    }
    
    // 로그인 여부 확인
    func isLoggedIn() -> Bool {
//        return token.
        return false
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
                    self.token.accept(token)
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
        self.token.accept(accessToken)
        
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

    /// 요청에 성공했을때 데이터 처리
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            // 처음 로그인할때는 이름,이메일,아이덴티 모두 제공
            // 첫 로그인아닐때는 아이덴티만 제공
            let uid = appleIDCredential.user
//            let fcmToken = Defaults.shared.get(for: .fcmToken)
//            let pushId = fcmToken == nil ? nil : fcmToken
//            let loginData = LoginSnsReqData(snsType: "A", encSnsUid: uid, snsEmail: nil, userName: nil, pushId: pushId)
//            self.loginSnsData.accept(loginData)
        default:
            break
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
                  let idToken = user.idToken?.tokenString
            else {
                print("❌ 토큰 가져오기 실패")
                completion(nil, nil)
                return
            }
            let accessToken = user.accessToken.tokenString
            self.token.accept(accessToken)

            print("✅ idToken: \(idToken)")
            print("✅ accessToken: \(accessToken)")
            completion(idToken, accessToken)
        }
    }


}

struct NaverUserModel: Codable {
    let resultCode: String
    let message: String
    let value: NaverUserInfo
    
    enum CodingKeys: String, CodingKey {
        case resultCode = "resultcode"
        case value = "response"
        case message
    }
}

struct NaverUserInfo: Codable {
    let email: String
    let nickname: String
    let profileImage: String
    let age: String
    let gender: String
    let id: String
    let name: String
    let birthday: String
    let birthyear: String
    let mobile: String
    
    enum CodingKeys: String, CodingKey {
        case email, nickname, age, gender, id, name, birthday, birthyear, mobile
        case profileImage = "profile_image"
    }
}

//struct UserInfo: Codable {
//    let name: String
//    let nickname: String
//    let id: String
//}
