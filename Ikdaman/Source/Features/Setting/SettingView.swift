//
//  SettingView.swift
//  Ikdaman
//
//  Created by Soo on 3/13/26.
//

import SwiftUI

struct SettingsView: View {
    @State private var nickname: String = "수진"
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. 공통 헤더 (DungGeunMo 폰트 적용된 버전)
            CustomHeader(title: "설 정", showBackButton: true)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 40) {
                    
                    // 2. 인사말 섹션
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(nickname)님,")
                        Text("안녕하세요!")
                    }
                    .font(.customDungGeunMo(size: 24))
                    .padding(.top, 30)
                    .padding(.bottom, 60)
                    
                    // 3. 닉네임 수정 섹션
                    VStack(alignment: .leading, spacing: 6) {
                        Text("닉네임")
                            .font(.customDungGeunMo(size: 16))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                        
                        TextField("", text: $nickname)
                            .font(.customSansRegular(size: 16))
                            .padding(.horizontal, 16)
                            .frame(height: 45)
                            .background(Color.white)
                            .overlay(
                                Rectangle()
                                    .stroke(Color.black, lineWidth: 1)
                            )
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("중복된 닉네임이에요.")
                            Text("닉네임을 다시 확인해주세요.")
                        }
                        .font(.customDungGeunMo(size: 12))
                        .foregroundColor(Color.customBlue)
                    }
                    
                    VStack(alignment: .leading, spacing: 24) {
                        Button("공지사항") { }
                        Button("서비스 이용약관") { }
                        Button("개인정보 처리방침") { }
                    }
                    .font(.customDungGeunMo(size: 16))
                    .foregroundStyle(.black)
                    .padding(.top, 28)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
            }
        }
        .background(Color.customBg)
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    SettingsView()
}
