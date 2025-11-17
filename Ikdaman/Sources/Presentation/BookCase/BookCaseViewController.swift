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

class BookCaseView: UIView {
    
    // MARK: - UI Components
    let backgroundView = GradientBackgroundView()
    let searchBar = CustomSearchBar()
    let filterView = FilterView()
    let bookListView = UICollectionView(frame: .zero, collectionViewLayout: {
        let layout = RowSeparatorFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 160)
        layout.minimumLineSpacing = 50
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 21, bottom: 50, right: 21)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return layout
    }()).then {
        $0.register(BookCaseCell.self, forCellWithReuseIdentifier: BookCaseCell.identifier)
        $0.backgroundColor = .clear
    }

    let searchResultView = UICollectionView(frame: .zero, collectionViewLayout: {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 110, height: 230)
        layout.minimumLineSpacing = 40
        layout.minimumInteritemSpacing = 26
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 50, right: 20)
        return layout
    }()).then {
        $0.register(BookCaseSearchCell.self, forCellWithReuseIdentifier: BookCaseSearchCell.identifier)
        $0.backgroundColor = .clear
        $0.isHidden = true // 기본 숨김
    }
    
    var emptyLibraryView = EmptyLibraryView()
    var searchEmptyLibraryView = SearchEmptyLibraryView().then {
        $0.isHidden = true
    }
    let addButton = UIButton().then {
        $0.backgroundColor = .black
        $0.layer.cornerRadius = 22.5
        $0.setImage(UIImage(systemName: "plus"), for: .normal)
        $0.tintColor = .white
    }
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupLayout()
        setupDismissKeyboardGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupViews() {
        addSubview(backgroundView)
        addSubview(emptyLibraryView)
        addSubviews([searchBar, filterView, bookListView, searchResultView, searchEmptyLibraryView])
        addSubview(addButton)
    }
    
    private func setupLayout() {
        backgroundView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(MainTabBarSize.height)
        }
        
        searchBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(35)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }
        
        filterView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(40)
            $0.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(17)
        }
        
        bookListView.snp.makeConstraints {
            $0.top.equalTo(filterView.snp.bottom).offset(17)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(backgroundView.snp.bottom)
        }
        
        emptyLibraryView.snp.makeConstraints {
            $0.top.equalTo(filterView.snp.bottom).offset(17)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(175)
        }
        
        searchResultView.snp.makeConstraints {
            $0.top.equalTo(filterView.snp.bottom).offset(17)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(backgroundView.snp.bottom)
        }
        
        searchEmptyLibraryView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(filterView.snp.bottom).offset(68)
        }
        
        addButton.snp.makeConstraints {
            $0.size.equalTo(45)
            $0.trailing.equalToSuperview().inset(27)
            $0.bottom.equalTo(backgroundView.snp.bottom).inset(27)
        }
    }
    
    // MARK: - Public Methods
    func setBackgroundColor() {
        if let rawValue = UserDefaults.standard.string(forKey: "backgroundColor"),
           let colorType = ColorType(rawValue: rawValue) {
            backgroundView.updateGradient(colors: colorType.gradientColors)
        }
    }
    
    private func setupDismissKeyboardGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false // 다른 터치 이벤트 방해하지 않도록
        addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        endEditing(true)
    }
}

enum FilterType: String, CaseIterable {
    case all = "전체"
    case completed = "🎵완독한 책"
    case inProgress = "📖독서중인 책"
    
    var status: String? {
        switch self {
        case .completed:
            return "completed"
        case .inProgress:
            return "in-progress"
        default:
            return nil
        }
    }
}

class FilterView: UIView {
    
    private let stackView = UIStackView()
    private var buttons: [UIButton] = []
    private var selectedFilter: FilterType = .all

    let filterTapped = PublishRelay<FilterType>()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        updateButtonStates()
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        updateButtonStates()
    }

    private func setupView() {
        stackView.axis = .horizontal
        stackView.spacing = 10
        addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        FilterType.allCases.forEach { filter in
            let width: CGFloat
            switch filter {
            case .all:
                width = 24
            case .completed:
                width = 68
            case .inProgress:
                width = 80
            }
            
            let button = UIButton(type: .custom).then {
                let title = filter.rawValue

                // 초기(비선택) 상태 attributed title 설정
                $0.setAttributedTitle(makeAttributedTitle(title, isSelected: filter == selectedFilter), for: .normal)
                // 선택 상태용도 미리 설정해두면 update 시 덜 복잡
                $0.setAttributedTitle(makeAttributedTitle(title, isSelected: true), for: .selected)

                $0.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            }

            buttons.append(button)
            button.tag = buttons.count - 1
            stackView.addArrangedSubview(button)

            button.snp.makeConstraints {
                $0.width.equalTo(width)
            }
        }

    }

    @objc private func buttonTapped(_ sender: UIButton) {
        let selected = FilterType.allCases[sender.tag]
        guard selected != selectedFilter else { return }
        selectedFilter = selected
        updateButtonStates()
        filterTapped.accept(selectedFilter)
    }

    private func updateButtonStates() {
        for (index, button) in buttons.enumerated() {
            let filter = FilterType.allCases[index]
            let isSelected = filter == selectedFilter
            
            button.isSelected = isSelected
            
            button.setAttributedTitle(
                makeAttributedTitle(filter.rawValue, isSelected: isSelected),
                for: .normal
            )
        }
    }


    func setFilter(_ filter: FilterType) {
        selectedFilter = filter
        updateButtonStates()
    }

    func getSelectedFilter() -> FilterType {
        return selectedFilter
    }
    
    private func makeAttributedTitle(_ title: String, isSelected: Bool) -> NSAttributedString {
        let color: UIColor = isSelected ? .white : UIColor(white: 1.0, alpha: 0.6)
        let font = UIFont.pretendard(.medium, size: 14)

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .kern: -0.56
        ]
        return NSAttributedString(string: title, attributes: attributes)
    }

}

class BookCaseCell: UICollectionViewCell {

    static let identifier = "BookCaseCell"

    private let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        contentView.layer.cornerRadius = 8

        contentView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func configure(book: Book) {
        let highResURLString = book.coverImage.aladinHighResURL()
        
        if let url = URL(string: highResURLString) {
            imageView.kf.setImage(with: url)
        }
    }
}

class BookCaseSearchCell: UICollectionViewCell {
    static let identifier = "BookCaseSearchCell"

    private let imageView = UIImageView()
    private let titleLabel = UILabel().then {
        $0.font = .pretendard(.medium, size: 14)
        $0.numberOfLines = 2
        $0.textAlignment = .left
    }
    private let authorLabel = UILabel().then {
        $0.font = .pretendard(.regular, size: 12)
        $0.textAlignment = .left
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {

        contentView.addSubviews([imageView, titleLabel, authorLabel])
        imageView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(160)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(36)
        }
        
        authorLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(5)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(21)
        }
        
    }

    func configure(book: Book) {
        titleLabel.text = book.title
        authorLabel.text = book.author
        let highResURLString = book.coverImage.aladinHighResURL()
        
        if let url = URL(string: highResURLString) {
            imageView.kf.setImage(with: url)
        }
    }
}

class CustomSearchBar: UIView, UITextFieldDelegate {

    // MARK: - UI Components
    private let textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "책 제목을 검색해주세요."
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.textColor = .black
        tf.clearButtonMode = .whileEditing
        tf.returnKeyType = .search
        return tf
    }()

    let searchButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "magnifyingglass")
        button.setImage(image, for: .normal)
        button.tintColor = .darkGray
        return button
    }()

    // MARK: - Callback
    var onSearchReturn: ((String) -> Void)?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        textField.delegate = self
        setupButtonAction()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        textField.delegate = self
        setupButtonAction()
    }

    // MARK: - Setup View
    private func setupView() {
        backgroundColor = .white
        layer.cornerRadius = 5
        layer.masksToBounds = true

        addSubview(textField)
        addSubview(searchButton)

        searchButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }

        textField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalTo(searchButton.snp.leading).offset(-8)
            $0.top.bottom.equalToSuperview()
        }

        snp.makeConstraints {
            $0.height.equalTo(48)
        }
    }

    // MARK: - Button Action
    private func setupButtonAction() {
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
    }

    @objc private func searchButtonTapped() {
        onSearchReturn?(textField.text ?? "")
        textField.resignFirstResponder()
    }

    // MARK: - Public Methods
    func getSearchText() -> String {
        return textField.text ?? ""
    }

    func setDelegate(_ delegate: UITextFieldDelegate) {
        textField.delegate = delegate
    }

    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchButtonTapped()
        textField.resignFirstResponder()
        return true
    }
}
