//
//  BarcodeScannerUseCase.swift
//  Ikdaman
//
//  Created by 이재혁 on 8/8/25.
//

import Foundation
import RxSwift
import Moya

protocol BarcodeScannerUseCase {
    func addBook(book: AddMyBook) -> Single<Response>
}

final class DefaultBarcodeScannerUseCase: BarcodeScannerUseCase {
    private let barcodeScannerRepository: BarcodeScannerRepository
    
    // MARK: - Init
    init(barcodeScannerRepository: BarcodeScannerRepository) {
        self.barcodeScannerRepository = barcodeScannerRepository
    }
    
    func addBook(book: AddMyBook) -> Single<Response> {
        barcodeScannerRepository.addMyBooks(book: book)
    }
}
