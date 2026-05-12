//
//  BookDetailView.swift
//  Ikdaman
//
//  Created by Soo on 3/13/26.
//

import SwiftUI

struct BookDetailView: View {
    @StateObject private var viewModel: BookDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showEditPopup = false
    @State private var editInitialTab = 0
    @State private var showDeleteConfirmation = false

    init(book: Books) {
        _viewModel = StateObject(wrappedValue: BookDetailViewModel(book: book))
    }

    var body: some View {
        VStack(spacing: 0) {
            CustomHeader(title: "", showBackButton: true) {
                Button("삭제") {
                    showDeleteConfirmation = true
                }
                .font(.customDungGeunMo(size: 16))
                .foregroundColor(.black)
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 책 표지 및 기본 정보
                    HStack(alignment: .top) {
                        Spacer()
                        
                        AsyncImage(url: URL(string: (viewModel.book.bookInfo.coverImage ?? "")
                            .replacingOccurrences(of: "http://", with: "https://")
                            .replacingOccurrences(of: "/coversum/", with: "/cover/"))) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 201, height: 272)
                                    .clipped()
                            default:
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 201, height: 272)
                            }
                        }
                        .frame(width: 201, height: 272)
                        .border(Color.black, width: 1)
                        
                        Spacer()
                    }
                    .padding(.top, 30)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text({
                            switch viewModel.readingStatus {
                            case "TODO": return "읽고 싶은 책"
                            case "INPROGRESS": return "읽는 중"
                            case "DONE": return "완독"
                            default: return "읽고 싶은 책"
                            }
                        }())
                            .font(.customDungGeunMo(size: 12))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(viewModel.readingStatus == "TODO" ? Color(hex: "#010196") : Color(hex: "#333333"))

                        Text(viewModel.book.bookInfo.title)
                            .font(.customSemiBold(size: 18))
                            .lineLimit(3)

                        Text(viewModel.book.bookInfo.author)
                            .font(.customRegular(size: 14))
                        
                        Text(viewModel.book.bookInfo.publisher ?? "")
                            .font(.customRegular(size: 14))
                    }
                    .padding(.top, 2)
                    .padding(.bottom, 10)
                    
                    // 독서 이력 섹션
                    VStack(spacing: 0) {
                        SectionHeader(title: "독서 이력", onEdit: {
                            editInitialTab = 1
                            showEditPopup = true
                        })
                        VStack(alignment: .leading, spacing: 8) {
                            historyRow(label: "SAVE", value: viewModel.savedDate)
                            historyRow(label: "START", value: viewModel.startedDate)
                            historyRow(label: "FINISH", value: viewModel.finishedDate)
                        }
                        .padding(15)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .pixelBorder()
                    }
                    
                    // 읽고 싶었던 이유
                    VStack(spacing: 0) {
                        SectionHeader(title: "읽고 싶었던 이유", onEdit: {
                            editInitialTab = 0
                            showEditPopup = true
                        })
                        Text(viewModel.book.reason.isEmpty ? "이유를 입력해주세요" : viewModel.book.reason)
                            .font(.customRegular(size: 14))
                            .padding(15)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .pixelBorder()
                    }
                    
                    // 상세 제원 (페이지, 출간일, ISBN)
//                    InfoField(label: "페이지 수", value: "\($viewModel.book.totalPages)")
                    InfoField(label: "출간일", value: "2020 - 04 - 20")
                    InfoField(label: "ISBN", value: viewModel.book.bookInfo.isbn ?? "")
                    
                    // 책 소개
                    VStack(alignment: .leading, spacing: 6) {
                        Text("책 소개")
                            .font(.customDungGeunMo(size: 14))
                        
                        Text(viewModel.book.bookInfo.description ?? "")
                            .font(.customSansRegular(size: 16))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity, minHeight: 46, alignment: .leading)
                            .background(Color.white)
                            .pixelBorder()
                    }
                    .frame(maxWidth: .infinity)
                    
                    // 하단 버튼
                    Button {
                        
                    } label: {
                        Text("알라딘에서 더보기")
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .background(Color.white)
                            .pixelBorder()
                            .font(.customSansRegular(size: 16))
                            .foregroundColor(.black)
                    }
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 20)
            }
        }
        .background(Color.customBg)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await viewModel.onAppear()
        }
        .onChange(of: viewModel.shouldDismiss) { _, value in
            if value { dismiss() }
        }
        .overlay {
            if showEditPopup {
                BookDetailEditPopupView(
                    initialTab: editInitialTab,
                    readingStatus: viewModel.readingStatus,
                    currentReason: viewModel.book.reason,
                    rawStartedDate: viewModel.rawStartedDate,
                    rawFinishedDate: viewModel.rawFinishedDate,
                    onConfirm: { tab, reason, startedDate, finishedDate in
                        showEditPopup = false
                        Task {
                            if tab == 1 {
                                await viewModel.updateReadingHistory(
                                    startedDate: startedDate,
                                    finishedDate: finishedDate
                                )
                            } else {
                                await viewModel.updateReason(reason)
                            }
                        }
                    },
                    onCancel: { showEditPopup = false }
                )
            }
        }
        .overlay {
            if showDeleteConfirmation {
                DeleteConfirmationView(
                    onConfirm: {
                        showDeleteConfirmation = false
                        Task { await viewModel.deleteBook() }
                    },
                    onCancel: { showDeleteConfirmation = false }
                )
            }
        }
        .alert("오류", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("확인") { viewModel.errorMessage = nil }
        } message: {
            if let msg = viewModel.errorMessage { Text(msg) }
        }
    }

    private func historyRow(label: String, value: String) -> some View {
        HStack(spacing: 10) {
            Text(label)
                .font(.customDungGeunMo(size: 16))
                .frame(width: 74, alignment: .leading)
            Text(value)
                .font(.customRegular(size: 16))
        }
    }
}

struct SectionHeader: View {
    let title: String
    var showEdit: Bool = true
    var onEdit: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(title)
                .font(.customDungGeunMo(size: 14))
            Spacer()
            if showEdit {
                Button("수정") {
                    onEdit?()
                }
                .font(.customDungGeunMo(size: 14))
                .foregroundStyle(.black)
                .frame(width: 44, height: 22, alignment: .center)
                .border(Color.black, width: 1)
            }
        }
        .padding(.leading, 10)
        .frame(height: 22)
        .background(Color.customBt)
        .border(Color.black, width: 1)
    }
}

// 정보 표시 박스 (페이지, 출간일, ISBN 등)
struct InfoField: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.customDungGeunMo(size: 14))

            Text(value)
                .font(.customSansRegular(size: 16))
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
                .background(Color.white)
                .pixelBorder()
        }
    }
}

// MARK: - Book Detail Edit Popup

struct BookDetailEditPopupView: View {
    let initialTab: Int
    let readingStatus: String
    let currentReason: String
    let rawStartedDate: String?
    let rawFinishedDate: String?
    let onConfirm: (Int, String, String?, String?) -> Void
    let onCancel: () -> Void

    @State private var selectedTab: Int
    @State private var reason: String
    @State private var startDate: Date
    @State private var finishDate: Date?
    @State private var showStartCalendar = false
    @State private var showFinishCalendar = false
    @State private var startCalX: CGFloat = 0
    @State private var startCalY: CGFloat = 0
    @State private var finishCalX: CGFloat = 0
    @State private var finishCalY: CGFloat = 0

    private let maxReasonLength = 400

    init(
        initialTab: Int,
        readingStatus: String,
        currentReason: String,
        rawStartedDate: String?,
        rawFinishedDate: String?,
        onConfirm: @escaping (Int, String, String?, String?) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.initialTab = initialTab
        self.readingStatus = readingStatus
        self.currentReason = currentReason
        self.rawStartedDate = rawStartedDate
        self.rawFinishedDate = rawFinishedDate
        self.onConfirm = onConfirm
        self.onCancel = onCancel
        _selectedTab = State(initialValue: initialTab)
        _reason = State(initialValue: currentReason)
        _startDate = State(initialValue: Self.parseDate(rawStartedDate))
        _finishDate = State(initialValue: rawFinishedDate.map { Self.parseDate($0) })
    }

    private static func parseDate(_ raw: String?) -> Date {
        guard let raw, !raw.isEmpty else { return Date() }
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        for fmt in ["yyyy-MM-dd'T'HH:mm:ss.SSSSSS", "yyyy-MM-dd'T'HH:mm:ss'Z'", "yyyy-MM-dd'T'HH:mm:ss", "yyyy-MM-dd"] {
            f.dateFormat = fmt
            if let date = f.date(from: raw) { return date }
        }
        return Date()
    }

    private func toISO8601(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: date)
    }

    private func displayString(_ date: Date) -> String {
        let f = DateFormatter()
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
                        Text("책 정보 수정")
                            .font(.customDungGeunMo(size: 20))
                            .foregroundColor(Color.customLb)

                        Spacer().frame(height: 16)

                        // 탭 선택
                        HStack(spacing: 6) {
                            editTabButton(title: "내 서점", isSelected: selectedTab == 0) {
                                selectedTab = 0
                            }
                            editTabButton(title: "히스토리", isSelected: selectedTab == 1) {
                                selectedTab = 1
                            }
                        }

                        Spacer().frame(height: 16)

                        if selectedTab == 0 {
                            // 내 서점 탭
                            Text(readingStatus == "TODO" ? "*읽고 싶은 책이에요." : "*독서 중이거나 완독한 책이에요.")
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
                            // 히스토리 탭
                            Text(readingStatus == "TODO" ? "*읽고 싶은 책이에요." : "*독서 중이거나 완독한 책이에요.")
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
                                            let f = geo.frame(in: .named("ePopup"))
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
                                            let f = geo.frame(in: .named("ePopup"))
                                            finishCalX = f.minX
                                            finishCalY = f.maxY
                                        }
                                    })
                                }
                                Spacer()
                            }

                            Spacer().frame(height: 24)

                            Text("읽고 싶은 이유")
                                .font(.customDungGeunMo(size: 12))
                                .foregroundColor(Color.customLb)
                            Spacer().frame(height: 8)
                            TextEditor(text: Binding(
                                get: { reason },
                                set: { reason = String($0.prefix(maxReasonLength)) }
                            ))
                            .font(.customSansRegular(size: 14))
                            .frame(height: 120)
                            .padding(8)
                            .background(Color(hex: "#F5F5F5"))
                            .scrollContentBackground(.hidden)
                            Spacer().frame(height: 4)
                            Text("\(reason.count)/\(maxReasonLength)")
                                .font(.customDungGeunMo(size: 10))
                                .foregroundColor(Color.customLb.opacity(0.5))
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
                                if selectedTab == 1 {
                                    onConfirm(1, reason, toISO8601(startDate), finishDate.map { toISO8601($0) })
                                } else {
                                    onConfirm(0, reason, nil, nil)
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
                .coordinateSpace(name: "ePopup")
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

    private func editTabButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
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

// MARK: - Delete Confirmation Popup

struct DeleteConfirmationView: View {
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        Color.black.opacity(0.4)
            .ignoresSafeArea()
            .overlay {
                VStack(spacing: 0) {
                    // 상단 타이틀 바
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

                    VStack(alignment: .leading, spacing: 0) {
                        Text("책 삭제")
                            .font(.customDungGeunMo(size: 20))
                            .foregroundColor(Color.customLb)

                        Spacer().frame(height: 20)

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
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.customBg)
                }
                .retroPopupShadow()
                .padding(.horizontal, 16)
            }
    }
}

extension View {
    func pixelBorder() -> some View {
        self
            .overlay(alignment: .trailing) {
                Rectangle().fill(Color.black).frame(width: 1).padding(.top, 1)
            }
            .overlay(alignment: .bottom) {
                Rectangle().fill(Color.black).frame(height: 1).padding(.leading, 1)
            }
    }

    /// 팝업 내부 버튼/박스용: 위/좌 흰색, 아래/우 검정 bevel + 1pt 그림자
    func retroPixelBorder() -> some View {
        self
            .overlay(alignment: .top) { Rectangle().fill(Color.white).frame(height: 1) }
            .overlay(alignment: .leading) { Rectangle().fill(Color.white).frame(width: 1) }
            .overlay(alignment: .bottom) { Rectangle().fill(Color.black).frame(height: 1) }
            .overlay(alignment: .trailing) { Rectangle().fill(Color.black).frame(width: 1) }
            .padding(.trailing, 1).padding(.bottom, 1)
            .background(Color.black)
    }

    /// 팝업 외곽 컨테이너용: 위/좌 흰색, 아래/우 검정 bevel + 3pt 그림자
    func retroPopupShadow() -> some View {
        self
            .overlay(alignment: .top) { Rectangle().fill(Color.white).frame(height: 1) }
            .overlay(alignment: .leading) { Rectangle().fill(Color.white).frame(width: 1) }
            .overlay(alignment: .bottom) { Rectangle().fill(Color.black).frame(height: 1) }
            .overlay(alignment: .trailing) { Rectangle().fill(Color.black).frame(width: 1) }
            .padding(.trailing, 3).padding(.bottom, 3)
            .background(Color.black)
    }
}


#Preview {
//    BookDetailView(bookData: Book(
//        title: "큰별쌤 최태성의 별별 한국사한국사 검정능력시험",
//        description: "철리 매거시는 알리스트레이어로 영국의 추간지 '스펙테이터'에 그림을 그리고, 옥스퍼드대학 출판부의 표지 디자이너로 있었고 그러면서 일상에서 살아온 행복한 것은 무언가 무엇인지를 생각하며 한구름을 대출을 나누고는 책 1권의 결과는 한구름을 대출을 나누고는 행...", coverImage: nil, author: "최태성",
//        publisher: "이투스북",
//        publishDate: "2020 - 04 - 20",
//        isbn: "9788997381678",
//        pageCount: "234"
//    ))
}





