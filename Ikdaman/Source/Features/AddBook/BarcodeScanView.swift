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
    
    var onBookFound: ((Books) -> Void)? = nil
    
    var body: some View {
        ZStack {
            // 카메라 배경
            BarcodeScannerView { code in
                Task {
                    await viewModel.handleScannedCode(code)
                }
            }
            .ignoresSafeArea()
            
            // 2. 바코드 영역 제외한 나머지 영역 #333333 덮기 (가운데 구멍 뚫기)
            ZStack {
                Color(hex: "333333")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    CustomHeader(title: "", showBackButton: true)
                        .hidden() // 위치 계산용 가짜 헤더
                    
                    VStack(spacing: 10) {
                        Text("책의 바코드 영역을 맞춰주세요.")
                            .font(.customDungGeunMo(size: 20))
                            .hidden()
                        
                        Image("arrowDown")
                            .hidden()
                        
                        Rectangle()
                            .fill(Color.black)
                            .frame(height: 189)
                            .padding(.top, 7)
                            .blendMode(.destinationOut) // 이 부분만 투명하게 구멍을 뚫음
                    }
                    .padding(.horizontal, 44)
                    .padding(.top, 150)
                    
                    Spacer()
                }
            }
            .compositingGroup()
            
            // 3. 실제 UI 그리기 (텍스트, 테두리 등)
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
        .onChange(of: viewModel.foundBook?.id) { _, newId in
            if newId != nil, let book = viewModel.foundBook {
                onBookFound?(book)
                dismiss() // 바코드 인식 후 결과를 찾으면 화면 닫기 (원하는 동작으로 추후 수정 가능)
            }
        }
    }
}

#Preview {
    BarcodeScanView()
}
