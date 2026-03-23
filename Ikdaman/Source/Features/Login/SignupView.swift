import SwiftUI

struct SignupView: View {
    @StateObject private var viewModel = SignupViewModel()
    @ObservedObject var authService = AuthService.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // 커스텀 헤더
            ZStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                    }
                    Spacer()
                }
                
                Text("완료")
                    .font(.system(size: 16, weight: .medium))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 80)
                
                // 메인 타이틀
                Text("닉네임을 입력해주세요.")
                    .font(.system(size: 24, weight: .bold))
                    .padding(.bottom, 40)
                
                // 입력 필드
                VStack(alignment: .leading, spacing: 8) {
                    TextField("닉네임", text: $viewModel.nickname)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.system(size: 16))
                        .padding()
                        .frame(height: 56)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(hex: "E0E0E0"), lineWidth: 1)
                        )
                        .cornerRadius(8)
                        .onChange(of: viewModel.nickname) { oldValue, newValue in
                            viewModel.validateNickname()
                        }
                    
                    // 설명 텍스트
                    VStack(alignment: .leading, spacing: 4) {
                        Text("중복을 체크하고있어요!")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "4A90E2"))
                        
                        Text("닉네임은 다시 바꾸지 못 해요.")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "4A90E2"))
                    }
                    .padding(.top, 4)
                    
                    // 에러 메시지
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                            .padding(.top, 4)
                    }
                    
                    // 중복 체크 상태
                    if viewModel.isChecking {
                        HStack(spacing: 8) {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("중복 확인 중...")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 4)
                    } else if viewModel.isNicknameAvailable && !viewModel.nickname.isEmpty {
                        Text("사용 가능한 닉네임입니다.")
                            .font(.system(size: 12))
                            .foregroundColor(.green)
                            .padding(.top, 4)
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            
            // 완료 버튼 (하단 고정)
            Button {
                Task {
                    await viewModel.signup()
                }
            } label: {
                Text("완료")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(viewModel.isValidNickname ? .black : .gray)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(viewModel.isValidNickname ? Color(hex: "D9D9D9") : Color(hex: "F5F5F5"))
                    .cornerRadius(8)
            }
            .disabled(!viewModel.isValidNickname)
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(Color.customBg)
        .navigationBarBackButtonHidden(true)
        // 회원가입 완료 후 LoginView와 SignupView를 모두 dismiss하여 메인으로 이동
        .onChange(of: authService.authState) { _, newState in
            if newState == .loggedIn {
                // NavigationStack을 완전히 pop하여 메인 화면으로 이동
                dismiss()
            }
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
