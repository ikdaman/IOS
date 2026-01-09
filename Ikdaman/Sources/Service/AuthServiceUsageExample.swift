//
//  AuthServiceUsageExample.swift
//  Ikdaman
//
//  Created by Soo on 1/7/26.
//

import SwiftUI

// MARK: - App에서 AuthService 주입하는 방법

// Example - not the actual app entry point
// @main
struct ExampleIkdamanApp: App {
    // AuthService 인스턴스 생성
    @State private var authService = AuthService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.authService, authService)
        }
    }
}

// MARK: - View에서 사용하는 방법

struct LoginView: View {
    @Environment(\.authService) private var authService
    
    var body: some View {
        VStack(spacing: 20) {
            if authService.isLoggedIn {
                Text("로그인 됨: \(authService.loginType?.provider ?? "")")
                
                Button("로그아웃") {
                    authService.logout()
                }
            } else {
                Text("로그인이 필요합니다")
                
                Button("카카오 로그인") {
                    Task {
                        do {
                            try await authService.kakaoLogin()
                        } catch {
                            print("카카오 로그인 실패: \(error)")
                        }
                    }
                }
                
                Button("네이버 로그인") {
                    authService.naverLogin()
                }
                
                Button("Apple 로그인") {
                    authService.requestAppleIdProvider()
                }
                
                Button("Google 로그인") {
                    Task {
                        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                              let rootViewController = windowScene.windows.first?.rootViewController else {
                            return
                        }
                        
                        do {
                            let (token, userId) = try await authService.googleLogin(viewController: rootViewController)
                            print("Google 로그인 성공: \(token), \(userId)")
                        } catch {
                            print("Google 로그인 실패: \(error)")
                        }
                    }
                }
            }
        }
        .padding()
    }
}

// MARK: - ViewModel에서 사용하는 방법 (필요시)

@Observable
class SomeViewModel {
    var authService: AuthService
    
    init(authService: AuthService) {
        self.authService = authService
    }
    
    func performLogin() async {
        do {
            try await authService.kakaoLogin()
        } catch {
            print("로그인 실패: \(error)")
        }
    }
    
    var isLoggedIn: Bool {
        authService.isLoggedIn
    }
}

struct SomeView: View {
    @Environment(\.authService) private var authService
    @State private var viewModel: SomeViewModel?
    
    var body: some View {
        Text("Some View")
            .onAppear {
                if viewModel == nil {
                    viewModel = SomeViewModel(authService: authService)
                }
            }
    }
}

#Preview {
    let authService = AuthService()
    LoginView()
        .environment(\.authService, authService)
}
