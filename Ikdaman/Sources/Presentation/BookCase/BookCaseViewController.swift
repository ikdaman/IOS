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
            .map { [weak self] in self?.bookCaseView.searchBar.getSearchText() ?? "" }
        
        let input = BookCaseViewModelInput(
            fetchBooks: Observable.just(()),
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
            .do(onNext: { [weak self] books in
                self?.bookCaseView.emptyLibraryView.isHidden = !books.isEmpty
            })
            .bind(to: bookCaseView.bookListView.rx.items(
                cellIdentifier: BookCaseCell.identifier,
                cellType: BookCaseCell.self
            )) { row, book, cell in
                cell.configure(book: book)
            }
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
        layout.minimumInteritemSpacing = 26
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 50, right: 20)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return layout
    }()).then {
        $0.register(BookCaseCell.self, forCellWithReuseIdentifier: BookCaseCell.identifier)
        $0.backgroundColor = .clear
    }
    
    var emptyLibraryView = EmptyLibraryView()
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupViews() {
        addSubview(backgroundView)
        addSubview(emptyLibraryView)
        addSubviews([searchBar, filterView, bookListView])
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
            $0.width.equalTo(188)
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
}

enum FilterType: String, CaseIterable {
    case all = "전체"
    case completed = "완독한 책"
    case inProgress = "독서중인 책"
    
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
                width = 66
            case .inProgress:
                width = 78
            }

            let button = UIButton(type: .system).then {
                $0.setTitle(filter.rawValue, for: .normal)
                $0.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
                $0.setTitleColor(filter == .all ? .white : UIColor(white: 1.0, alpha: 0.6), for: .normal)
                $0.tag = buttons.count
                $0.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            }

            buttons.append(button)
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
            let isSelected = FilterType.allCases[index] == selectedFilter
            button.setTitleColor(isSelected ? .white : #colorLiteral(red: 1, green: 0.9999999404, blue: 1, alpha: 0.6), for: .normal)
        }
    }

    func setFilter(_ filter: FilterType) {
        selectedFilter = filter
        updateButtonStates()
    }

    func getSelectedFilter() -> FilterType {
        return selectedFilter
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
        imageView.kf.setImage(with: URL(string: book.coverImage))
    }
}

class CustomSearchBar: UIView {

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

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
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

    // MARK: - Public Methods
    func onSearchTapped(_ target: Any?, action: Selector) {
        searchButton.addTarget(target, action: action, for: .touchUpInside)
    }

    func getSearchText() -> String {
        return textField.text ?? ""
    }

    func setDelegate(_ delegate: UITextFieldDelegate) {
        textField.delegate = delegate
    }
}

class RowSeparatorView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        let topView = UIView()
        topView.backgroundColor = #colorLiteral(red: 1, green: 0.9999999404, blue: 1, alpha: 0.3)
        let bottomView = UIView()
        bottomView.backgroundColor = .clear

        addSubview(topView)
        addSubview(bottomView)

        topView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(23)
        }
        bottomView.snp.makeConstraints {
            $0.top.equalTo(topView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(27)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class RowSeparatorFlowLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        // Decoration View 등록
        self.register(RowSeparatorView.self, forDecorationViewOfKind: "RowSeparator")
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }
        var allAttributes = attributes

        // 셀만 뽑아서 같은 Y값(= 같은 행) 기준으로 그룹핑
        let cellAttrs = attributes.filter { $0.representedElementCategory == .cell }
        let grouped = Dictionary(grouping: cellAttrs) { attr in
            Int(attr.frame.minY.rounded())
        }

        for (_, rowAttrs) in grouped {
            guard let first = rowAttrs.first else { continue }

            // 한 행 전체 width 만큼 밑줄 뷰 생성
            let decoration = UICollectionViewLayoutAttributes(
                forDecorationViewOfKind: "RowSeparator",
                with: IndexPath(item: first.indexPath.item, section: first.indexPath.section)
            )

            let rowMaxY = rowAttrs.map { $0.frame.maxY }.max() ?? first.frame.maxY
            decoration.frame = CGRect(
                x: 0,
                y: rowMaxY,
                width: collectionView?.bounds.width ?? 0,
                height: 50
            )
            decoration.zIndex = -1 // 셀보다 뒤로

            allAttributes.append(decoration)
        }

        return allAttributes
    }
}
