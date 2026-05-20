//
//  ReadingApp.swift
//  읽다만 iOS
//
//  Created on 2026-03-09.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth
import NaverThirdPartyLogin
import UIKit

@main
struct ReadingApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    if AuthApi.isKakaoTalkLoginUrl(url) {
                        _ = AuthController.handleOpenUrl(url: url)
                    } else {
                        NaverThirdPartyLoginConnection.getSharedInstance().application(
                            UIApplication.shared, open: url, options: [:]
                        )
                    }
                }
        }
    }
}
