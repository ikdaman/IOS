//
//  ReadingApp.swift
//  읽다만 iOS
//
//  Created on 2026-03-09.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth

@main
struct ReadingApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
