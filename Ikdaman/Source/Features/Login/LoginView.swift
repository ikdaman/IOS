//
//  LoginView.swift
//  Ikdaman
//
//  Created by Soo on 3/16/26.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @Environment(\.dismiss) private var dismiss
    
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
                    viewModel.login(type: .google)
                } label: {
                    Text("구글 로그인")
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white)
                        .cornerRadius(8)
                }
                
                // 네이버
                Button {
                    viewModel.login(type: .naver)
                } label: {
                    Text("네이버 로그인")
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.green)
                        .cornerRadius(8)
                }
                
                // 카카오
                Button {
                    viewModel.login(type: .kakao)
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
                        viewModel.handleAppleSignIn(result: result)
                    }
                )
                .frame(height: 50)
                .cornerRadius(8)
            }
            
            // 디버깅용 상태 표시
            Text("현재 상태: \(viewModel.authStateDescription)")
                .font(.system(size: 10))
                .foregroundColor(.gray)
                .padding(.bottom, 10)
        }
        .background(Color.customBg)
        .toolbar(.hidden, for: .tabBar)
        .navigationDestination(isPresented: $viewModel.showSignup) {
            SignupView()
        }
        .onChange(of: viewModel.shouldDismiss) { _, shouldDismiss in
            if shouldDismiss {
                dismiss()
            }
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
