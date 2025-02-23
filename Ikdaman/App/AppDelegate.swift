//
//  AppDelegate.swift
//  Ikdaman
//
//  Created by 김창규 on 2/11/25.
//

import UIKit
import KakaoSDKCommon
import NaverThirdPartyLogin

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let instance = NaverThirdPartyLoginConnection.getSharedInstance()
        
        // 네이버 앱으로 인증하는 방식 활성화(true)
        instance?.isNaverAppOauthEnable = true
        // SafariViewContoller에서 인증하는 방식 활성화(true)
        instance?.isInAppOauthEnable = true
        // 인증 화면을 iPhone의 세로 모드에서만 활성화(true)
        instance?.setOnlyPortraitSupportInIphone(true)
        
        // 로그인 설정
        instance?.serviceUrlScheme = "com.gogochang.Ikdaman" // 콜백을 받을 URL Scheme
        instance?.consumerKey = "f6Xqz2hzL03dVZtEADRs"  // 애플리케이션에서 사용하는 클라이언트 아이디
        instance?.consumerSecret = "s8v7FHuJc7"  // 애플리케이션에서 사용하는 클라이언트 시크릿
        instance?.appName = "Ikdaman"  // 애플리케이션 이름
        
        KakaoSDK.initSDK(appKey: "569b46893b34e3474de39ccd723f8bed")
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        NaverThirdPartyLoginConnection.getSharedInstance().application(app, open: url, options: options)
    }
}
