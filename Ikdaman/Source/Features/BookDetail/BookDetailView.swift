//
//  BookDetailView.swift
//  Ikdaman
//
//  Created by Soo on 3/13/26.
//

import SwiftUI

struct BookDetailView: View {
    @State private var bookData: Books
    
//    init(bookData: Book) {
//        _bookData = State(initialValue: bookData)
//    }
    
    var body: some View {
        VStack(spacing: 0) {
            CustomHeader(title: "", showBackButton: true) {
                Button("삭제") {
                    
                }
                .font(.customDungGeunMo(size: 16))
                .foregroundColor(.black)
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 책 표지 및 기본 정보
                    HStack(alignment: .top) {
                        Spacer()
                        
                        // 책 이미지
                        Image("book_cover") // 실제 이미지 에셋 이름
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 201, height: 272)
                            .border(Color.black, width: 1)
                        
                        Spacer()
                    }
                    .padding(.top, 30)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("읽고 싶은 책")
                            .font(.customDungGeunMo(size: 12))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue)
                        
                        Text(bookData.bookInfo.title)
                            .font(.customSemiBold(size: 18))
                            .lineLimit(3)
                        
                        Text(bookData.bookInfo.author.first ?? "''")
                            .font(.customRegular(size: 14))
                        
                        Text(bookData.bookInfo.publisher ?? "")
                            .font(.customRegular(size: 14))
                    }
                    .padding(.top, 2)
                    .padding(.bottom, 10)
                    
                    // 독서 이력 섹션
                    VStack(spacing: 0) {
                        SectionHeader(title: "독서 이력")
                        VStack(alignment: .leading, spacing: 8) {
                            historyRow(label: "SAVE", value: "2025 - 01 - 25")
                            historyRow(label: "START", value: "")
                            historyRow(label: "FINISH", value: "")
                        }
                        .padding(15)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .border(Color.black, width: 1)
                    }
                    
                    // 읽고 싶었던 이유
                    VStack(spacing: 0) {
                        SectionHeader(title: "읽고 싶었던 이유")
                        Text("나는 왜냐하면 이 책을 읽고 싶었기 때문이다. 나는 왜냐하면 이 책을 읽고 싶었기 때문이다.")
                            .font(.customRegular(size: 14))
                            .padding(15)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .border(Color.black, width: 1)
                    }
                    
                    // 상세 제원 (페이지, 출간일, ISBN)
//                    InfoField(label: "페이지 수", value: "\($bookData.totalPages)")
                    InfoField(label: "출간일", value: "2020 - 04 - 20")
                    InfoField(label: "ISBN", value: bookData.bookInfo.ISBN ?? "")
                    
                    // 책 소개
                    VStack(alignment: .leading, spacing: 6) {
                        Text("책 소개")
                            .font(.customDungGeunMo(size: 14))
                        
                        Text(bookData.bookInfo.description)
                            .font(.customSansRegular(size: 16))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity, minHeight: 46, alignment: .leading)
                            .background(Color.white)
                            .border(Color.black, width: 1)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // 하단 버튼
                    Button {
                        
                    } label: {
                        Text("알라딘에서 더보기")
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .background(Color.white)
                            .border(Color.black, width: 1)
                            .font(.customSansRegular(size: 16))
                            .foregroundColor(.black)
                    }
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 20)
            }
        }
        .background(Color.customBg)
    }
    
    private func historyRow(label: String, value: String) -> some View {
        HStack(spacing: 10) {
            Text(label)
                .font(.customDungGeunMo(size: 16))
                .frame(width: 74, alignment: .leading)
            Text(value)
                .font(.customRegular(size: 16))
        }
    }
}

struct SectionHeader: View {
    let title: String
    var showEdit: Bool = true
    
    var body: some View {
        HStack {
            Text(title)
                .font(.customDungGeunMo(size: 14))
            Spacer()
            if showEdit {
                Button("수정") {
                    
                }
                .font(.customDungGeunMo(size: 14))
                .foregroundStyle(.black)
                .frame(width: 44, height: 22, alignment: .center)
                .border(Color.black, width: 1)
            }
        }
        .padding(.leading, 10)
        .frame(height: 22)
        .background(Color.customBt)
        .border(Color.black, width: 1)
    }
}

// 정보 표시 박스 (페이지, 출간일, ISBN 등)
struct InfoField: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.customDungGeunMo(size: 14))
            
            Text(value)
                .font(.customSansRegular(size: 16))
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
                .background(Color.white)
                .border(Color.black, width: 1)
        }
    }
}


#Preview {
//    BookDetailView(bookData: Book(
//        title: "큰별쌤 최태성의 별별 한국사한국사 검정능력시험",
//        description: "철리 매거시는 알리스트레이어로 영국의 추간지 '스펙테이터'에 그림을 그리고, 옥스퍼드대학 출판부의 표지 디자이너로 있었고 그러면서 일상에서 살아온 행복한 것은 무언가 무엇인지를 생각하며 한구름을 대출을 나누고는 책 1권의 결과는 한구름을 대출을 나누고는 행...", coverImage: nil, author: "최태성",
//        publisher: "이투스북",
//        publishDate: "2020 - 04 - 20",
//        isbn: "9788997381678",
//        pageCount: "234"
//    ))
}





