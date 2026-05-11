//
//  MainTabView.swift
//  읽다만 iOS
//
//  Created on 2026-03-09.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    
    enum Tab: String, CaseIterable {
        case myLibrary = "내 서점"
        case addBook = "책 추가"
        case history = "히스토리"
    }
    private let selectedColor = Color(hex: "#010196")
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    let isSelected = selectedTab == tab
                    
                    Text(tab.rawValue)
                        .font(.customDungGeunMo(size: 14))
                        .foregroundColor(isSelected ? .white : .primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Rectangle()
                                .fill(isSelected ? selectedColor : Color.clear)
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
            }
        }
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(.separator)),
            alignment: .top
        )
    }
}

struct ContentView: View {
    @State private var selectedTab: CustomTabBar.Tab = .myLibrary
    @State private var hideTabBar = false // ✅ 추가
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 메인 콘텐츠 영역
            TabView(selection: $selectedTab) {
                MyLibraryView(selectedTab: $selectedTab, hideTabBar: $hideTabBar)
                    .tag(CustomTabBar.Tab.myLibrary)
                
                AddBookView()
                    .tag(CustomTabBar.Tab.addBook)
                
                HistoryView(hideTabBar: $hideTabBar)
                    .tag(CustomTabBar.Tab.history)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // 커스텀 탭바 - 오버레이
            if !hideTabBar {
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
        .background(Color.customBg)
    }
}

#Preview {
    ContentView()
}
