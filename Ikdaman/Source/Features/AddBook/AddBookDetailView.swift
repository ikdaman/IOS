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
                        if viewModel.isManualEntry && (viewModel.title.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.author.trimmingCharacters(in: .whitespaces).isEmpty) {
                            ToastManager.shared.show("제목과 작가는 필수입니다.")
                            return
                        }
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
        .alert("오류", isPresented: Binding<Bool>(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("확인", role: .cancel) { }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
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
                
                if let coverStr = book.bookInfo.coverImage {
                    URLImageView(urlString: coverStr)
                        .frame(width: 180, height: 250)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 180, height: 250)
                        .overlay(Text("URL 없음").font(.caption))
                }
                
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
    @State private var finishDate: Date? = nil
    @State private var showStartCalendar = false
    @State private var showFinishCalendar = false
    @State private var startCalX: CGFloat = 0
    @State private var startCalY: CGFloat = 0
    @State private var finishCalX: CGFloat = 0
    @State private var finishCalY: CGFloat = 0

    private let maxReasonLength = 400

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
                        Text("책 추가")
                            .font(.customDungGeunMo(size: 20))
                            .foregroundColor(Color.customLb)

                        Spacer().frame(height: 16)

                        // 탭 선택
                        HStack(spacing: 6) {
                            addTabButton(title: "내 서점", isSelected: selectedTab == 0) { selectedTab = 0 }
                            addTabButton(title: "히스토리", isSelected: selectedTab == 1) { selectedTab = 1 }
                        }

                        Spacer().frame(height: 16)

                        if selectedTab == 0 {
                            Text("*읽고 싶은 책이에요.")
                                .font(.customDungGeunMo(size: 12))
                                .foregroundColor(Color.customLb)
                            Spacer().frame(height: 8)
                            TextEditor(text: Binding(
                                get: { reason },
                                set: { reason = String($0.prefix(maxReasonLength)) }
                            ))
                            .font(.customSansRegular(size: 14))
                            .frame(height: 188)
                            .padding(8)
                            .background(Color.white)
                            .border(Color.black, width: 1)
                            .scrollContentBackground(.hidden)
                            Spacer().frame(height: 4)
                            Text("\(reason.count)/\(maxReasonLength)")
                                .font(.customDungGeunMo(size: 10))
                                .foregroundColor(Color.customLb.opacity(0.5))
                        } else {
                            Text("*독서 중이거나 완독한 책이에요.")
                                .font(.customDungGeunMo(size: 12))
                                .foregroundColor(Color.customLb)

                            Spacer().frame(height: 16)

                            // START
                            HStack {
                                Spacer()
                                HStack(spacing: 8) {
                                    Text("START")
                                        .font(.customDungGeunMo(size: 12))
                                        .foregroundColor(Color.customLb)
                                        .frame(width: 64, alignment: .leading)
                                    Button(action: {
                                        showStartCalendar.toggle()
                                        if showStartCalendar { showFinishCalendar = false }
                                    }) {
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
                                            let f = geo.frame(in: .named("addPopup"))
                                            startCalX = f.minX
                                            startCalY = f.maxY
                                        }
                                    })
                                }
                                Spacer()
                            }

                            Spacer().frame(height: 16)

                            // FINISH
                            HStack {
                                Spacer()
                                HStack(spacing: 8) {
                                    Text("FINISH")
                                        .font(.customDungGeunMo(size: 12))
                                        .foregroundColor(Color.customLb)
                                        .frame(width: 64, alignment: .leading)
                                    Button(action: {
                                        showFinishCalendar.toggle()
                                        if showFinishCalendar { showStartCalendar = false }
                                    }) {
                                        HStack(spacing: 0) {
                                            Text(finishDate.map { displayString($0) } ?? "읽는 중")
                                                .font(.customDungGeunMo(size: 12))
                                                .foregroundColor(finishDate != nil ? Color.customLb : Color.customLb.opacity(0.4))
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
                                            let f = geo.frame(in: .named("addPopup"))
                                            finishCalX = f.minX
                                            finishCalY = f.maxY
                                        }
                                    })
                                }
                                Spacer()
                            }
                        }

                        Spacer().frame(height: 32)

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
                            Button(action: {
                                if selectedTab == 0 {
                                    onConfirm(reason, nil, nil)
                                } else {
                                    onConfirm(reason, dateString(startDate), finishDate.map { dateString($0) })
                                }
                            }) {
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
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.customBg)
                }
                .coordinateSpace(name: "addPopup")
                .retroPopupShadow()
                .overlay(alignment: .topLeading) {
                    if showStartCalendar {
                        RetroCalendarDropdown(date: $startDate, onDismiss: { showStartCalendar = false })
                            .frame(width: 208)
                            .offset(x: startCalX, y: startCalY)
                    }
                }
                .overlay(alignment: .topLeading) {
                    if showFinishCalendar {
                        RetroCalendarDropdownOptional(
                            date: $finishDate,
                            initialDate: finishDate ?? Date(),
                            onDismiss: { showFinishCalendar = false }
                        )
                        .frame(width: 208)
                        .offset(x: finishCalX, y: finishCalY)
                    }
                }
                .padding(.horizontal, 16)
                .fixedSize(horizontal: false, vertical: true)
            }
    }

    private func addTabButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.customDungGeunMo(size: 12))
                .foregroundColor(Color.customLb)
                .padding(.horizontal, 12).padding(.vertical, 4)
                .background(isSelected ? Color(hex: "#E4E4E4") : Color.customBt)
                .overlay(alignment: .top) { Rectangle().fill(isSelected ? Color.black : Color.white).frame(height: 1) }
                .overlay(alignment: .leading) { Rectangle().fill(isSelected ? Color.black : Color.white).frame(width: 1) }
                .overlay(alignment: .bottom) { Rectangle().fill(isSelected ? Color.white : Color.black).frame(height: 1) }
                .overlay(alignment: .trailing) { Rectangle().fill(isSelected ? Color.white : Color.black).frame(width: 1) }
                .padding(.trailing, isSelected ? 0 : 1).padding(.bottom, isSelected ? 0 : 1)
                .background(isSelected ? Color.clear : Color.black)
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
                HStack(spacing: 0) {
                    Spacer()
                    Rectangle()
                        .frame(width: 1)
                        .foregroundColor(Color.customLb)
                    Button(action: { onCancel() }) {
                        Text("X")
                            .font(.customDungGeunMo(size: 12))
                            .foregroundColor(Color.customLb)
                            .frame(width: 30, height: 30)
                    }
                }
                .frame(height: 30)
                .background(Color.customBt)
                .overlay(
                    Rectangle().frame(height: 1).foregroundColor(Color.customLb),
                    alignment: .bottom
                )

                VStack(alignment: .leading, spacing: 16) {
                    Text("중복된 책")
                        .font(.customDungGeunMo(size: 20))
                        .foregroundColor(Color.customLb)
                        .padding(.top, 16)

                    Text("이미 저장한 책이에요.\n이 책 정보로 이동하시겠어요?")
                        .font(.customDungGeunMo(size: 12))
                        .foregroundColor(Color.customLb)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, alignment: .leading)

                // NO / YES 버튼
                HStack(spacing: 30) {
                    Button(action: { onCancel() }) {
                        Text("NO")
                            .font(.customDungGeunMo(size: 12))
                            .foregroundColor(Color.customLb)
                            .frame(width: 80, height: 30)
                            .background(Color.customBt)
                            .overlay(Rectangle().stroke(Color.customLb, lineWidth: 1))
                    }

                    Button(action: { onConfirm() }) {
                        Text("YES")
                            .font(.customDungGeunMo(size: 12))
                            .foregroundColor(Color.customLb)
                            .frame(width: 80, height: 30)
                            .background(Color.customBt)
                            .overlay(Rectangle().stroke(Color.customLb, lineWidth: 1))
                    }
                }
                .padding(.top, 24)
                .padding(.bottom, 24)
            }
            .background(Color.customBg)
            .frame(width: 280)
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(Color.customLb, lineWidth: 1)
            )
        }
    }
}

// MARK: - Custom Image Loader (To fix AsyncImage cancellation bug)
struct URLImageView: View {
    let urlString: String
    @State private var image: UIImage? = nil
    @State private var isLoading: Bool = false
    @State private var errorMsg: String? = nil
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else if isLoading {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(ProgressView())
            } else if let errorMsg = errorMsg {
                Rectangle()
                    .fill(Color.red.opacity(0.3))
                    .overlay(
                        VStack {
                            Text("오류")
                                .font(.caption)
                            Text(errorMsg)
                                .font(.caption2)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                    )
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(Text("URL 없음").font(.caption))
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        guard let url = URL(string: urlString) else {
            errorMsg = "Invalid URL"
            return
        }
        isLoading = true
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error as? URLError {
                    if error.code == .cancelled { return }
                    self.errorMsg = error.localizedDescription
                    return
                } else if let error = error {
                    self.errorMsg = error.localizedDescription
                    return
                }
                
                if let data = data, let uiImage = UIImage(data: data) {
                    self.image = uiImage
                } else {
                    self.errorMsg = "Data is not an image"
                }
            }
        }.resume()
    }
}
