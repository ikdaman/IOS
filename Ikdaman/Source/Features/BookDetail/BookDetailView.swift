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
    let currentReason: String
    let rawStartedDate: String?
    let rawFinishedDate: String?
    let onConfirm: (Int, String, String?, String?) -> Void
    let onCancel: () -> Void

    @State private var selectedTab: Int
    @State private var reason: String
    @State private var startDate: Date
    @State private var finishDate: Date?
    @State private var showStartPicker = false
    @State private var showFinishPicker = false

    private let maxReasonLength = 400

    init(
        initialTab: Int,
        currentReason: String,
        rawStartedDate: String?,
        rawFinishedDate: String?,
        onConfirm: @escaping (Int, String, String?, String?) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.initialTab = initialTab
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
                    // 타이틀 바
                    HStack(spacing: 0) {
                        Spacer()
                        Rectangle().frame(width: 1).foregroundColor(Color.customLb)
                        Button("X") { onCancel() }
                            .font(.customDungGeunMo(size: 12))
                            .foregroundColor(Color.customLb)
                            .frame(width: 30, height: 30)
                    }
                    .frame(height: 30)
                    .background(Color.customBt)
                    .overlay(Rectangle().frame(height: 1).foregroundColor(Color.customLb), alignment: .bottom)

                    VStack(alignment: .leading, spacing: 16) {
                        Text("책 정보 수정")
                            .font(.customDungGeunMo(size: 20))
                            .foregroundColor(Color.customLb)
                            .padding(.top, 16)

                        // 탭 선택
                        HStack(spacing: 0) {
                            Button(action: { selectedTab = 0 }) {
                                Text("내 서점")
                                    .font(.customDungGeunMo(size: 12))
                                    .foregroundColor(Color.customLb)
                                    .padding(.horizontal, 12).padding(.vertical, 6)
                                    .background(selectedTab == 0 ? Color.customBg : Color.customBt)
                                    .overlay(Rectangle().stroke(Color.customLb, lineWidth: 1))
                            }
                            Button(action: { selectedTab = 1 }) {
                                Text("히스토리")
                                    .font(.customDungGeunMo(size: 12))
                                    .foregroundColor(Color.customLb)
                                    .padding(.horizontal, 12).padding(.vertical, 6)
                                    .background(selectedTab == 1 ? Color.customBg : Color.customBt)
                                    .overlay(Rectangle().stroke(Color.customLb, lineWidth: 1))
                            }
                        }

                        if selectedTab == 0 {
                            // 내 서점 탭: 읽고 싶은 이유
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
                                .background(Color.white)
                                .scrollContentBackground(.hidden)
                                Text("\(reason.count)/\(maxReasonLength)")
                                    .font(.customSansRegular(size: 10))
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8).padding(.bottom, 8)
                            }
                        } else {
                            // 히스토리 탭: 독서 시작/종료 날짜
                            VStack(alignment: .leading, spacing: 8) {
                                Text("START").font(.customDungGeunMo(size: 12)).foregroundColor(Color.customLb)
                                Button(action: {
                                    showStartPicker.toggle()
                                    if showStartPicker { showFinishPicker = false }
                                }) {
                                    HStack {
                                        Text(displayString(startDate))
                                            .font(.customDungGeunMo(size: 12)).foregroundColor(Color.customLb)
                                        Spacer()
                                        Text("▼").font(.customDungGeunMo(size: 10)).foregroundColor(Color.customLb)
                                    }
                                    .padding(.horizontal, 8).padding(.vertical, 6)
                                    .overlay(Rectangle().stroke(Color.customLb, lineWidth: 1))
                                }
                                if showStartPicker {
                                    DatePicker("", selection: $startDate, displayedComponents: .date)
                                        .datePickerStyle(.graphical).labelsHidden().tint(Color.customLb)
                                }
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("FINISH").font(.customDungGeunMo(size: 12)).foregroundColor(Color.customLb)
                                Button(action: {
                                    if finishDate == nil { finishDate = Date() }
                                    showFinishPicker.toggle()
                                    if showFinishPicker { showStartPicker = false }
                                }) {
                                    HStack {
                                        Text(finishDate.map { displayString($0) } ?? "읽는 중")
                                            .font(.customDungGeunMo(size: 12)).foregroundColor(Color.customLb)
                                        Spacer()
                                        Text("▼").font(.customDungGeunMo(size: 10)).foregroundColor(Color.customLb)
                                    }
                                    .padding(.horizontal, 8).padding(.vertical, 6)
                                    .overlay(Rectangle().stroke(Color.customLb, lineWidth: 1))
                                }
                                if showFinishPicker, let finish = finishDate {
                                    DatePicker("", selection: Binding(get: { finish }, set: { finishDate = $0 }),
                                               displayedComponents: .date)
                                        .datePickerStyle(.graphical).labelsHidden().tint(Color.customLb)
                                    Button("읽는 중으로 변경") {
                                        finishDate = nil
                                        showFinishPicker = false
                                    }
                                    .font(.customDungGeunMo(size: 10)).foregroundColor(Color.customLb.opacity(0.6))
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    // NO / YES 버튼
                    HStack(spacing: 30) {
                        Button(action: { onCancel() }) {
                            Text("NO").font(.customDungGeunMo(size: 12)).foregroundColor(Color.customLb)
                                .frame(width: 80, height: 30).background(Color.customBt)
                                .overlay(Rectangle().stroke(Color.customLb, lineWidth: 1))
                        }
                        Button(action: {
                            if selectedTab == 1 {
                                onConfirm(1, reason, toISO8601(startDate), finishDate.map { toISO8601($0) })
                            } else {
                                onConfirm(0, reason, nil, nil)
                            }
                        }) {
                            Text("YES").font(.customDungGeunMo(size: 12)).foregroundColor(Color.customLb)
                                .frame(width: 80, height: 30).background(Color.customBt)
                                .overlay(Rectangle().stroke(Color.customLb, lineWidth: 1))
                        }
                    }
                    .padding(.top, 24).padding(.bottom, 24)
                }
                .background(Color.customBg)
                .frame(width: 300)
                .overlay(RoundedRectangle(cornerRadius: 0).stroke(Color.customLb, lineWidth: 1))
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
                    HStack(spacing: 0) {
                        Spacer()
                        Rectangle().frame(width: 1).foregroundColor(Color.customLb)
                        Button("X") { onCancel() }
                            .font(.customDungGeunMo(size: 12))
                            .foregroundColor(Color.customLb)
                            .frame(width: 30, height: 30)
                    }
                    .frame(height: 30)
                    .background(Color.customBt)
                    .overlay(Rectangle().frame(height: 1).foregroundColor(Color.customLb), alignment: .bottom)

                    VStack(spacing: 12) {
                        Text("책 삭제")
                            .font(.customDungGeunMo(size: 20))
                            .foregroundColor(Color.customLb)
                            .padding(.top, 16)

                        Text("책을 삭제하면 모든 기록이 사라져요.\n정말로 삭제하시겠어요?")
                            .font(.customSansRegular(size: 14))
                            .foregroundColor(Color.customLb)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                    }

                    HStack(spacing: 30) {
                        Button(action: { onCancel() }) {
                            Text("NO").font(.customDungGeunMo(size: 12)).foregroundColor(Color.customLb)
                                .frame(width: 80, height: 30).background(Color.customBt)
                                .overlay(Rectangle().stroke(Color.customLb, lineWidth: 1))
                        }
                        Button(action: { onConfirm() }) {
                            Text("YES").font(.customDungGeunMo(size: 12)).foregroundColor(Color.customLb)
                                .frame(width: 80, height: 30).background(Color.customBt)
                                .overlay(Rectangle().stroke(Color.customLb, lineWidth: 1))
                        }
                    }
                    .padding(.top, 24).padding(.bottom, 24)
                }
                .background(Color.customBg)
                .frame(width: 300)
                .overlay(RoundedRectangle(cornerRadius: 0).stroke(Color.customLb, lineWidth: 1))
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





