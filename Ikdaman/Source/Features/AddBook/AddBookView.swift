//
//  AddBookView.swift
//  Ikdaman
//
//  Created by Soo on 3/12/26.
//

import SwiftUI
import AVFoundation

// MARK: - Add Book View
struct AddBookView: View {
    @StateObject private var viewModel = AddBookViewModel()
    @State private var searchText = ""
    @FocusState private var isSearchFieldFocused: Bool
    @State private var showManualEntry = false
    @State private var showBarcodEntry = false
    @State private var selectedBook: Books?
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Search Bar
            searchBar
            
            // MARK: - Content
            if searchText.isEmpty {
                // 초기 상태: 검색 전
                emptySearchState
            } else if viewModel.isSearching {
                // 검색 중
                loadingState
            } else if viewModel.searchResults.isEmpty {
                // 검색 결과 없음
                noResultsState
            } else {
                // 검색 결과 있음
                searchResultsList
                    .padding(.bottom, 46)
            }
        }
        .background(Color.customBg)
        .navigationBarHidden(true)
        .onChange(of: searchText) { oldValue, newValue in
            viewModel.searchBooks(query: newValue)
        }
        .fullScreenCover(isPresented: $showManualEntry) {
            AddBookDetailView()
        }
        .fullScreenCover(isPresented: $showBarcodEntry) {
            BarcodeScanView(onBookFound: { book in
                showBarcodEntry = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    selectedBook = book
                }
            })
        }
        .fullScreenCover(item: $selectedBook) { book in
            AddBookDetailView(bookData: book)
        }
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 0) {
            // 텍스트 필드
            TextField("책 제목을 검색해주세요.", text: $searchText)
                .font(.customDungGeunMo(size: 16))
                .focused($isSearchFieldFocused)
                .submitLabel(.search)
                .onSubmit {
                    viewModel.searchBooks(query: searchText)
                }
                .padding(.leading, 10)
            
            Spacer()
            
            // 클리어 버튼 (텍스트가 있을 때만 표시)
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    viewModel.clearResults()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 18))
                }
                .padding(.trailing, 8)
            }
            
            // 바코드 스캔 버튼
            Button(action: {
                checkCameraPermission()
            }) {
                Image("camera")
            }
            .padding(.trailing, 10)
            
            // 검색 버튼
            Button(action: {
                viewModel.searchBooks(query: searchText)
            }) {
                Image("textSearch")
            }
            .padding(.trailing, 10)
        }
        .frame(height: 48)
        .overlay(
            RoundedRectangle(cornerRadius: 0.7)
                .stroke(Color(red: 51/255, green: 51/255, blue: 51/255), lineWidth: 0.7)
        )
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
    }
    
    // MARK: - Empty Search State
    private var emptySearchState: some View {
        VStack {
            Spacer()
            
            Text("")
                .font(.customRegular(size: 16))
                .foregroundColor(.gray)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Loading State
    private var loadingState: some View {
        VStack {
            Spacer()
            
            ProgressView()
                .scaleEffect(1.5)
            
            Text("검색 중...")
                .font(.customSansRegular(size: 16))
                .foregroundColor(.gray)
                .padding(.top, 16)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - No Results State
    private var noResultsState: some View {
        VStack(spacing: 24) {
            Text("검색 결과가 없습니다.")
                .font(.customSansRegular(size: 20))
                .foregroundColor(.black)
            
            Button("[+] 책 직접 입력하기") {
                showManualEntry = true
            }
            .buttonStyle(PixelButtonStyle(fontSize: 18))
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
    
    // MARK: - Search Results List
    private var searchResultsList: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(viewModel.searchResults, id: \.myBookId) { book in
                    BookSearchResultRow(book: book) {
                        selectedBook = book
                    }
                }
            }
        }
    }
    
    // MARK: - Camera Permission
    private func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            showBarcodEntry = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        showBarcodEntry = true
                    }
                }
            }
        case .denied, .restricted:
            break
        @unknown default:
            break
        }
    }
}

// MARK: - Book Search Result Row
struct BookSearchResultRow: View {
    let book: Books
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            // 책 선택 액션
            action()
        }) {
            HStack(alignment: .top, spacing: 18) {
                // 책 표지
                AsyncImage(url: URL(string: book.bookInfo.coverImage ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    bookCoverPlaceholder
                }
                .frame(width: 86, height: 120)
                .clipped()
                
                // 책 정보
                VStack(alignment: .leading, spacing: 8) {
                    Text(book.bookInfo.title)
                        .font(.customSansSemiBold(size: 16))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.black)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                    
                    Text(book.bookInfo.author ?? "")
                        .font(.customSansRegular(size: 12))
                        .foregroundColor(.gray)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                    
                    Text(book.bookInfo.publisher)
                        .font(.customSansRegular(size: 12))
                        .foregroundColor(.gray)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var bookCoverPlaceholder: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color.gray.opacity(0.2))
            .overlay(
                Image(systemName: "book.fill")
                    .foregroundColor(.gray)
            )
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        AddBookView()
    }
}
