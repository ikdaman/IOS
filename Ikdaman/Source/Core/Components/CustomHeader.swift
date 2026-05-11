//
//  CustomHeader.swift
//  Ikdaman
//
//  Created by Soo on 3/11/26.
//

import SwiftUI

struct CustomHeader<RightContent: View>: View {
    @Environment(\.dismiss) private var dismiss
    
    let title: String
    var showBackButton: Bool = true
    var titleColor: Color = .primary
    let rightContent: RightContent
    
    // 초기화: 우측 버튼이 있는 경우
    init(
        title: String,
        showBackButton: Bool = true,
        titleColor: Color = .primary,
        @ViewBuilder rightContent: () -> RightContent
    ) {
        self.title = title
        self.showBackButton = showBackButton
        self.titleColor = titleColor
        self.rightContent = rightContent()
    }
    
    // 초기화: 우측 버튼이 없는 경우 (편의용)
    init(title: String, showBackButton: Bool = true, titleColor: Color = .primary) where RightContent == EmptyView {
        self.init(title: title, showBackButton: showBackButton, titleColor: titleColor) {
            EmptyView()
        }
    }
    
    var body: some View {
        ZStack {
            // 1. 중앙 타이틀
            Text(title)
                .font(.customDungGeunMo(size: 22)) // 이미지의 느낌을 살려 둥근모 적용
                .foregroundColor(titleColor)
            
            HStack {
                // 2. 좌측 뒤로가기 버튼
                if showBackButton {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.black)
                    }
                }
                
                Spacer()
                
                // 3. 우측 액션 버튼 영역
                rightContent
            }
            .padding(.horizontal, 23)
        }
        .frame(height: 56) // 일반적인 헤더 높이
        .background(Color.customBg)
    }
}

// ## 사용방법
//
//우측에 '저장' 버튼이 있는 경우 (직접 입력, 책 추가하기)
//CustomHeader(title: "직접 입력") {
//    Button("저장") {
//        // 저장 로직
//    }
//    .font(.customRegular(size: 14))
//    .foregroundColor(.gray)
//}
//
//우측에 버튼이 없는 경우 (내 책 검색, 설정)
//CustomHeader(title: "내 책 검색")
//
//우측에 버튼이 여러 개 있는 경우 (책 수정 삭제)
//CustomHeader(title: "책 상세") {
//    HStack(spacing: 12) {
//        Button("책 수정") { }
//        Button("삭제") { }
//    }
//    .font(.customRegular(size: 14))
//    .foregroundColor(.gray)
//}
//
//뒤로가기가 없는 메인 타이틀 (HISTORY)
//CustomHeader(title: "HISTORY", showBackButton: false)
