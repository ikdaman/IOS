//
//  AuthServiceEnvironment.swift
//  Ikdaman
//
//  Created by Soo on 1/7/26.
//

import SwiftUI

// Environment Key 정의
private struct AuthServiceKey: EnvironmentKey {
    static let defaultValue: AuthService = {
        MainActor.assumeIsolated {
            AuthService()
        }
    }()
}

extension EnvironmentValues {
    var authService: AuthService {
        get { self[AuthServiceKey.self] }
        set { self[AuthServiceKey.self] = newValue }
    }
}

// Extension for easy injection
extension View {
    func authService(_ service: AuthService) -> some View {
        environment(\.authService, service)
    }
}
