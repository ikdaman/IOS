//
//  BookCaseView.swift
//  Ikdaman
//
//  Created by Soo on 11/18/25.
//

import UIKit

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
