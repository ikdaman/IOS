//
//  SignUpRepositoryAsyncImpl.swift
//  Ikdaman
//
//  Created by Soo on 1/7/26.
//

import Foundation

// MARK: - Protocol
protocol SignUpRepositoryAsync {
    func login(type: LoginType) async throws -> Profile
}

// MARK: - Implementation
final class SignUpRepositoryAsyncImpl: SignUpRepositoryAsync {
    private let apiClient = APIClient.shared
    
    func login(type: LoginType) async throws -> Profile {
        return try await apiClient.request(
            BookEndpoint.login(type: type),
            responseType: Profile.self
        )
    }
}
