//
//  AddBookDetailView.swift
//  Ikdaman
//
//  Created by Soo on 3/13/26.
//

import SwiftUI

// MARK: - Add Book View
struct AddBookDetailView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: AddBookDetailViewModel
    @State private var showLogin = false

    init(bookData: Books? = nil) {
        _viewModel = StateObject(wrappedValue: AddBookDetailViewModel(bookData: bookData))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                CustomHeader(title: viewModel.isManualEntry ? "직접 입력" : "책 추가하기", showBackButton: true) {
                    Button(action: {
                        if AuthService.shared.isLogin {
                            viewModel.showAddPopup = true
                        } else {
                            showLogin = true
                        }
                    }) {
                        Text("저장")
                            .font(.customDungGeunMo(size: 16))
                            .foregroundStyle(Color.customLb)
                    }
                }

                if let book = viewModel.bookData {
                    bookDataContent(book: book)
                } else {
                    manualEntryContent
                }
            }
        }
        .background(Color.customBg)
        .navigationBarHidden(true)
        .onChange(of: viewModel.shouldDismiss) { _, value in
            if value { dismiss() }
        }
        .fullScreenCover(isPresented: $showLogin) {
            NavigationStack {
                LoginView()
            }
        }
        .overlay {
            if viewModel.showAddPopup {
                AddBookPopupView(
                    onConfirm: { reason, startDate, finishDate in
                        Task { await viewModel.saveBook(reason: reason, startDate: startDate, finishDate: finishDate) }
                    },
                    onCancel: {
                        viewModel.showAddPopup = false
                    }
                )
            } else if viewModel.showDuplicatePopup {
                DuplicateBookPopupView(
                    onConfirm: {
                        viewModel.showDuplicatePopup = false
                        dismiss()
                    },
                    onCancel: {
                        viewModel.showDuplicatePopup = false
                    }
                )
            }
        }
    }
    
    // MARK: - Manual Entry Content
    private var manualEntryContent: some View {
        VStack(spacing: 20) {
            // 책 표지 이미지
            Rectangle()
                .fill(Color.customBt)
                .frame(width: 101, height: 145)
                .overlay(
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .padding(.top, 60)
                .padding(.bottom, 10)
            
            // 제목 (필수)
            VStack(alignment: .leading, spacing: 8) {
                Text("제목(필수)")
                    .font(.customDungGeunMo(size: 14))
                
                TextField("", text: $viewModel.title)
                    .font(.customSansRegular(size: 16))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.black),
                        alignment: .bottom
                    )
            }
            
            // 작가 (필수)
            VStack(alignment: .leading, spacing: 6) {
                Text("작가(필수)")
                    .font(.customDungGeunMo(size: 14))
                TextField("", text: $viewModel.author)
                    .font(.customSansRegular(size: 16))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.black),
                        alignment: .bottom
                    )
            }
            
            // 출판사
            VStack(alignment: .leading, spacing: 6) {
                Text("출판사")
                    .font(.customDungGeunMo(size: 14))
                TextField("", text: $viewModel.publisher)
                    .font(.customSansRegular(size: 16))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.black),
                        alignment: .bottom
                    )
            }
            
            // 출간일
            VStack(alignment: .leading, spacing: 6) {
                Text("출간일")
                    .font(.customDungGeunMo(size: 14))
                TextField("", text: $viewModel.publishDate)
                    .font(.customSansRegular(size: 16))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.black),
                        alignment: .bottom
                    )
            }
            
            // ISBN
            VStack(alignment: .leading, spacing: 6) {
                Text("ISBN")
                    .font(.customDungGeunMo(size: 14))
                TextField("", text: $viewModel.isbn)
                    .font(.customSansRegular(size: 16))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.black),
                        alignment: .bottom
                    )
            }
            
            // 페이지 수
            VStack(alignment: .leading, spacing: 6) {
                Text("페이지 수")
                    .font(.customDungGeunMo(size: 14))
                TextField("", text: $viewModel.pageCount)
                    .font(.customSansRegular(size: 16))
                    .keyboardType(.numberPad)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.black),
                        alignment: .bottom
                    )
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Book Data Content
    private func bookDataContent(book: Books) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                Spacer()
                
                AsyncImage(url: URL(string: book.bookInfo.coverImage ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 180, height: 250)
                
                Spacer()
            }
            .padding(.top, 30)
            .padding(.bottom, 20)
               
            
            // 책 제목
            Text(viewModel.title)
                .font(.customSansSemiBold(size: 20))
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 8)

            // 저자 정보
            VStack(spacing: 8) {
                Text(viewModel.author)
                    .font(.customSansRegular(size: 16))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(viewModel.publisher)
                    .font(.customSansRegular(size: 16))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.bottom, 28)
            
            VStack(spacing: 20) {
                // 페이지 수
                VStack(alignment: .leading, spacing: 6) {
                    Text("페이지 수")
                        .font(.customDungGeunMo(size: 14))
                    TextField("", text: $viewModel.pageCount)
                        .font(.customSansRegular(size: 16))
                        .keyboardType(.numberPad)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .overlay(
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.black),
                            alignment: .bottom
                        )
                }
                
                // 출간일
                VStack(alignment: .leading, spacing: 8) {
                    Text("출간일")
                        .font(.customDungGeunMo(size: 14))
                    TextField("", text: $viewModel.publishDate)
                        .font(.customSansRegular(size: 16))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .overlay(
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.black),
                            alignment: .bottom
                        )
                }
                
                // ISBN
                VStack(alignment: .leading, spacing: 8) {
                    Text("ISBN")
                        .font(.customDungGeunMo(size: 14))
                    TextField("", text: $viewModel.isbn)
                        .font(.customSansRegular(size: 16))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .overlay(
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.black),
                            alignment: .bottom
                        )
                }
                
                // 책 소개
                VStack(alignment: .leading, spacing: 8) {
                    Text("책 소개")
                        .font(.customDungGeunMo(size: 14))
                    Text(viewModel.description)
                        .font(.customSansRegular(size: 16))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .overlay(
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.black),
                            alignment: .bottom
                        )
                }
                
                Button(action: {
                    // 알라딘 페이지 열기
                    if let url = URL(string: book.bookInfo.link ?? "") {
                        #if os(iOS)
                        UIApplication.shared.open(url)
                        #endif
                    }
                }) {
                    Text("알라딘에서 더보기")
                        .font(.customSansRegular(size: 16))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .overlay(
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.black),
                            alignment: .bottom
                        )
                }
            }
        }
        .padding(.horizontal, 16)
    }

}

// MARK: - Add Book Popup View
struct AddBookPopupView: View {
    let onConfirm: (String, String?, String?) -> Void
    let onCancel: () -> Void

    @State private var selectedTab = 0
    @State private var reason: String = ""
    @State private var startDate: Date = Date()
    @State private var finishDate: Date = Date()

    private let maxReasonLength = 400

    private func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // 타이틀 바
                HStack {
                    Spacer()
                    Button("X") { onCancel() }
                        .font(.customDungGeunMo(size: 12))
                        .foregroundColor(Color.customLb)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.customBt)

                VStack(alignment: .leading, spacing: 16) {
                    Text("책 추가")
                        .font(.customDungGeunMo(size: 20))
                        .foregroundColor(Color.customLb)

                    // 탭 선택
                    HStack(spacing: 0) {
                        Button(action: { selectedTab = 0 }) {
                            Text("내 서점")
                                .font(.customDungGeunMo(size: 12))
                                .foregroundColor(Color.customLb)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedTab == 0 ? Color.white : Color.customBt)
                                .overlay(
                                    Rectangle().stroke(Color.customLb, lineWidth: 0.7)
                                )
                        }
                        Button(action: { selectedTab = 1 }) {
                            Text("히스토리")
                                .font(.customDungGeunMo(size: 12))
                                .foregroundColor(Color.customLb)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedTab == 1 ? Color.white : Color.customBt)
                                .overlay(
                                    Rectangle().stroke(Color.customLb, lineWidth: 0.7)
                                )
                        }
                    }

                    if selectedTab == 0 {
                        // 내 서점 탭
                        Text("*읽고 싶은 책이에요.")
                            .font(.customDungGeunMo(size: 12))
                            .foregroundColor(Color.customLb)

                        ZStack(alignment: .bottomTrailing) {
                            TextEditor(text: Binding(
                                get: { reason },
                                set: { reason = String($0.prefix(maxReasonLength)) }
                            ))
                            .font(.customSansRegular(size: 12))
                            .frame(height: 140)
                            .padding(8)
                            .background(Color(red: 235/255, green: 235/255, blue: 245/255))
                            .scrollContentBackground(.hidden)

                            Text("\(reason.count)/\(maxReasonLength)")
                                .font(.customSansRegular(size: 10))
                                .foregroundColor(.gray)
                                .padding(.trailing, 8)
                                .padding(.bottom, 8)
                        }
                    } else {
                        // 히스토리 탭
                        Text("*독서 중이거나 완독한 책이에요.")
                            .font(.customDungGeunMo(size: 12))
                            .foregroundColor(Color.customLb)

                        HStack {
                            Text("START")
                                .font(.customDungGeunMo(size: 12))
                                .foregroundColor(Color.customLb)
                                .frame(width: 60, alignment: .leading)
                            DatePicker("", selection: $startDate, displayedComponents: .date)
                                .labelsHidden()
                        }

                        HStack {
                            Text("FINISH")
                                .font(.customDungGeunMo(size: 12))
                                .foregroundColor(Color.customLb)
                                .frame(width: 60, alignment: .leading)
                            DatePicker("", selection: $finishDate, displayedComponents: .date)
                                .labelsHidden()
                        }
                    }
                }
                .padding(16)
                .background(Color.white)

                // NO / YES 버튼
                HStack(spacing: 0) {
                    Button("NO") { onCancel() }
                        .font(.customDungGeunMo(size: 12))
                        .foregroundColor(Color.customLb)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.customBt)

                    Rectangle()
                        .frame(width: 1)
                        .foregroundColor(Color.customLb.opacity(0.3))

                    Button("YES") {
                        if selectedTab == 0 {
                            onConfirm(reason, nil, nil)
                        } else {
                            onConfirm("히스토리", dateString(startDate), dateString(finishDate))
                        }
                    }
                    .font(.customDungGeunMo(size: 12))
                    .foregroundColor(Color.customLb)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.customBt)
                }
            }
            .frame(width: 300)
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(Color.customLb, lineWidth: 1)
            )
        }
    }
}

// MARK: - Duplicate Book Popup View
struct DuplicateBookPopupView: View {
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // 타이틀 바
                HStack {
                    Spacer()
                    Button("X") { onCancel() }
                        .font(.customDungGeunMo(size: 12))
                        .foregroundColor(Color.customLb)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.customBt)

                VStack(alignment: .leading, spacing: 16) {
                    Text("중복된 책")
                        .font(.customDungGeunMo(size: 20))
                        .foregroundColor(Color.customLb)

                    Text("이미 저장한 책이에요.\n이 책 정보로 이동하시겠어요?")
                        .font(.customDungGeunMo(size: 12))
                        .foregroundColor(Color.customLb)
                        .lineSpacing(4)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)

                // NO / YES 버튼
                HStack(spacing: 0) {
                    Button("NO") { onCancel() }
                        .font(.customDungGeunMo(size: 12))
                        .foregroundColor(Color.customLb)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.customBt)

                    Rectangle()
                        .frame(width: 1)
                        .foregroundColor(Color.customLb.opacity(0.3))

                    Button("YES") { onConfirm() }
                        .font(.customDungGeunMo(size: 12))
                        .foregroundColor(Color.customLb)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.customBt)
                }
            }
            .frame(width: 280)
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(Color.customLb, lineWidth: 1)
            )
        }
    }
}
