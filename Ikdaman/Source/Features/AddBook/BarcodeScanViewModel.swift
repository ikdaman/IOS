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

    private let apiService = AladinAPIService()

    func handleScannedCode(_ code: String) async {
        isScanning = true
        scannedISBN = code
//        do {
//            let aladinBook = try await apiService.getBook(isbn: code)
//            foundBook = Books(
//                myBookId: aladinBook.itemId,
//                createdDate: ISO8601DateFormatter().string(from: Date()),
//                reason: "",
//                bookInfo: BookInfo(
//                    title: aladinBook.title,
//                    author: [aladinBook.author],
//                    coverImage: aladinBook.cover,
//                    description: aladinBook.description ?? "",
//                    ISBN: aladinBook.isbn,
//                    publisher: aladinBook.publisher,
//                    publishDate: aladinBook.pubDate,
//                    link: aladinBook.link
//                )
//            )
//        } catch {
//            errorMessage = "바코드에 해당하는 도서를 찾을 수 없습니다."
//        }
        isScanning = false
    }
}
