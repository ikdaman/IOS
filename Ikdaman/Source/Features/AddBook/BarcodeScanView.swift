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
        ZStack {
            // 카메라 배경
            BarcodeScannerView { code in
                Task {
                    await viewModel.handleScannedCode(code)
                }
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                CustomHeader(title: "", showBackButton: true)
                    .background(Color.black.opacity(0.8)) // 헤더 뒷배경 살짝 어둡게
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
                        .strokeBorder(Color.white, lineWidth: 2) // 선만 표시
                        .background(Color.clear) // 내부는 투명하게
                        .frame(height: 189)
                        .padding(.top, 7)
                }
                .padding(.horizontal, 44)
                .padding(.top, 150)
                
                Spacer()
            }
            
            // 검색 중 오버레이 표시
            if viewModel.isScanning {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                ProgressView()
                    .scaleEffect(2.0)
                    .tint(.white)
            }
        }
        .background(.black)
        .onChange(of: viewModel.foundBook) { _, newValue in
            if newValue != nil {
                dismiss() // 바코드 인식 후 결과를 찾으면 화면 닫기 (원하는 동작으로 추후 수정 가능)
            }
        }
    }
}

#Preview {
    BarcodeScanView()
}
