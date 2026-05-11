import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showWithdrawDialog = false

    var body: some View {
        VStack(spacing: 0) {
            CustomHeader(title: "설 정", showBackButton: true)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // MARK: - 인사말
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(viewModel.nickname.isEmpty ? "OO" : viewModel.nickname)님,")
                        Text("안녕하세요!")
                    }
                    .font(.customDungGeunMo(size: 24))
                    .padding(.top, 30)
                    .padding(.bottom, 60)

                    // MARK: - 닉네임 수정
                    VStack(alignment: .leading, spacing: 6) {
                        Text("닉네임")
                            .font(.customDungGeunMo(size: 16))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)

                        if viewModel.isEditingNickname {
                            // 편집 모드
                            TextField("닉네임 입력", text: $viewModel.nickname)
                                .font(.customSansRegular(size: 16))
                                .padding(.horizontal, 16)
                                .frame(height: 45)
                                .background(Color.white)
                                .overlay(Rectangle().stroke(Color.black, lineWidth: 1))

                            if let error = viewModel.nicknameError {
                                Text(error)
                                    .font(.customDungGeunMo(size: 12))
                                    .foregroundColor(Color.customBlue)
                            }

                            HStack {
                                Spacer()
                                Button("취소") {
                                    viewModel.cancelEditingNickname()
                                }
                                .font(.customDungGeunMo(size: 14))
                                .foregroundColor(.black)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 6)
                                .border(Color.black, width: 1)

                                Button("저장") {
                                    Task { await viewModel.updateNickname() }
                                }
                                .font(.customDungGeunMo(size: 14))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 6)
                                .background(Color.customBlue)
                                .border(Color.black, width: 1)
                            }
                            .padding(.top, 8)
                        } else {
                            // 뷰 모드
                            Button(action: { viewModel.startEditingNickname() }) {
                                HStack {
                                    Text(viewModel.nickname.isEmpty ? "닉네임 없음" : viewModel.nickname)
                                        .font(.customSansRegular(size: 16))
                                        .foregroundColor(.black)
                                    Spacer()
                                    Text("수정")
                                        .font(.customDungGeunMo(size: 12))
                                        .foregroundColor(.black.opacity(0.5))
                                }
                                .padding(.horizontal, 16)
                                .frame(height: 45)
                                .background(Color.white)
                                .overlay(Rectangle().stroke(Color.black, lineWidth: 1))
                            }
                        }
                    }

                    // MARK: - 메뉴 항목
                    VStack(alignment: .leading, spacing: 0) {
                        settingMenuItem("공지사항") { }
                        settingMenuItem("서비스 이용약관") {
                            UIApplication.shared.open(URL(string: "https://scientific-ferryboat-eb1.notion.site/3354710961a98025a529d8e3bb765d2a")!)
                        }
                        settingMenuItem("개인정보 처리방침") {
                            UIApplication.shared.open(URL(string: "https://scientific-ferryboat-eb1.notion.site/3354710961a9809caafdf17937d5dc80")!)
                        }
                    }
                    .padding(.top, 40)

                    // MARK: - 회원탈퇴
                    Button(action: { showWithdrawDialog = true }) {
                        Text("회원탈퇴")
                            .font(.customDungGeunMo(size: 12))
                            .foregroundColor(.black.opacity(0.4))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                    }
                    .padding(.top, 16)

                    Spacer().frame(height: 60)

                    // MARK: - 에러 메시지
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.customDungGeunMo(size: 12))
                            .foregroundColor(Color.customBlue)
                            .padding(.bottom, 8)
                    }

                    // MARK: - 로그아웃 버튼
                    Button(action: {
                        Task { await viewModel.logout() }
                    }) {
                        Text(viewModel.isLoading ? "로그아웃 중..." : "로그아웃")
                            .font(.customDungGeunMo(size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .background(Color.customBlue)
                            .border(Color.black, width: 1)
                    }
                    .disabled(viewModel.isLoading)
                    .padding(.bottom, 16)
                }
                .padding(.horizontal, 16)
            }
        }
        .background(Color.customBg)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .task {
            await viewModel.onAppear()
        }
        .onChange(of: viewModel.shouldLogout) { _, value in
            if value { dismiss() }
        }
        .onChange(of: viewModel.shouldWithdraw) { _, value in
            if value { dismiss() }
        }
        // MARK: - 회원탈퇴 확인 다이얼로그
        .alert("회원탈퇴", isPresented: $showWithdrawDialog) {
            Button("취소", role: .cancel) { }
            Button("탈퇴", role: .destructive) {
                Task { await viewModel.withdraw() }
            }
        } message: {
            Text("탈퇴하면 모든 데이터가 삭제되며\n복구할 수 없어요.\n정말로 탈퇴하시겠어요?")
        }
    }

    private func settingMenuItem(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.customDungGeunMo(size: 16))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 32)
                .padding(.horizontal, 10)
        }
    }
}

#Preview {
    SettingsView()
}
