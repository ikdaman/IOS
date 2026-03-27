//
//  SettingViewModel.swift
//  Ikdaman
//
//  Created by Soo on 3/27/26.
//

import Foundation

@MainActor
final class SettingViewModel: ObservableObject {
    @Published var nickname: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var nicknameError: String?

    private let repository: BookRepositoryProtocol
    private let authService: AuthService

    init(repository: BookRepositoryProtocol = BookRepository(), authService: AuthService = .shared) {
        self.repository = repository
        self.authService = authService
        loadNickname()
    }

    private func loadNickname() {
        nickname = UserDefaults.standard.string(forKey: "nickname") ?? ""
    }

    func updateNickname() async {
        guard !nickname.isEmpty else {
            nicknameError = "닉네임을 입력해주세요."
            return
        }
        isLoading = true
        nicknameError = nil
        errorMessage = nil
        do {
            try await repository.modifyProfile(nickname: nickname)
            UserDefaults.standard.set(nickname, forKey: "nickname")
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func logout() async {
        await authService.logout()
    }
}
