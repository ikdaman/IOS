//
//  BookDetailViewModel.swift
//  Ikdaman
//
//  Created by Soo on 3/27/26.
//

import Foundation

@MainActor
final class BookDetailViewModel: ObservableObject {
    @Published var book: Books
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var shouldDismiss: Bool = false

    private let repository: BookRepositoryProtocol

    init(book: Books, repository: BookRepositoryProtocol = BookRepository()) {
        self.book = book
        self.repository = repository
    }

    func deleteBook() async {
        isLoading = true
        errorMessage = nil
        do {
            try await repository.deleteBook(bookId: book.myBookId)
            shouldDismiss = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
