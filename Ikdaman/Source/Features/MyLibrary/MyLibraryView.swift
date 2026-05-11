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
    @StateObject private var viewModel = MyLibraryViewModel()
    @State private var showStartReadingPopup = false
    @State private var selectedBookForReading: Books?

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
                                    navigationPath.append(book.myBookId)
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
                    .padding(.bottom, 56)
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
                } else if value == "SearchView" {
                    MyBookSearchView()
                        .onAppear { hideTabBar = true }
                        .onDisappear { hideTabBar = false }
                }
            }
            .navigationDestination(for: Int.self) { myBookId in
                BookDetailView(book: Books(myBookId: myBookId))
                    .onAppear { hideTabBar = true }
                    .onDisappear { hideTabBar = false }
            }
        }
        .task {
            await viewModel.onAppear()
        }
        .onChange(of: AuthService.shared.authState) { _, _ in
            Task { await viewModel.onAppear() }
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

            Button(action: {
                viewModel.changeSortType(to: viewModel.sortType == .latest ? .oldest : .latest)
            }) {
                HStack(spacing: 4) {
                    Text(viewModel.sortType == .latest ? "최신순" : "오래된순")
                        .font(.customDungGeunMo(size: 10))
                        .foregroundColor(Color.customLb)
                    Image("arrowDropDown")
                }
            }

            Button(action: {
                navigationPath.append("SearchView")
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

    private func formattedDate(_ raw: String) -> String {
        let input = DateFormatter()
        input.locale = Locale(identifier: "en_US_POSIX")
        let output = DateFormatter()
        output.dateFormat = "yyyy.MM.dd"
        for fmt in ["yyyy-MM-dd'T'HH:mm:ss.SSSSSS", "yyyy-MM-dd'T'HH:mm:ss", "yyyy-MM-dd"] {
            input.dateFormat = fmt
            if let date = input.date(from: raw) { return output.string(from: date) }
        }
        return raw
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                Rectangle()
                    .background()
                    .frame(maxWidth: .infinity, maxHeight: 1)
                
                HStack {
                    Text("NO.\(book.myBookId) (\(formattedDate(book.createdDate)))")
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
                    AsyncImage(url: URL(string: book.bookInfo.coverImage ?? "")) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 81, height: 114)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        case .failure, .empty:
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 81, height: 114)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(width: 81, height: 114)
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
    @State private var showStartPicker = false
    @State private var showFinishPicker = false

    private func dateString(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: date)
    }

    private func displayString(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy.MM.dd"
        return f.string(from: date)
    }

    var body: some View {
        Color.black.opacity(0.4)
            .ignoresSafeArea()
            .overlay {
                VStack(spacing: 0) {
                    // 타이틀 바
                    HStack {
                        Text("팝업 – 책 시작하기")
                            .font(.customDungGeunMo(size: 12))
                            .foregroundColor(Color.customLb)
                        Spacer()
                        Button("X") { onCancel() }
                            .font(.customDungGeunMo(size: 12))
                            .foregroundColor(Color.customLb)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.customBt)

                    // 본문
                    VStack(alignment: .leading, spacing: 16) {
                        Text("책 시작하기")
                            .font(.customDungGeunMo(size: 14))
                            .foregroundColor(Color.customLb)

                        Text(book.bookInfo.title)
                            .font(.customRegular(size: 10))
                            .foregroundColor(Color.customLb)
                            .lineLimit(2)

                        // START
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 12) {
                                Text("START")
                                    .font(.customDungGeunMo(size: 12))
                                    .foregroundColor(Color.customLb)
                                    .frame(width: 50, alignment: .leading)

                                Button(action: {
                                    showStartPicker.toggle()
                                    if showStartPicker { showFinishPicker = false }
                                }) {
                                    HStack {
                                        Text(displayString(startDate))
                                            .font(.customDungGeunMo(size: 12))
                                            .foregroundColor(Color.customLb)
                                        Spacer()
                                        Text("▼")
                                            .font(.customDungGeunMo(size: 10))
                                            .foregroundColor(Color.customLb)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 6)
                                    .overlay(Rectangle().stroke(Color.customLb, lineWidth: 1))
                                }
                            }

                            if showStartPicker {
                                DatePicker("", selection: $startDate, displayedComponents: .date)
                                    .datePickerStyle(.graphical)
                                    .labelsHidden()
                                    .tint(Color.customLb)
                            }
                        }

                        // FINISH
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 12) {
                                Text("FINISH")
                                    .font(.customDungGeunMo(size: 12))
                                    .foregroundColor(Color.customLb)
                                    .frame(width: 50, alignment: .leading)

                                Button(action: {
                                    if finishDate == nil { finishDate = Date() }
                                    showFinishPicker.toggle()
                                    if showFinishPicker { showStartPicker = false }
                                }) {
                                    HStack {
                                        Text(finishDate.map { displayString($0) } ?? "읽는 중")
                                            .font(.customDungGeunMo(size: 12))
                                            .foregroundColor(Color.customLb)
                                        Spacer()
                                        Text("▼")
                                            .font(.customDungGeunMo(size: 10))
                                            .foregroundColor(Color.customLb)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 6)
                                    .overlay(Rectangle().stroke(Color.customLb, lineWidth: 1))
                                }
                            }

                            if showFinishPicker, let finish = finishDate {
                                DatePicker("", selection: Binding(
                                    get: { finish },
                                    set: { finishDate = $0 }
                                ), displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .labelsHidden()
                                .tint(Color.customLb)

                                Button("읽는 중으로 변경") {
                                    finishDate = nil
                                    showFinishPicker = false
                                }
                                .font(.customDungGeunMo(size: 10))
                                .foregroundColor(Color.customLb.opacity(0.6))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color.white)

                    // NO / YES
                    HStack(spacing: 0) {
                        Button("NO") { onCancel() }
                            .font(.customDungGeunMo(size: 12))
                            .foregroundColor(Color.customLb)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.customBt)

                        Color.customLb.opacity(0.3)
                            .frame(width: 1)

                        Button("YES") {
                            onConfirm(dateString(startDate), finishDate.map { dateString($0) })
                        }
                        .font(.customDungGeunMo(size: 12))
                        .foregroundColor(Color.customLb)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.customBt)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                }
                .frame(width: 280)
                .border(Color.customLb, width: 1)
            }
    }
}

// MARK: - Preview
#Preview {
//    MyLibraryView(selectedTab: .constant(.addBook), hideTabBar: .)
}
