//
//  MyLibraryView.swift
//  읽다만 iOS
//
//  Created on 2026-03-09.
//

import SwiftUI

struct MyLibraryView: View {
    @Binding var selectedTab: CustomTabBar.Tab
    @Binding var hideTabBar: Bool
    @State private var navigationPath = NavigationPath()
    @State private var sortOption = "최신순"
    @StateObject private var viewModel = MyLibraryViewModel()
    @State private var showStartReadingPopup = false
    @State private var selectedBookForReading: Books?

    let sortOptions = ["최신순", "오래된순", "제목순"]
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                VStack(spacing: 0) {
                    // MARK: - Custom Header
                    CustomHeader(title: "", showBackButton: false) {
                        Button(action: {
                            viewModel.headerButtonTapped()
                        }) {
                            Image("Cog")
                        }
                    }
                    
                    // MARK: - 상단 Empty State
                    emptyStateContent
                        .padding(.bottom, 96)
                    
                    // MARK: - 정렬 및 검색 바
                    sortAndSearchBar
                    
                    // MARK: - 책 리스트
                    VStack(spacing: 16) {
                        ForEach(viewModel.books, id: \.myBookId) { book in
                            BookRowView(
                                book: book,
                                onTap: {
                                    viewModel.viewBookDetail(book)
                                },
                                onStartReading: {
                                    selectedBookForReading = book
                                    showStartReadingPopup = true
                                },
                                onDelete: {
                                    Task {
                                        await viewModel.deleteBook(bookId: book.myBookId)
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
            .background(Color.customBg)
            .navigationBarHidden(true)
            .navigationDestination(for: String.self) { value in
                if value == "SettingView" {
                    SettingsView()
                        .onAppear { hideTabBar = true }
                        .onDisappear { hideTabBar = false }
                } else if value == "LoginView" {
                    LoginView()
                        .onAppear { hideTabBar = true }
                        .onDisappear { hideTabBar = false }
                }
            }
        }
        .task {
            await viewModel.onAppear()
        }
        .overlay {
            if showStartReadingPopup, let book = selectedBookForReading {
                StartReadingPopupView(
                    book: book,
                    onConfirm: { startDate, finishDate in
                        showStartReadingPopup = false
                        Task {
                            await viewModel.startReading(
                                bookId: book.myBookId,
                                startDate: startDate,
                                finishDate: finishDate
                            )
                        }
                    },
                    onCancel: {
                        showStartReadingPopup = false
                    }
                )
            }
        }
        .onChange(of: viewModel.shouldNavigateToSettings) { _, value in
            if value {
                if AuthService.shared.isLogin {
                    navigationPath.append("SettingView")
                } else {
                    navigationPath.append("LoginView")
                }
                viewModel.shouldNavigateToSettings = false
            }
        }
        .alert("오류", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("확인") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Empty State Content
    private var emptyStateContent: some View {
        VStack(alignment: .leading) {
            Text("지금 떠오르는\n책이 있나요...!")
                .font(.customDungGeunMo(size: 28))
                .lineSpacing(20)
                .foregroundColor(Color.customLb)
            
            Spacer()
            
            HStack {
                Spacer()
                
                Button("[+] ADD BOOK") {
                    selectedTab = .addBook
                }
                .buttonStyle(PixelButtonStyle())
            }
        }
        .padding([.horizontal, .top], 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 192)
    }
    
    // MARK: - Sort and Search Bar
    private var sortAndSearchBar: some View {
        HStack {
            Spacer()
            
            Menu {
                ForEach(sortOptions, id: \.self) { option in
                    Button(action: {
                        sortOption = option
                    }) {
                        HStack {
                            Text(option)
                            if sortOption == option {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(sortOption)
                        .font(.customDungGeunMo(size: 10))
                        .foregroundColor(Color.customLb)
                    Image("arrowDropDown")
                }
            }
            
            Button(action: {
//                showSearch.toggle()
            }) {
                Image("search")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 0)
    }
}

// MARK: - Book Row View
struct BookRowView: View {
    let book: Books
    let onTap: () -> Void
    let onStartReading: () -> Void
    let onDelete: () -> Void

    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                Rectangle()
                    .background()
                    .frame(maxWidth: .infinity, maxHeight: 1)
                
                HStack {
                    Text("NO.\(book.myBookId) (\(book.createdDate))")
                        .font(.customDungGeunMo(size: 12))
                        .foregroundColor(Color.customLb)
                        .padding(.leading, 8)
                        .padding(.vertical, 7.5)
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Button("독서 시작") {
                            onStartReading()
                        }
                        .font(.customDungGeunMo(size: 10))
                        .foregroundColor(Color.customLb)
                        
                        Image("verticalLine")
                        
                        Button("삭제") {
                            onDelete()
                        }
                        .font(.customDungGeunMo(size: 10))
                        .foregroundColor(Color.customLb)
                    }
                    .padding(.trailing, 7)
                }
                .background(Color.customBt)
            }
            
            HStack(alignment: .top, spacing: 0) {
                // 책 표지
                VStack {
//                    if let coverImage = book.bookInfo.coverImage {
                        Image(book.bookInfo.coverImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 81, height: 114)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
//                    } else {
//                        Rectangle()
//                            .fill(Color.gray.opacity(0.3))
//                            .frame(width: 81, height: 114)
//                            .overlay(
//                                Image(systemName: "book.fill")
//                                    .foregroundColor(.gray)
//                            )
//                    }
                }
                .padding(.horizontal, 14.5)
                
//                // 책 정보
                VStack(alignment: .leading, spacing: 10) {
                    // 책 제목
                    Text(book.bookInfo.title)
                        .font(.customSemiBold(size: 14))
                        .frame(height: 48, alignment: .topLeading)
                        .foregroundColor(Color.customLb)
                        .lineSpacing(4)
                        .lineLimit(2)
                        .padding(.trailing, 13)
                        .padding(.leading, 8)
                        .padding(.vertical, 6)
                    
                    // 책 설명
                    Text(book.bookInfo.description ?? "")
                        .font(.customRegular(size: 10))
                        .foregroundColor(Color.customLb)
                        .lineSpacing(4)
                        .lineLimit(3)
                        .padding(.horizontal, 10)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 164)
            .background(Color.white)
            .onTapGesture {
                onTap()
            }
        }
    }
}

// MARK: - Start Reading Popup View

struct StartReadingPopupView: View {
    let book: Books
    let onConfirm: (String, String?) -> Void
    let onCancel: () -> Void

    @State private var startDate: Date = Date()
    @State private var finishDate: Date? = nil

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
                    Text("팝업 – 책 시작하기")
                        .font(.customDungGeunMo(size: 12))
                        .foregroundColor(Color.customLb)
                    Spacer()
                    Button("X") {
                        onCancel()
                    }
                    .font(.customDungGeunMo(size: 12))
                    .foregroundColor(Color.customLb)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.customBt)

                VStack(alignment: .leading, spacing: 16) {
                    // 섹션 헤더
                    Text("책 시작하기")
                        .font(.customDungGeunMo(size: 14))
                        .foregroundColor(Color.customLb)

                    // 책 제목
                    Text(book.bookInfo.title)
                        .font(.customRegular(size: 10))
                        .foregroundColor(Color.customLb)
                        .lineLimit(2)

                    // START 날짜
                    HStack {
                        Text("START")
                            .font(.customDungGeunMo(size: 12))
                            .foregroundColor(Color.customLb)
                            .frame(width: 60, alignment: .leading)

                        DatePicker("", selection: $startDate, displayedComponents: .date)
                            .labelsHidden()
                            .font(.customDungGeunMo(size: 12))
                    }

                    // FINISH 날짜
                    HStack {
                        Text("FINISH")
                            .font(.customDungGeunMo(size: 12))
                            .foregroundColor(Color.customLb)
                            .frame(width: 60, alignment: .leading)

                        if let finish = finishDate {
                            DatePicker("", selection: Binding(
                                get: { finish },
                                set: { finishDate = $0 }
                            ), displayedComponents: .date)
                            .labelsHidden()
                            .font(.customDungGeunMo(size: 12))

                            Button("X") {
                                finishDate = nil
                            }
                            .font(.customDungGeunMo(size: 10))
                            .foregroundColor(Color.customLb)
                        } else {
                            Button("읽는 중  ▼") {
                                finishDate = Date()
                            }
                            .font(.customDungGeunMo(size: 12))
                            .foregroundColor(Color.customLb)
                        }
                    }
                }
                .padding(16)
                .background(Color.white)

                // NO / YES 버튼
                HStack(spacing: 0) {
                    Button("NO") {
                        onCancel()
                    }
                    .font(.customDungGeunMo(size: 12))
                    .foregroundColor(Color.customLb)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.customBt)

                    Rectangle()
                        .frame(width: 1)
                        .foregroundColor(Color.customLb.opacity(0.3))

                    Button("YES") {
                        let finish = finishDate.map { dateString($0) }
                        onConfirm(dateString(startDate), finish)
                    }
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

// MARK: - Preview
#Preview {
//    MyLibraryView(selectedTab: .constant(.addBook), hideTabBar: .)
}
