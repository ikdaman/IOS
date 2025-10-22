//
//  BarcodeScannerViewModel.swift
//  Ikdaman
//
//  Created by 이재혁 on 5/25/25.
//

import Foundation
import RxSwift
import RxCocoa
import AVFoundation

enum BarcodeScannerriggerType {
    case scannedIsbn(String)
    case closeBottomSheet
    case backBtnTapped
    
    case addBookTapped
}

class BarcodeScannerViewModel {
    typealias ViewModel = BarcodeScannerViewModel
    private let disposeBag = DisposeBag()
    
    private let barcodeScannerUseCase: BarcodeScannerUseCase
    
    private var hasPermissionRelay = PublishRelay<Void>()
    /// isbn으로 검색한 책
    private var searchedBookRelay = BehaviorRelay<AladinBook>(value: .empty)
    
    private var outputRequest = PublishRelay<RequestDestinationVC>()
    
    init(
        barcodeScannerUseCase: BarcodeScannerUseCase = DefaultBarcodeScannerUseCase(barcodeScannerRepository: BarcodeScannerRepositoryImpl())
    ) {
        self.barcodeScannerUseCase = barcodeScannerUseCase
    }
    struct Input {
        let viewDidLoad: Observable<Void>
        let action: PublishRelay<BarcodeScannerriggerType>
    }
    
    struct Output {
        let setupBarcodeScanner: Observable<Void>
        let scannedBook: Observable<AladinBook>
        let outputRequest: Observable<RequestDestinationVC>
    }
    
    func transform(req: ViewModel.Input) -> ViewModel.Output {
        req.viewDidLoad
            .subscribe(onNext: { [weak self] _ in
                Task {
                    await self?.setupScanner()
                }
            })
            .disposed(by: disposeBag)
        
        req.action
            .subscribe(onNext: actionTriggerRequest)
            .disposed(by: disposeBag)
        
        return Output(
            setupBarcodeScanner: hasPermissionRelay.asObservable(),
            scannedBook: searchedBookRelay.asObservable(),
            outputRequest: outputRequest.asObservable())
    }
    
    func actionTriggerRequest(action: BarcodeScannerriggerType) {
        switch action {
        case .scannedIsbn(let isbn):
            print("ISBN > \(isbn)")
            AladinAPIService.shared.searchBook(isbn: isbn) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    print("ISBN 책 응답 > \(response)")
                    guard let book = response.item.first else {
                        print("책 정보 가져올 수 없음")
                        return
                    }
                    searchedBookRelay.accept(book)
                case .failure(let error):
                    print("검색 에러: \(error)")
                }
            }
            
        case .closeBottomSheet:
            outputRequest.accept(.close)
            
        case .addBookTapped:
            print("바텀시트 이 책 추가 탭")
            let dateString = Date.currentISO8601String
            let book = searchedBookRelay.value
            let addMyBook = AddMyBook(title: book.title, writer: book.author, publisher: book.publisher,
                                      isbn: book.isbn, page: book.subInfo?.itemPage ?? 0, coverImage: book.cover,
                                      itemId: book.itemId, impression: "", createdAt: dateString)
            
            barcodeScannerUseCase.addBook(book: addMyBook)
                .flatMap { response -> Single<Void> in
                    if response.statusCode == 201 {
                        return .just(())
                    } else {
                        // 실패: 에러 반환
                        return .error(NSError(domain: "", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: "Add book failed with status: \(response.statusCode)"]))
                    }
                }
                .asObservable()
                .materialize()
                .withUnretained(self)
                .subscribe(onNext: { `self`, event in
                    switch event {
                    case .completed:
                        print("책 추가 성공")
                        self.outputRequest.accept(.close)
                    case .error(let error):
                        print("책 추가 실패 > \(error)")
                    default: break
                    }
                })
                .disposed(by: disposeBag)
            
        case .backBtnTapped:
            outputRequest.accept(.close)
        }
        
    }
    
    private func setupScanner() async {
        let hasPermission = await checkCameraPermission()
            if hasPermission {
                print("카메라 권한 허용됨")
                hasPermissionRelay.accept(())
            } else {
                // 권한 거부 처리
                print(BarcodeScannerError.permissionDenied.localizedDescription)
            }
    }
    
    private func fetchAladinBook() {
        
    }
}

extension BarcodeScannerViewModel {
    private func checkCameraPermission() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return true
        case .notDetermined:
            return await withCheckedContinuation { continuation in
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    continuation.resume(returning: granted)
                }
            }
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }
    
    enum BarcodeScannerError: Error {
        case cameraNotAvailable
        case cameraInputFailed
        case metadataOutputFailed
        case permissionDenied
        
        var localizedDescription: String {
            switch self {
            case .cameraNotAvailable:
                return "카메라를 찾을 수 없습니다."
            case .cameraInputFailed:
                return "카메라 입력을 설정할 수 없습니다."
            case .metadataOutputFailed:
                return "메타데이터 출력을 설정할 수 없습니다."
            case .permissionDenied:
                return "카메라 권한이 거부되었습니다."
            }
        }
    }
}

extension BarcodeScannerViewModel {
    enum RequestDestinationVC {
        case close
        case closeAll
    }
}
