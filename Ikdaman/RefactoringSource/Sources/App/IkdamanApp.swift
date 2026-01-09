//
//  IkdamanApp.swift
//  Ikdaman
//
//  Created by Soo on 1/7/26.
//

import SwiftUI

@main
struct IkdamanApp: App {
    @StateObject private var authService = AuthService()
    @StateObject private var networkService = NetworkService.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
                .environmentObject(networkService)
                .onAppear {
                    // NetworkService에 AuthService 연결
                    networkService.authService = authService
                }
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        Group {
            if authService.isLogin {
                Text("로그인됨")
                    .foregroundStyle(.black)
            } else {
                Text("로그아웃 상태")
                    .foregroundStyle(.black)
            }
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab = Tab
    
    enum Tab {
        case addBook
        case 
    }
}
