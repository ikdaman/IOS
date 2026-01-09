//
//  SignUpUseCaseAsync.swift
//  Ikdaman
//
//  Created by Soo on 1/7/26.
//

import Foundation

// MARK: - Protocol
protocol SignUpUseCaseAsync {
    func login(type: LoginType) async throws -> Profile
}

// MARK: - Implementation
final class DefaultSignUpUseCaseAsync: SignUpUseCaseAsync {
    private let repository: SignUpRepositoryAsync
    
    init(repository: SignUpRepositoryAsync = SignUpRepositoryAsyncImpl()) {
        self.repository = repository
    }
    
    func login(type: LoginType) async throws -> Profile {
        return try await repository.login(type: type)
    }
}
