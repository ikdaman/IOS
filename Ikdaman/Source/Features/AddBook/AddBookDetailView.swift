//
//  AddBookDetailView.swift
//  Ikdaman
//
//  Created by Soo on 3/13/26.
//

import SwiftUI

// MARK: - Add Book View
struct AddBookDetailView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: AddBookDetailViewModel

    init(bookData: Books? = nil) {
        _viewModel = StateObject(wrappedValue: AddBookDetailViewModel(bookData: bookData))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                CustomHeader(title: viewModel.isManualEntry ? "직접 입력" : "책 추가하기", showBackButton: true) {
                    Button(action: {
                        Task { await viewModel.saveBook() }
                    }) {
                        Text("저장")
                            .font(.customDungGeunMo(size: 16))
                            .foregroundStyle(Color.customLb)
                    }
                }

                if let book = viewModel.bookData {
                    bookDataContent(book: book)
                } else {
                    manualEntryContent
                }
            }
        }
        .background(Color.customBg)
        .navigationBarHidden(true)
        .onChange(of: viewModel.shouldDismiss) { _, value in
            if value { dismiss() }
        }
        .alert("오류", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("확인") { viewModel.errorMessage = nil }
        } message: {
            if let msg = viewModel.errorMessage { Text(msg) }
        }
    }
    
    // MARK: - Manual Entry Content
    private var manualEntryContent: some View {
        VStack(spacing: 20) {
            // 책 표지 이미지
            Rectangle()
                .fill(Color.customBt)
                .frame(width: 101, height: 145)
                .overlay(
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .padding(.top, 60)
                .padding(.bottom, 10)
            
            // 제목 (필수)
            VStack(alignment: .leading, spacing: 8) {
                Text("제목(필수)")
                    .font(.customDungGeunMo(size: 14))
                
                TextField("", text: $viewModel.title)
                    .font(.customSansRegular(size: 16))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.black),
                        alignment: .bottom
                    )
            }
            
            // 작가 (필수)
            VStack(alignment: .leading, spacing: 6) {
                Text("작가(필수)")
                    .font(.customDungGeunMo(size: 14))
                TextField("", text: $viewModel.author)
                    .font(.customSansRegular(size: 16))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.black),
                        alignment: .bottom
                    )
            }
            
            // 출판사
            VStack(alignment: .leading, spacing: 6) {
                Text("출판사")
                    .font(.customDungGeunMo(size: 14))
                TextField("", text: $viewModel.publisher)
                    .font(.customSansRegular(size: 16))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.black),
                        alignment: .bottom
                    )
            }
            
            // 출간일
            VStack(alignment: .leading, spacing: 6) {
                Text("출간일")
                    .font(.customDungGeunMo(size: 14))
                TextField("", text: $viewModel.publishDate)
                    .font(.customSansRegular(size: 16))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.black),
                        alignment: .bottom
                    )
            }
            
            // ISBN
            VStack(alignment: .leading, spacing: 6) {
                Text("ISBN")
                    .font(.customDungGeunMo(size: 14))
                TextField("", text: $viewModel.isbn)
                    .font(.customSansRegular(size: 16))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.black),
                        alignment: .bottom
                    )
            }
            
            // 페이지 수
            VStack(alignment: .leading, spacing: 6) {
                Text("페이지 수")
                    .font(.customDungGeunMo(size: 14))
                TextField("", text: $viewModel.pageCount)
                    .font(.customSansRegular(size: 16))
                    .keyboardType(.numberPad)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.black),
                        alignment: .bottom
                    )
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Book Data Content
    private func bookDataContent(book: Books) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                Spacer()
                
                AsyncImage(url: URL(string: book.bookInfo.coverImage)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 180, height: 250)
                
                Spacer()
            }
            .padding(.top, 30)
            .padding(.bottom, 20)
               
            
            // 책 제목
            Text(viewModel.title)
                .font(.customSansSemiBold(size: 20))
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 8)

            // 저자 정보
            VStack(spacing: 8) {
                Text(viewModel.author)
                    .font(.customSansRegular(size: 16))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(viewModel.publisher)
                    .font(.customSansRegular(size: 16))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.bottom, 28)
            
            VStack(spacing: 20) {
                // 페이지 수
                VStack(alignment: .leading, spacing: 6) {
                    Text("페이지 수")
                        .font(.customDungGeunMo(size: 14))
                    TextField("", text: $viewModel.pageCount)
                        .font(.customSansRegular(size: 16))
                        .keyboardType(.numberPad)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .overlay(
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.black),
                            alignment: .bottom
                        )
                }
                
                // 출간일
                VStack(alignment: .leading, spacing: 8) {
                    Text("출간일")
                        .font(.customDungGeunMo(size: 14))
                    TextField("", text: $viewModel.publishDate)
                        .font(.customSansRegular(size: 16))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .overlay(
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.black),
                            alignment: .bottom
                        )
                }
                
                // ISBN
                VStack(alignment: .leading, spacing: 8) {
                    Text("ISBN")
                        .font(.customDungGeunMo(size: 14))
                    TextField("", text: $viewModel.isbn)
                        .font(.customSansRegular(size: 16))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .overlay(
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.black),
                            alignment: .bottom
                        )
                }
                
                // 책 소개
                VStack(alignment: .leading, spacing: 8) {
                    Text("책 소개")
                        .font(.customDungGeunMo(size: 14))
                    Text(viewModel.description)
                        .font(.customSansRegular(size: 16))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .overlay(
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.black),
                            alignment: .bottom
                        )
                }
                
                Button(action: {
                    // 알라딘 페이지 열기
                    if let url = URL(string: book.bookInfo.link ?? "") {
                        #if os(iOS)
                        UIApplication.shared.open(url)
                        #endif
                    }
                }) {
                    Text("알라딘에서 더보기")
                        .font(.customSansRegular(size: 16))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .overlay(
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.black),
                            alignment: .bottom
                        )
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
}
