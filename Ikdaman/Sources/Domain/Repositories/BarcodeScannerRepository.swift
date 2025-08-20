//
//  BarcodeScannerRepository.swift
//  Ikdaman
//
//  Created by 이재혁 on 8/8/25.
//

import RxSwift
import Moya

protocol BarcodeScannerRepository {
    func addMyBooks(book: AddMyBook) -> Single<Response>
}

