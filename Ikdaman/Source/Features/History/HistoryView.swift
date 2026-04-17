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
    @StateObject private var viewModel = HistoryViewModel()

    var body: some View {
        VStack(spacing: 4) {
            // 상단 타이틀
            CustomHeader(title: "히스토리", showBackButton: false)
            
            // 컨트롤바 (뷰 전환 버튼 & 정렬)
            HStack {
                // 왼쪽: 리스트/그리드 전환 버튼
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

                // 오른쪽: 정렬 및 검색
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

            // 3. 메인 콘텐츠 (전환 영역)
            ScrollView {
                if viewModel.displayMode == .list {
                    historyListView
                } else {
                    historyGridView
                }
            }
        }
        .background(Color(r: 235, g: 238, b: 245).ignoresSafeArea())
        .task {
            await viewModel.onAppear()
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
                // 짝수(0, 2, 4...)일 때는 흰색, 홀수(1, 3, 5...)일 때는 연한 회색 배경
                .background(index % 2 == 0 ? Color.white : Color(r: 242, g: 244, b: 248))
            }
        }
        .padding(.horizontal, 15)
    }
    
    // MARK: - 그리드(썸네일) 뷰 레이아웃
    private var historyGridView: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
            ForEach(viewModel.historyItems) { item in
                VStack(spacing: 4) {
                    Rectangle()
                        .fill(Color(r: 210, g: 210, b: 210))
                        .overlay(
                            Text("표지")
                                .font(.customDungGeunMo(size: 12))
                                .foregroundColor(.gray)
                        )
                        .aspectRatio(0.7, contentMode: .fit)
                        .border(Color.black, width: 1)
                    Text(item.title)
                        .font(.customDungGeunMo(size: 10))
                        .lineLimit(1)
                }
            }
        }
        .padding(20)
    }
}

// 데이터 모델
struct HistoryBook: Identifiable {
    let id = UUID()
    let start: String
    let finish: String
    let title: String
}

#Preview {
    HistoryView()
}
