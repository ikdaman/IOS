//
//  BarcodeScanViewModel.swift
//  Ikdaman
//
//  Created by Soo on 3/27/26.
//

import Foundation

@MainActor
final class BarcodeScanViewModel: ObservableObject {
    @Published var scannedISBN: String?
    @Published var isScanning: Bool = false
    @Published var errorMessage: String?
    @Published var foundBook: Books?
    @Published var pageCount: String = ""

    private let apiService = AladinAPIService()

    func handleScannedCode(_ code: String) async {
        isScanning = true
        scannedISBN = code
        do {
            let aladinBook = try await apiService.getBook(isbn: code)
            if let itemPage = aladinBook.subInfo?.itemPage, itemPage > 0 {
                self.pageCount = String(itemPage)
            }
            
            foundBook = Books(
                myBookId: aladinBook.itemId,
                createdDate: ISO8601DateFormatter().string(from: Date()),
                reason: "",
                bookInfo: BookInfo(
                    source: "ALADIN",
                    aladinId: aladinBook.itemId,
                    isbn: aladinBook.isbn13 ?? aladinBook.isbn,
                    title: aladinBook.title,
                    author: aladinBook.author,
                    publisher: aladinBook.publisher,
                    description: aladinBook.description ?? "",
                    totalPage: Int(pageCount) ?? aladinBook.subInfo?.itemPage ?? 0,
                    publishDate: aladinBook.pubDate,
                    coverImage: aladinBook.cover.replacingOccurrences(of: "http://", with: "https://"),
                    link: aladinBook.link
                )
            )
        } catch {
            errorMessage = "바코드에 해당하는 도서를 찾을 수 없습니다."
        }
        isScanning = false
    }
}
