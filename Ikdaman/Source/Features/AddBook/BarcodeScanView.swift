//
//  BarcodeScanView.swift
//  Ikdaman
//
//  Created by Soo on 3/13/26.
//

import SwiftUI

struct BarcodeScanView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = BarcodeScanViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            CustomHeader(title: "", showBackButton: true)
                .overlay(
                    Rectangle()
                         .frame(height: 1)
                        .foregroundColor(Color(.separator)),
                    alignment: .bottom
                )

                VStack(spacing: 10) {
                    Text("책의 바코드 영역을 맞춰주세요.")
                        .font(.customDungGeunMo(size: 20))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Image("arrowDown")

                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 189)
                        .padding(.top, 7)
                }
                .padding(.horizontal, 44)
                .padding(.top, 150)
            
            Spacer()
        }
        .background(.black)
    }
}

#Preview {
    BarcodeScanView()
}
