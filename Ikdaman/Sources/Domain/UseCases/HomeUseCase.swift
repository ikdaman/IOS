//
//  HomeUseCase.swift
//  Ikdaman
//
//  Created by 이재혁 on 8/25/25.
//

import Foundation
import RxSwift
import Moya

protocol HomeUseCase {
    func getReadingBooks() -> RxSwift.Observable<ReadingBookInfo>
}

final class DefaultHomeUseCase: HomeUseCase {
    private let homeRepository: HomeRepository
    
    // MARK: - Init
    init(homeRepository: HomeRepository) {
        self.homeRepository = homeRepository
    }
    
    func getReadingBooks() -> RxSwift.Observable<ReadingBookInfo> {
        homeRepository.getReadingBooks()
    }
}
