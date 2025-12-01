//
//  BookDetailViewController.swift
//  Ikdaman
//
//  Created by Soo on 7/10/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class BookDetailViewController: BaseViewController {

    // MARK: - Properties
    private let bookDetailView = BookDetailView()
    private let viewModel: BookDetailViewModel
    private let disposeBag = DisposeBag()

    private var currentBookInfo: MyBookInfo? // bookInfo 보관
    private let tapModifyLogSubject = PublishSubject<(String, Int)>()
    private let tapDeleteLogSubject = PublishSubject<Int>()
    private let deleteBookRelay = PublishRelay<Void>()

    var tapModifyLog: Observable<(String, Int)> {
        return tapModifyLogSubject.asObservable()
    }

    var tapDeleteLog: Observable<Int> {
        return tapDeleteLogSubject.asObservable()
    }

    // MARK: - Initializer
    init(viewModel: BookDetailViewModel) {
        self.viewModel = viewModel
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCycle
    override func loadView() {
        self.view = bookDetailView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomBackButton()
        bindViewModel()
        bindActions()
        setupKeyboardHandling()
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextViewDidBeginEditing(_:)), name: .bookLogTextViewDidBeginEditing, object: nil)
    }

    // MARK: - Binding
    private func bindViewModel() {
        // 타입 명시
        let tapModifyLogObservable: Observable<(String, Int)> = tapModifyLogSubject.asObservable()
        let tapDeleteLogObservable: Observable<Int> = tapDeleteLogSubject.asObservable()

        // ViewModel Input
        let input = BookDetailViewModelInput(
            fetchBookInfo: Observable.just(()),
            fetchBookHistory: Observable.just(()),
            tapDeleteBook: deleteBookRelay.asObservable(),
            tapModifyLog: tapModifyLogObservable,
            tapDeleteLog: tapDeleteLogObservable
        )

        let output = viewModel.transform(input: input)
        
        // Book Info 바인딩
        output.bookInfo
            .subscribe(onNext: { [weak self] myBookInfo in
                guard let myBookInfo = myBookInfo else { return }
                self?.currentBookInfo = myBookInfo
                self?.bookDetailView.configure(myBookInfo: myBookInfo)
                self?.bookDetailView.bookInfoView.configure(myBookInfo: myBookInfo)
            })
            .disposed(by: disposeBag)
        
        // Book History 바인딩
        output.bookHistory
            .map { $0?.booklogs ?? [] }
            .subscribe(onNext: { [weak self] logs in
                guard let self = self else { return }
                self.bookDetailView.updateLogs(
                    logs,
                    modifyLogSubject: self.tapModifyLogSubject,
                    deleteLogSubject: self.tapDeleteLogSubject
                )
            })
            .disposed(by: disposeBag)
        
        // 삭제 완료 시 pop
        output.completeDelete
            .subscribe(onNext: { [weak self] in
                NotificationCenter.default.post(name: .reloadBookList, object: nil)
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }


    private func bindActions() {
        let recordRepository: RecordRepository = AddRecordRepositorylmpl()
        let addRecordUseCase: AddRecordUseCase = DefaultAddRecordUseCase(recordRepository: recordRepository)

        bookDetailView.emptyImpressionView.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self,
                      let bookId = self.currentBookInfo?.mybookId,
                      let bookTitle = self.currentBookInfo?.bookInfo.title,
                      let bookAuthor = self.currentBookInfo?.bookInfo.author else { return }

                let vm = DefaultAddRecordViewModel(
                    addRecordUseCase: addRecordUseCase,
                    type: .firstImpression,
                    bookId: Int(bookId) ?? 0,
                    bookTitle: bookTitle,
                    bookAuthor: bookAuthor
                )

                let vc = AddRecordViewController(viewModel: vm)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)

        Observable.merge(bookDetailView.progressView.rx.tap.asObservable(),
                         bookDetailView.addBookButton.rx.tap.asObservable())
            .subscribe(onNext: { [weak self] _ in
                guard let self = self,
                      let bookId = self.currentBookInfo?.mybookId,
                      let bookTitle = self.currentBookInfo?.bookInfo.title,
                      let bookAuthor = self.currentBookInfo?.bookInfo.author,
                      let totalPage = self.currentBookInfo?.bookInfo.totalPage,
                      let nowPage = self.currentBookInfo?.nowPage else { return }

                let vm = DefaultAddRecordViewModel(
                    addRecordUseCase: addRecordUseCase,
                    type: .progress,
                    bookId: Int(bookId) ?? 0,
                    bookTitle: bookTitle,
                    bookAuthor: bookAuthor,
                    totalPage: totalPage,
                    nowPage: nowPage
                )

                let vc = AddRecordViewController(viewModel: vm)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)

        bookDetailView.readCompleteButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self,
                      let bookId = self.currentBookInfo?.mybookId else { return }

                let vm = DefaultAddRecordViewModel(
                    addRecordUseCase: addRecordUseCase,
                    type: .completion,
                    bookId: Int(bookId) ?? 0
                )

                let vc = AddRecordViewController(viewModel: vm)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        bookDetailView.topBarView.customButton?.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.deletePopup()
            }).disposed(by: disposeBag)
    }
    
    private func deletePopup() {
        let alertVC = CommonAlertViewController(type: .deleteBook, confirmTitle: "삭제", cancelTitle: "취소")
        
        alertVC.onConfirm = { [weak self] isChecked in
            self?.deleteBookRelay.accept(())
        }
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    private func setupKeyboardHandling() {
        // 1️⃣ 키보드 나타남/사라짐 이벤트 등록
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )

        // 2️⃣ ScrollView 외 빈 공간 탭 시 키보드 내리기
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false // 스크롤도 막지 않음
        bookDetailView.scrollView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTextViewDidBeginEditing(_ notification: Notification) {
        guard let logView = notification.object as? BookLogView else { return }

        // logView 위치를 scrollView 기준에서 화면 기준으로 변환
        let logViewFrameInScroll = logView.convert(logView.bounds, to: bookDetailView.scrollView)

        // scrollView contentOffset 조정
        let scrollPoint = CGPoint(x: 0, y: logViewFrameInScroll.origin.y - 20) // 상단 여백 20
        bookDetailView.scrollView.setContentOffset(scrollPoint, animated: true)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }

        // scrollView contentInset 조정
        bookDetailView.scrollView.contentInset.bottom = keyboardFrame.height
        bookDetailView.scrollView.verticalScrollIndicatorInsets.bottom = keyboardFrame.height
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        // 원래대로
        bookDetailView.scrollView.contentInset.bottom = 0
        bookDetailView.scrollView.verticalScrollIndicatorInsets.bottom = 0
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
