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
        let pressed = configuration.isPressed
        return configuration.label
            .font(.customDungGeunMo(size: fontSize))
            .foregroundColor(.customLb)
            .padding(.horizontal, 7)
            .padding(.vertical, 4)
            .background(Color.customBt)
            .overlay(alignment: .top) {
                Rectangle().fill(pressed ? Color.black : Color.white)
                    .frame(height: 1).padding(.trailing, pressed ? 0 : 1)
            }
            .overlay(alignment: .leading) {
                Rectangle().fill(pressed ? Color.black : Color.white)
                    .frame(width: 1).padding(.bottom, pressed ? 0 : 1)
            }
            .overlay(alignment: .bottom) {
                Rectangle().fill(pressed ? Color.white : Color.black)
                    .frame(height: 1).padding(.leading, pressed ? 0 : 1)
            }
            .overlay(alignment: .trailing) {
                Rectangle().fill(pressed ? Color.white : Color.black)
                    .frame(width: 1).padding(.top, pressed ? 0 : 1)
            }
    }
}

//// --- 사용 예시 ---
//Button("[+] ADD BOOK") {
//    // 액션
//}
//.buttonStyle(PixelButtonStyle())
