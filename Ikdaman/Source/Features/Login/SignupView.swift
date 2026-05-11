import SwiftUI

struct SignupView: View {
    @StateObject private var viewModel = SignupViewModel()
    @ObservedObject var authService = AuthService.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            CustomHeader(title: "닉네임 입력", showBackButton: true) {
                Button("완료") {
                    Task { await viewModel.signup() }
                }
                .font(.customDungGeunMo(size: 16))
                .foregroundColor(.black)
            }

            Spacer().frame(height: 60)

            Text("닉네임을 입력해주세요.")
                .font(.customDungGeunMo(size: 22))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)

            Spacer().frame(height: 60)

            // 입력 필드 (PixelShadow 스타일)
            VStack(alignment: .leading, spacing: 6) {
                TextField("", text: $viewModel.nickname)
                    .textFieldStyle(.plain)
                    .font(.customSansRegular(size: 16))
                    .foregroundColor(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .overlay(alignment: .top) {
                        Rectangle().fill(Color.white).frame(height: 1).padding(.trailing, 1)
                    }
                    .overlay(alignment: .leading) {
                        Rectangle().fill(Color.white).frame(width: 1).padding(.bottom, 1)
                    }
                    .overlay(alignment: .bottom) {
                        Rectangle().fill(Color.black).frame(height: 1).padding(.leading, 1)
                    }
                    .overlay(alignment: .trailing) {
                        Rectangle().fill(Color.black).frame(width: 1).padding(.top, 1)
                    }
                    .padding(.trailing, 1)
                    .padding(.bottom, 1)
                    .background(Color.black)
                    .onChange(of: viewModel.nickname) { _, _ in
                        viewModel.validateNickname()
                    }

                if let errorMessage = viewModel.errorMessage {
                    Spacer().frame(height: 6)
                    Text(errorMessage)
                        .font(.customDungGeunMo(size: 12))
                        .foregroundColor(Color(hex: "#010196"))
                    Text("닉네임을 다시 확인해주세요.")
                        .font(.customDungGeunMo(size: 12))
                        .foregroundColor(Color(hex: "#010196"))
                }
            }
            .padding(.horizontal, 16)

            Spacer()
        }
        .background(Color.customBg)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .onChange(of: authService.authState) { _, newState in
            if newState == .loggedIn { dismiss() }
        }
    }
}

// MARK: - Signup ViewModel

@MainActor
class SignupViewModel: ObservableObject {
    @Published var nickname: String = ""
    @Published var errorMessage: String?
    @Published var isChecking: Bool = false
    @Published var isNicknameAvailable: Bool = false
    
    private let repository: BookRepositoryProtocol
    private let authService: AuthService
    private var debounceTask: Task<Void, Never>?
    
    var isValidNickname: Bool {
        !nickname.isEmpty &&
        nickname.count <= 10 &&
        errorMessage == nil &&
        isNicknameAvailable
    }
    
    init(repository: BookRepositoryProtocol = BookRepository(), authService: AuthService = .shared) {
        self.repository = repository
        self.authService = authService
    }
    
    /// 닉네임 유효성 검사
    func validateNickname() {
        debounceTask?.cancel()
        
        errorMessage = nil
        isNicknameAvailable = false
        
        guard !nickname.isEmpty else {
            return
        }
        
        if nickname.count > 10 {
            errorMessage = "닉네임은 최대 10자까지 가능합니다."
            return
        }
        
        // 한글, 영어, 숫자만 허용
        let pattern = "^[가-힣a-zA-Z0-9]+$"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: nickname.utf16.count)
        
        if regex?.firstMatch(in: nickname, range: range) == nil {
            errorMessage = "한글, 영어, 숫자만 사용 가능합니다."
            return
        }
        
        // 디바운스 적용
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            guard !Task.isCancelled else { return }
            
            await checkNicknameDuplication()
        }
    }
    
    /// 닉네임 중복 체크
    private func checkNicknameDuplication() async {
        isChecking = true
        
        do {
            let isAvailable = try await repository.checkNickname(nickname: nickname)
            isNicknameAvailable = isAvailable
            
            if !isAvailable {
                errorMessage = "중복된 닉네임이에요."
            }
        } catch {
            errorMessage = "닉네임 확인에 실패했습니다."
        }
        
        isChecking = false
    }
    
    /// 회원가입
    func signup() async {
        guard isValidNickname else { return }
        
        await authService.signup(nickname: nickname)
        
        // authState 변화는 SignupView에서 감지하여 화면 전환 처리
        if let error = authService.errorMessage {
            errorMessage = error
        }
    }
}

#Preview {
    SignupView()
}
