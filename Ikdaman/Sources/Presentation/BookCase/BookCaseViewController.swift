//
//  BookCaseViewController.swift
//  Ikdaman
//
//  Created by Soo on 7/7/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import Kingfisher

final class BookCaseViewController: BaseViewController, UIScrollViewDelegate {
    
    // MARK: - Properties
    private let bookCaseView = BookCaseView()
    private let viewModel: BookCaseViewModel
    private let disposeBag = DisposeBag()
    private var output: BookCaseViewModelOutput!
    
    private var scrollEventEnabled = true
    
    // MARK: - Initializer
    init(viewModel: BookCaseViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func loadView() {
        self.view = bookCaseView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bookCaseView.setBackgroundColor()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        bindActions()
        
        bookCaseView.bookListView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Binding
    private func bindViewModel() {
        if output != nil { return } // 중복 방지

        let searchTappedObservable = bookCaseView.searchBar.searchButton.rx.tap
            .map { [weak self] in self?.bookCaseView.searchBar.getSearchText().trimmingCharacters(in: .whitespacesAndNewlines) ?? "" }
        
        let reloadObservable = NotificationCenter.default.rx.notification(.reloadBookList)
            .map { _ in () }   // Void 이벤트로 변환

        let fetchBooksObservable = Observable.merge(
            Observable.just(()),     // 최초 1회 호출
            reloadObservable         // reload 시에도 호출
        )
        
        let input = BookCaseViewModelInput(
            fetchBooks: fetchBooksObservable,
            searchTapped: searchTappedObservable,
            filterTapped: bookCaseView.filterView.filterTapped
                .distinctUntilChanged()
                .do(onNext: { [weak self] _ in
                    // 필터 전환 직후 스크롤 이벤트 잠깐 막기
                    self?.scrollEventEnabled = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self?.scrollEventEnabled = true
                    }
                })
                .asObservable()
        )
        
        output = viewModel.transform(input: input)

        output.books
            .bind(to: bookCaseView.bookListView.rx.items(
                cellIdentifier: BookCaseCell.identifier,
                cellType: BookCaseCell.self
            )) { row, book, cell in
                cell.configure(book: book)
            }
            .disposed(by: disposeBag)
        
        output.books
            .bind(to: bookCaseView.searchResultView.rx.items(
                cellIdentifier: BookCaseSearchCell.identifier,
                cellType: BookCaseSearchCell.self
            )) { _, book, cell in
                cell.configure(book: book)
            }
            .disposed(by: disposeBag)
        
        Observable.combineLatest(
            output.books,
            output.isKeywordSearch
        )
        .observe(on: MainScheduler.instance)
        .subscribe(onNext: { [weak self] books, isSearchMode in
            guard let self = self else { return }
            
            let isEmpty = books.isEmpty
            
            self.bookCaseView.bookListView.isHidden = isSearchMode
            self.bookCaseView.searchResultView.isHidden = !isSearchMode
            self.bookCaseView.emptyLibraryView.isHidden = !(isEmpty && !isSearchMode)
            self.bookCaseView.searchEmptyLibraryView.isHidden = !(isEmpty && isSearchMode)
            
            // ✅ 검색 결과 없을 때 메시지 갱신
            if isSearchMode {
                let title = self.bookCaseView.searchBar.getSearchText()
                self.bookCaseView.searchEmptyLibraryView.messageLabel.text = "\(title)\n에 대한 검색결과가 없어요.\n\n검색어나 필터를 확인해 보거나\n독서를 추가해 보세요 🤓"
            }
        })
        .disposed(by: disposeBag)
    }
    
    private func bindActions() {
        bookCaseView.addButton.rx.tap
            .subscribe(onNext: { _ in
                TabBarNavigator.shared.navigateToSearch()
            })
            .disposed(by: disposeBag)
        
        bookCaseView.bookListView.rx.modelSelected(Book.self)
            .subscribe(onNext: { [weak self] book in
                let vc = BookDetailViewController(
                    viewModel: DefaultBookDetailViewModel(bookId: book.mybookId)
                )
                self?.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        bookCaseView.searchResultView.rx.modelSelected(Book.self)
            .subscribe(onNext: { [weak self] book in
                let vc = BookDetailViewController(
                    viewModel: DefaultBookDetailViewModel(bookId: book.mybookId)
                )
                self?.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - UIScrollViewDelegate
extension BookCaseViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollEventEnabled else { return }
        guard let vm = viewModel as? DefaultBookCaseViewModel else { return }
        guard !vm.isLoading, vm.nowPage < vm.totalPage else { return }

        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height

        if offsetY > contentHeight - frameHeight - MainTabBarSize.height {
            vm.fetchNextPage()
        }
    }

}
