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
    @State private var bookData: Books?
    @State private var isManualEntry: Bool = false
    
    // 입력 필드
    @State private var title: String = ""
    @State private var author: String = ""
    @State private var publisher: String = ""
    @State private var publishDate: String = ""
    @State private var isbn: String = ""
    @State private var pageCount: String = ""
    @State private var description: String = ""
    
    // 초기화 함수 추가
    init(bookData: Books? = nil) {
        _bookData = State(initialValue: bookData)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                CustomHeader(title: bookData == nil ? "직접 입력" : "책 추가하기", showBackButton: true) {
                    Button(action: {
                        saveBook()
                    }) {
                        Text("저장")
                            .font(.customDungGeunMo(size: 16))
                            .foregroundStyle(Color.customLb)
                    }
                }
                
                if let book = bookData {
                    bookDataContent(book: book)
                } else {
                    manualEntryContent
                }
            }
        }
        .background(Color.customBg)
        .navigationBarHidden(true)
        .onAppear {
            loadBookData()
        }
    }
    
    // MARK: - Load Book Data
    private func loadBookData() {
        if let book = bookData {
            isManualEntry = false
            title = book.bookInfo.title
            author = book.bookInfo.author.first ?? ""
            publisher = book.bookInfo.publisher ?? ""
            publishDate = book.bookInfo.publishDate ?? ""
            isbn = book.bookInfo.ISBN ?? ""
            pageCount = "\(book.bookInfo.totalPage)"
            description = book.bookInfo.description
        } else {
            isManualEntry = true
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
                
                TextField("", text: $title)
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
                TextField("", text: $author)
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
                TextField("", text: $publisher)
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
                TextField("", text: $publishDate)
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
                TextField("", text: $isbn)
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
                TextField("", text: $pageCount)
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
            Text(title)
                .font(.customSansSemiBold(size: 20))
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 8)
            
            // 저자 정보
            VStack(spacing: 8) {
                Text(author)
                    .font(.customSansRegular(size: 16))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(publisher)
                    .font(.customSansRegular(size: 16))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.bottom, 28)
            
            VStack(spacing: 20) {
                // 페이지 수
                VStack(alignment: .leading, spacing: 6) {
                    Text("페이지 수")
                        .font(.customDungGeunMo(size: 14))
                    TextField("", text: $pageCount)
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
                    TextField("", text: $publishDate)
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
                    TextField("", text: $isbn)
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
                    Text(description)
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
    
    // MARK: - Save Book
    private func saveBook() {
        // 필수 입력 항목 검증
        guard !title.isEmpty, !author.isEmpty else {
            print("제목과 작가는 필수 입력 항목입니다.")
            return
        }
        
        // 책 저장 로직 (ViewModel 또는 Service를 통해 서버에 저장)
        print("책 저장: \(title) by \(author)")
        dismiss()
    }
}
