//
//  ButtonStyle.swift
//  Ikdaman
//
//  Created by Soo on 3/13/26.
//

import SwiftUI

struct PixelButtonStyle: ButtonStyle {
    // 1. 파라미터로 받을 프로퍼티 선언
    let fontSize: CGFloat
    
    // 기본값을 설정하고 싶다면 초기화(init)를 명시하거나 선언 시 할당합니다.
    init(fontSize: CGFloat = 20) {
        self.fontSize = fontSize
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.customDungGeunMo(size: fontSize)) // 파라미터 적용
            .foregroundColor(.customLb)
            .padding(.horizontal, 7)
            .padding(.vertical, 4) // 패딩도 조절 가능
            .background(Color.customBt)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

//// --- 사용 예시 ---
//Button("[+] ADD BOOK") {
//    // 액션
//}
//.buttonStyle(PixelButtonStyle())
