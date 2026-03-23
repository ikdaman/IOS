//
//  LoginView.swift
//  Ikdaman
//
//  Created by Soo on 3/16/26.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @ObservedObject var authService = AuthService.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showSignup = false
    
    var body: some View {
        VStack(spacing: 0) {
            CustomHeader(title: "로그인", showBackButton: true)
            
            Spacer()
            
            // 타이틀 섹션
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("읽고 싶은 책").font(.system(size: 28, weight: .bold))
                    Text("(가제)").font(.system(size: 24, weight: .medium))
                }
                VStack(spacing: 4) {
                    Text("최고다").font(.system(size: 16))
                    Text("로그인하세요!").font(.system(size: 16))
                }
                .padding(.top, 20)
            }
            
            Spacer()
            
            policyText
            
            VStack(spacing: 12) {
                // 구글
                Button {
                    Task { await authService.login(type: .google) }
                } label: {
                    Text("구글 로그인")
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white)
                        .cornerRadius(8)
                }
                
                // 네이버
                Button {
                    Task { await authService.login(type: .naver) }
                } label: {
                    Text("네이버 로그인")
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.green)
                        .cornerRadius(8)
                }
                
                // 카카오
                Button {
                    Task { await authService.login(type: .kakao) }
                } label: {
                    Text("카카오 로그인")
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.yellow)
                        .cornerRadius(8)
                }
                
                // 애플
                SignInWithAppleButton(
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        Task { @MainActor in
                            switch result {
                            case .success(let authorization):
                                if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                                   let identityToken = appleIDCredential.identityToken,
                                   let tokenString = String(data: identityToken, encoding: .utf8) {
                                    authService.loginType = LoginType(
                                        token: tokenString,
                                        provider: .apple,
                                        providerId: appleIDCredential.user
                                    )
                                    await authService.authenticateWithServer()
                                }
                            case .failure(let error):
                                authService.errorMessage = error.localizedDescription
                            }
                        }
                    }
                )
                .frame(height: 50)
                .cornerRadius(8)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 40)
            
            // 디버깅용 상태 표시
            Text("현재 상태: \(authStateDescription)")
                .font(.system(size: 10))
                .foregroundColor(.gray)
                .padding(.bottom, 10)
        }
        .background(Color.customBg)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .navigationDestination(isPresented: $showSignup) {
            SignupView()
        }
        .onChange(of: authService.authState) { oldState, newState in
            print("🔄 [LoginView] AuthState changed from \(oldState) to \(newState)")
            
            if newState == .needsSignup {
                showSignup = true
            } else if newState == .loggedIn {
                dismiss()
            }
        }
    }
    
    private var authStateDescription: String {
        switch authService.authState {
        case .loggedOut: return "로그아웃"
        case .needsSignup: return "회원가입 필요"
        case .loggedIn: return "로그인 완료"
        }
    }
    
    private var policyText: some View {
        (Text("가입시 ") +
         Text("이용약관").underline() +
         Text(" 및 ") +
         Text("개인정보처리방침").underline() +
         Text("에 동의하게 됩니다."))
        .font(.system(size: 12))
        .foregroundColor(.black)
    }
}
