//
//  HistoryView.swift
//  Ikdaman
//
//  Created by Soo on 3/13/26.
//

import SwiftUI

// 디스플레이 모드 정의
enum DisplayMode {
    case list, grid
}

struct HistoryView: View {
    @Binding var hideTabBar: Bool
    @StateObject private var viewModel = HistoryViewModel()
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 4) {
                CustomHeader(title: "히스토리", showBackButton: false)

                HStack {
                    HStack(spacing: 4) {
                        Button(action: { viewModel.toggleViewType() }) {
                            Image(systemName: "list.bullet")
                                .frame(width: 36, height: 36)
                                .background(viewModel.displayMode == .list ? Color.gray.opacity(0.3) : Color.clear)
                                .border(Color.black, width: 1)
                        }
                        Button(action: { viewModel.toggleViewType() }) {
                            Image(systemName: "square.grid.2x2.fill")
                                .frame(width: 36, height: 36)
                                .background(viewModel.displayMode == .grid ? Color.gray.opacity(0.3) : Color.clear)
                                .border(Color.black, width: 1)
                        }
                    }
                    .foregroundColor(.black)

                    Spacer()

                    HStack(spacing: 8) {
                        Button(action: { viewModel.toggleSort() }) {
                            HStack(spacing: 2) {
                                Text(viewModel.sortDescending ? "최신순" : "오래된순")
                                Image(systemName: "chevron.down")
                            }
                        }
                        .foregroundColor(.black)
                        Image("search")
                    }
                    .font(.customDungGeunMo(size: 14))
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
                .padding(.top, 10)

                ScrollView {
                    if viewModel.displayMode == .list {
                        historyListView
                    } else {
                        historyGridView
                    }
                }
                .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 56) }
            }
            .background(Color(r: 235, g: 238, b: 245).ignoresSafeArea())
            .navigationBarHidden(true)
            .navigationDestination(for: Int.self) { myBookId in
                BookDetailView(book: Books(myBookId: myBookId))
                    .onAppear { hideTabBar = true }
                    .onDisappear { hideTabBar = false }
            }
            .task {
                await viewModel.onAppear()
            }
        }
    }
    
    // MARK: - 리스트 뷰 레이아웃
    private var historyListView: some View {
        VStack(spacing: 0) {
            // 테이블 헤더
            HStack(spacing: 0) {
                Text("START").frame(width: 70, alignment: .leading)
                Text("FINISH").frame(width: 70, alignment: .leading)
                Text("BOOK NAME").frame(maxWidth: .infinity, alignment: .leading)
            }
            .font(.customDungGeunMo(size: 12))
            .padding(.horizontal, 15)
            .frame(height: 30)
            .background(Color(r: 210, g: 215, b: 220))
            .border(Color.black, width: 0.5)

            if viewModel.historyItems.isEmpty {
                Text("읽고 있는 책을 추가해주세요.")
                    .font(.customSansRegular(size: 14))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
            } else {
                // 리스트 항목
                ForEach(Array(viewModel.historyItems.enumerated()), id: \.offset) { index, item in
                    HStack(spacing: 0) {
                        Text(item.start).frame(width: 70, alignment: .leading)
                        Text(item.finish).frame(width: 70, alignment: .leading)
                        Text(item.title)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .font(.customDungGeunMo(size: 13))
                    .padding(.horizontal, 15)
                    .frame(height: 35)
                    .background(index % 2 == 0 ? Color.white : Color(r: 242, g: 244, b: 248))
                    .onTapGesture { navigationPath.append(item.myBookId) }
                }
            }
        }
        .padding(.horizontal, 15)
    }

    // MARK: - 그리드(썸네일) 뷰 레이아웃
    private var historyGridView: some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
        let placeholderCount = max(0, 12 - viewModel.historyItems.count)

        return LazyVGrid(columns: columns, spacing: 15) {
            ForEach(viewModel.historyItems) { item in
                coverCell(url: item.coverImage)
                    .onTapGesture { navigationPath.append(item.myBookId) }
            }
            ForEach(0..<placeholderCount, id: \.self) { _ in
                coverCell(url: nil)
            }
        }
        .padding(20)
    }

    @ViewBuilder
    private func coverCell(url: String?) -> some View {
        ZStack {
            Color(r: 210, g: 210, b: 210)

            if let urlString = url, let imageURL = URL(string: urlString) {
                AsyncImage(url: imageURL) { phase in
                    if case .success(let image) = phase {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 18)
                    }
                }
            }
        }
        .aspectRatio(0.7, contentMode: .fit)
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(Color.black)
                .frame(width: 1)
                .padding(.top, 1)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.black)
                .frame(height: 1)
                .padding(.leading, 1)
        }
    }
}

// 데이터 모델
struct HistoryBook: Identifiable {
    let id = UUID()
    let myBookId: Int
    let start: String
    let finish: String
    let title: String
    let coverImage: String?
}


