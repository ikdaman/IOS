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

final class BookCaseViewController: BaseViewController {
    
    // MARK: - Properties
    private let bookCaseView = BookCaseView()
    private let viewModel: BookCaseViewModel
    private let disposeBag = DisposeBag()
    
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
        bookCaseView.bookListView.delegate = self
        bookCaseView.bookListView.dataSource = self
    }
    
    // MARK: - Binding
    private func bindViewModel() {
        let input = BookCaseViewModelInput(fetchBooks: Observable.just(()),
                                           filterTapped: bookCaseView.filterView.filterTapped.asObservable())
        
        let output = viewModel.transform(input: input)
        
        output.books
            .do(onNext: { [weak self] books in
                self?.bookCaseView.emptyLibraryView.isHidden = books.isEmpty
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
        self.bookCaseView.addButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                let vc = BookDetailViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
            }).disposed(by: disposeBag)
    }
    
}

extension BookCaseViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10 // 임의의 아이템 개수
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookCaseCell.identifier, for: indexPath) as? BookCaseCell else {
            return UICollectionViewCell()
        }
        cell.backgroundColor = .blue
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("선택된 셀: \(indexPath.item + 1)")
    }
}

class BookCaseView: UIView {
    
    // MARK: - UI Components
    let backgroundView = GradientBackgroundView()
    let searchBar = CustomSearchBar()
    let filterView = FilterView()
    let bookListView = UICollectionView(frame: .zero, collectionViewLayout: {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 23, right: 21)
        layout.minimumLineSpacing = 50
        layout.minimumInteritemSpacing = 26
        layout.itemSize = CGSize(width: 100, height: 160)
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
    
    var status: String {
        switch self {
        case .completed:
            return "completed"
        case .inProgress:
            return "in-progress"
        default:
            return ""
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
        contentView.backgroundColor = .systemBlue
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

    private let searchButton: UIButton = {
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
