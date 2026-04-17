import Foundation

@MainActor
final class SettingViewModel: ObservableObject {

    // MARK: - Published

    @Published var nickname: String = ""
    @Published var isEditingNickname: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var nicknameError: String?
    @Published var shouldLogout: Bool = false
    @Published var shouldWithdraw: Bool = false

    // MARK: - Dependencies

    private let repository: BookRepositoryProtocol
    private let authService: AuthService

    init(repository: BookRepositoryProtocol = BookRepository(), authService: AuthService = .shared) {
        self.repository = repository
        self.authService = authService
    }

    // MARK: - Lifecycle

    func onAppear() async {
        await fetchProfile()
    }

    // MARK: - Profile

    /// 서버에서 닉네임 조회
    func fetchProfile() async {
        do {
            let response = try await repository.getProfile()
            nickname = response.nickname
            UserDefaults.standard.set(nickname, forKey: "nickname")
        } catch {
            // 실패 시 로컬 캐시 fallback
            nickname = UserDefaults.standard.string(forKey: "nickname") ?? ""
            print("⚠️ fetchProfile fallback: \(error)")
        }
    }

    // MARK: - Nickname

    func startEditingNickname() {
        isEditingNickname = true
        nicknameError = nil
    }

    func cancelEditingNickname() {
        isEditingNickname = false
        nicknameError = nil
        // 원래 값으로 복원
        nickname = UserDefaults.standard.string(forKey: "nickname") ?? ""
    }

    /// 닉네임 유효성 검사 (Android 동일 규칙)
    func validateNickname(_ input: String) -> Bool {
        guard !input.isEmpty else {
            nicknameError = "닉네임을 입력해주세요"
            return false
        }
        if input.count > 10 {
            nicknameError = "닉네임은 최대 10자까지 가능합니다"
            return false
        }
        let regex = "^[가-힣a-zA-Z0-9]*$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        if !predicate.evaluate(with: input) {
            nicknameError = "한글, 영어, 숫자만 사용할 수 있습니다"
            return false
        }
        nicknameError = nil
        return true
    }

    /// 닉네임 변경 저장
    func updateNickname() async {
        guard validateNickname(nickname) else { return }

        isLoading = true
        errorMessage = nil

        do {
            let response = try await repository.modifyProfile(nickname: nickname)
            nickname = response.nickname
            UserDefaults.standard.set(nickname, forKey: "nickname")
            isEditingNickname = false
            nicknameError = nil
        } catch {
            if let networkError = error as? NetworkError {
                nicknameError = networkError.errorDescription
            } else {
                nicknameError = error.localizedDescription
            }
        }

        isLoading = false
    }

    // MARK: - Logout

    func logout() async {
        isLoading = true
        do {
            try await repository.logout()
        } catch {
            // 로그아웃 API 실패해도 로컬 상태는 초기화
            print("⚠️ logout API error: \(error)")
        }
        await authService.logout()
        isLoading = false
        shouldLogout = true
    }

    // MARK: - Withdrawal

    func withdraw() async {
        isLoading = true
        errorMessage = nil

        do {
            try await repository.withdrawal()
            await authService.logout()
            shouldWithdraw = true
        } catch {
            if let networkError = error as? NetworkError {
                errorMessage = networkError.errorDescription
            } else {
                errorMessage = error.localizedDescription
            }
        }

        isLoading = false
    }
}
