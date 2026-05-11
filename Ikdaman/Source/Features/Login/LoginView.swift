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
            CustomHeader(title: "", showBackButton: true)

            Spacer()

            // 앱 로고 + 타이틀
            VStack(spacing: 12) {
                Image("BookLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                Text("모아북")
                    .font(.customDungGeunMo(size: 28))
                    .foregroundColor(.black)
            }

            Spacer()

            // 소셜 로그인 버튼
            VStack(spacing: 12) {
                LoginSocialButton(iconName: "GmailLogo", text: "구글 로그인") {
                    viewModel.login(type: .google)
                }
                LoginSocialButton(iconName: nil, text: "네이버 로그인") {
                    viewModel.login(type: .naver)
                }
                LoginSocialButton(iconName: "KakaoLogo", text: "카카오 로그인") {
                    viewModel.login(type: .kakao)
                }
                SignInWithAppleButton(
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        viewModel.handleAppleSignIn(result: result)
                    }
                )
                .frame(height: 48)
            }
            .padding(.horizontal, 16)

            Spacer().frame(height: 16)

            // 약관 동의 문구
            HStack(spacing: 0) {
                Text("가입시 ")
                Text("이용약관").underline()
                Text(" 및 ")
                Text("개인정보처리방침").underline()
                Text("에 동의하게 됩니다.")
            }
            .font(.customSansRegular(size: 14))
            .foregroundColor(.black)
            .padding(.horizontal, 16)

            Spacer().frame(height: 40)
        }
        .background(Color.customBg)
        .toolbar(.hidden, for: .tabBar)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $viewModel.showSignup) {
            SignupView()
        }
        .onChange(of: viewModel.shouldDismiss) { _, shouldDismiss in
            if shouldDismiss { dismiss() }
        }
    }
}

// MARK: - Social Login Button

private struct LoginSocialButton: View {
    let iconName: String?
    let text: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let iconName {
                    Image(iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                }
                Text(text)
                    .font(.customDungGeunMo(size: 14))
                    .foregroundColor(.black)
            }
        }
        .buttonStyle(LoginSocialButtonStyle())
    }
}

private struct LoginSocialButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed
        return configuration.label
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(Color.white)
            .overlay(alignment: .top) {
                Rectangle().fill(pressed ? Color.black : Color.white)
                    .frame(height: 1).padding(.trailing, pressed ? 0 : 1)
            }
            .overlay(alignment: .leading) {
                Rectangle().fill(pressed ? Color.black : Color.white)
                    .frame(width: 1).padding(.bottom, pressed ? 0 : 1)
            }
            .overlay(alignment: .bottom) {
                Rectangle().fill(pressed ? Color.white : Color.black)
                    .frame(height: 1).padding(.leading, pressed ? 0 : 1)
            }
            .overlay(alignment: .trailing) {
                Rectangle().fill(pressed ? Color.white : Color.black)
                    .frame(width: 1).padding(.top, pressed ? 0 : 1)
            }
            .padding(.trailing, pressed ? 0 : 1)
            .padding(.bottom, pressed ? 0 : 1)
            .background(Color.black)
    }
}
