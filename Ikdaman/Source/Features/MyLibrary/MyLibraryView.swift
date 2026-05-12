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
    @State private var showDeletePopup = false
    @State private var selectedBookForDelete: Books?

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
                    if viewModel.books.isEmpty {
                        emptyBookList
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            .padding(.bottom, 56)
                    } else {
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
                                        selectedBookForDelete = book
                                        showDeletePopup = true
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 56)
                    }
                }
            }
            .background(Color.customBg)
            .navigationBarHidden(true)
            .onAppear { hideTabBar = false }
            .navigationDestination(for: String.self) { value in
                if value == "SettingView" {
                    SettingsView()
                        .onAppear { hideTabBar = true }
                        .onDisappear { hideTabBar = false }
                } else if value == "LoginView" {
                    LoginView(hideTabBar: $hideTabBar)
                        .onAppear { hideTabBar = true }
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
        .onChange(of: AuthService.shared.didJustSignup) { _, didSignup in
            if didSignup {
                ToastManager.shared.show("가입을 축하드려요!!")
                AuthService.shared.didJustSignup = false
            }
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
            } else if showDeletePopup, let book = selectedBookForDelete {
                DeleteBookPopupView(
                    onConfirm: {
                        showDeletePopup = false
                        Task { await viewModel.deleteBook(bookId: book.myBookId) }
                    },
                    onCancel: {
                        showDeletePopup = false
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
    
    // MARK: - Empty Book List
    private var emptyBookList: some View {
        VStack(spacing: 0) {
            // 헤더 행
            VStack(spacing: 0) {
                Rectangle()
                    .background()
                    .frame(maxWidth: .infinity, maxHeight: 1)
                HStack {
                    Text("NO.00 (0000.00.00)")
                        .font(.customDungGeunMo(size: 12))
                        .foregroundColor(Color.customLb)
                        .padding(.leading, 8)
                        .padding(.vertical, 7.5)
                    Spacer()
                }
                .background(Color.customBt)
            }
            // 본문 카드
            HStack(spacing: 20) {
                Image("moaBook")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 58, height: 58)
                    .padding(.leading, 14.5)

                VStack(alignment: .leading, spacing: 8) {
                    Text("지금 읽고 싶은 책을 저장하기")
                        .font(.customSansSemiBold(size: 16))
                        .foregroundColor(Color.customLb)
                    Text("왜 읽고 싶었는지, 같이 남겨두세요.")
                        .font(.customSansRegular(size: 14))
                        .foregroundColor(Color.customLb)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 164)
            .background(Color.white)
        }
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
    @State private var showStartCalendar = false
    @State private var calX: CGFloat = 0
    @State private var calY: CGFloat = 0

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
                    // 상단 타이틀 바 (회색 빈 바 + X 버튼)
                    HStack(spacing: 0) {
                        Color.customBt
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .border(Color.black, width: 1)
                        Button("X") { onCancel() }
                            .font(.customDungGeunMo(size: 12))
                            .foregroundColor(Color.customLb)
                            .frame(width: 29, height: 28)
                            .background(Color.customBt)
                            .border(Color.black, width: 1)
                    }
                    .frame(height: 28)

                    // 본문
                    VStack(alignment: .leading, spacing: 0) {
                        Text("책 시작하기")
                            .font(.customDungGeunMo(size: 20))
                            .foregroundColor(Color.customLb)

                        Spacer().frame(height: 35)

                        Text(book.bookInfo.title)
                            .font(.customSansRegular(size: 16))
                            .foregroundColor(Color.customLb)
                            .lineLimit(2)

                        Spacer().frame(height: 30)

                        // START
                        HStack {
                            Spacer()
                            HStack(spacing: 8) {
                                Text("START")
                                    .font(.customDungGeunMo(size: 12))
                                    .foregroundColor(Color.customLb)
                                    .frame(width: 64, alignment: .leading)

                                Button(action: { showStartCalendar.toggle() }) {
                                    HStack(spacing: 0) {
                                        Text(displayString(startDate))
                                            .font(.customDungGeunMo(size: 12))
                                            .foregroundColor(Color.customLb)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.horizontal, 10)
                                            .frame(height: 28)
                                        Color.customBt
                                            .frame(width: 28, height: 28)
                                            .overlay(Text("▼").font(.customDungGeunMo(size: 10)).foregroundColor(Color.customLb))
                                    }
                                    .background(Color.white)
                                    .retroPixelBorder()
                                }
                                .frame(width: 208)
                                .background(GeometryReader { geo in
                                    Color.clear.onAppear {
                                        let f = geo.frame(in: .named("sPopup"))
                                        calX = f.minX
                                        calY = f.maxY
                                    }
                                })
                            }
                            Spacer()
                        }

                        Spacer().frame(height: 16)

                        // FINISH (비대화형 - 읽는 중 고정)
                        HStack {
                            Spacer()
                            HStack(spacing: 8) {
                                Text("FINISH")
                                    .font(.customDungGeunMo(size: 12))
                                    .foregroundColor(Color.customLb)
                                    .frame(width: 64, alignment: .leading)

                                HStack(spacing: 0) {
                                    Text("읽는 중")
                                        .font(.customDungGeunMo(size: 12))
                                        .foregroundColor(Color.customLb.opacity(0.4))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, 10)
                                        .frame(height: 28)
                                    Color.customBt
                                        .frame(width: 28, height: 28)
                                        .overlay(Text("▼").font(.customDungGeunMo(size: 10)).foregroundColor(Color.customLb))
                                }
                                .frame(width: 208)
                                .background(Color.white)
                                .retroPixelBorder()
                            }
                            Spacer()
                        }

                        Spacer().frame(height: 43)

                        // NO / YES 버튼
                        HStack {
                            Spacer()
                            Button(action: { onCancel() }) {
                                Text("NO")
                                    .font(.customDungGeunMo(size: 12))
                                    .foregroundColor(Color.customLb)
                                    .padding(.horizontal, 16).padding(.vertical, 4)
                                    .background(Color.customBt)
                                    .retroPixelBorder()
                            }
                            Spacer().frame(width: 50)
                            Button(action: { onConfirm(dateString(startDate), nil) }) {
                                Text("YES")
                                    .font(.customDungGeunMo(size: 12))
                                    .foregroundColor(Color.customLb)
                                    .padding(.horizontal, 16).padding(.vertical, 4)
                                    .background(Color.customBt)
                                    .retroPixelBorder()
                            }
                            Spacer()
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.customBg)
                }
                .coordinateSpace(name: "sPopup")
                .retroPopupShadow()
                .overlay(alignment: .topLeading) {
                    if showStartCalendar {
                        RetroCalendarDropdown(date: $startDate, onDismiss: { showStartCalendar = false })
                            .frame(width: 208)
                            .offset(x: calX, y: calY)
                    }
                }
                .padding(.horizontal, 16)
                .fixedSize(horizontal: false, vertical: true)
            }
    }
}
// MARK: - Delete Book Popup View

struct DeleteBookPopupView: View {
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        Color.black.opacity(0.4)
            .ignoresSafeArea()
            .overlay {
                VStack(spacing: 0) {
                    // 타이틀 바
                    HStack(spacing: 0) {
                        Color.customBt
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .border(Color.black, width: 1)
                        Button("X") { onCancel() }
                            .font(.customDungGeunMo(size: 12))
                            .foregroundColor(Color.customLb)
                            .frame(width: 29, height: 28)
                            .background(Color.customBt)
                            .border(Color.black, width: 1)
                    }
                    .frame(height: 28)

                    // 본문
                    VStack(alignment: .leading, spacing: 0) {
                        Text("책 삭제")
                            .font(.customDungGeunMo(size: 18))
                            .foregroundColor(Color.customLb)

                        Spacer().frame(height: 24)

                        Text("책을 삭제하면 모든 기록이 사라져요!\n정말로 삭제하시겠어요?")
                            .font(.customDungGeunMo(size: 14))
                            .foregroundColor(Color.customLb)
                            .lineSpacing(0)

                        Spacer().frame(height: 32)

                        HStack {
                            Spacer()
                            Button(action: { onCancel() }) {
                                Text("NO")
                                    .font(.customDungGeunMo(size: 12))
                                    .foregroundColor(Color.customLb)
                                    .padding(.horizontal, 16).padding(.vertical, 4)
                                    .background(Color.customBt)
                                    .retroPixelBorder()
                            }
                            Spacer().frame(width: 50)
                            Button(action: { onConfirm() }) {
                                Text("YES")
                                    .font(.customDungGeunMo(size: 12))
                                    .foregroundColor(Color.customLb)
                                    .padding(.horizontal, 16).padding(.vertical, 4)
                                    .background(Color.customBt)
                                    .retroPixelBorder()
                            }
                            Spacer()
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.customBg)
                }
                .retroPopupShadow()
                .padding(.horizontal, 16)
                .fixedSize(horizontal: false, vertical: true)
            }
    }
}

// MARK: - Preview
//#Preview {
////    MyLibraryView(selectedTab: .constant(.addBook), hideTabBar: .)
//}
