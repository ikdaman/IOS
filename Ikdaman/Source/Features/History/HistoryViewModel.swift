//
//  HistoryViewModel.swift
//  Ikdaman
//
//  Created by Soo on 3/27/26.
//

import Foundation

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published var displayMode: DisplayMode = .list
    @Published var historyItems: [HistoryBook] = [
        HistoryBook(start: "251010", finish: "", title: "프로덕트 오너"),
        HistoryBook(start: "250921", finish: "250930", title: "논리의 기술"),
        HistoryBook(start: "251010", finish: "251025", title: "지적 대화를 위한 넓고 얕은 지식..."),
        HistoryBook(start: "251010", finish: "251025", title: "파브르 식물기"),
        HistoryBook(start: "251010", finish: "251012", title: "더 좋은 삶을 위한 철학"),
        HistoryBook(start: "250921", finish: "250930", title: "논리의 기술"),
        HistoryBook(start: "250921", finish: "250930", title: "논리의 기술"),
        HistoryBook(start: "250921", finish: "250930", title: "논리의 기술")
    ]
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let repository: BookRepositoryProtocol

    init(repository: BookRepositoryProtocol = BookRepository()) {
        self.repository = repository
    }
}
