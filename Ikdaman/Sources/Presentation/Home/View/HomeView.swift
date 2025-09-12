//
//  HomeView.swift
//  Ikdaman
//
//  Created by 양원식 on 4/27/25.
//

import UIKit
import RxSwift
import RxCocoa

class HomeView: UIView {
    
    private let disposeBag = DisposeBag()
    private let actionTriggers = PublishRelay<HomeTriggerType>()
    
    private var readingBooks: [ReadingBook] = []
    private var currentIndex: Int = 0
    private var editMode: EditMode = .default
    
    // MARK: - UI Components
    let backgroundView = GradientBackgroundView()
    
    let topBarView = TopBarView()
    
    let colorPickerView = ColorPickerView().then {
        $0.alpha = 0
    }
    
    private lazy var dayContainerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 18
        
        $0.addSubviews([bookIconView, dayLabel])
        bookIconView.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(7)
            $0.left.equalToSuperview().inset(15)
            $0.size.equalTo(22)
        }
        
        dayLabel.snp.makeConstraints {
            $0.left.equalTo(bookIconView.snp.right).offset(5)
            $0.right.equalToSuperview().inset(15)
            $0.centerY.equalTo(bookIconView)
        }
    }
    
    private let bookIconView = UIImageView().then {
        $0.image = UIImage(named: "ic_book")
        $0.contentMode = .scaleAspectFit
    }
    
    private let dayLabel = UILabel().then {
        $0.font = .pretendard(.bold, size: 14)
        $0.textColor = .init(hex: "727272")
    }
    
    private let bookTailImageView = UIImageView().then {
        $0.image = UIImage(named: "ic_bubble_tail")
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.minimumInteritemSpacing = 25
        $0.minimumLineSpacing = 0
    }).then {
        $0.backgroundColor = .clear
        $0.showsHorizontalScrollIndicator = false
        $0.isPagingEnabled = false
        $0.decelerationRate = UIScrollView.DecelerationRate.fast
        $0.delegate = self
        $0.dataSource = self
        $0.register(ReadingBookCell.self, forCellWithReuseIdentifier: ReadingBookCell.identifier)
    }
    
    private lazy var bookTitleContainerView = UIView().then {
        $0.addSubviews([titleLabel, authorLabel])
        
        titleLabel.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
        }
        
        authorLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = .black
        $0.font = .pretendard(.semiBold, size: 16)
        $0.textAlignment = .center
        $0.numberOfLines = 1
    }
    
    private let authorLabel = UILabel().then {
        $0.textColor = .black
        $0.font = .pretendard(.regular, size: 12)
        $0.textAlignment = .center
        $0.numberOfLines = 1
    }
    
    private let progressView = ProgressIndicatorView().then {
        $0.backgroundColor = .clear
    }
    
    private lazy var firstImpressionContainerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
        
        let impressionTitleLabel = UILabel().then {
            $0.text = "💕 책의 첫인상"
            $0.textColor = .black
            $0.font = .pretendard(.regular, size: 14)
        }
        
        $0.addSubviews([impressionTitleLabel, impressionContentLabel])
        
        impressionTitleLabel.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview().inset(25)
        }
        
        impressionContentLabel.snp.makeConstraints {
            $0.top.equalTo(impressionTitleLabel.snp.bottom).offset(10)
            $0.horizontalEdges.bottom.equalToSuperview().inset(25)
        }
    }
    
    private let impressionContentLabel = UILabel().then {
        $0.textColor = .init(hex: "666666")
        $0.font = .pretendard(.regular, size: 13)
        $0.numberOfLines = 3
    }
    
    private let addRecordBtn = UIButton().then {
        let title = "이 책의 기록 추가 +"
        let attributedTitle = NSAttributedString(
            string: title,
            attributes: [
                .foregroundColor: UIColor.black,
                .font: UIFont.pretendard(.regular, size: 12),
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
        )
        $0.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    private let addButton = UIButton().then {
        $0.backgroundColor = .init(hex: "060606")
        $0.setImage(UIImage(named: "ic_plus_home"), for: .normal)
        $0.contentMode = .scaleAspectFit
        $0.layer.cornerRadius = 45 / 2
    }
    
    private var emptyLibraryView = EmptyLibraryView().then {
        $0.isHidden = true
    }
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    override func layoutSubviews() {
        super.layoutSubviews()
        setupCollectionViewInsets()
    }
    
    private func setupCollectionViewInsets() {
        // Content inset 설정 (양 옆 여백 - 가운데 정렬을 위해)
        let sideInset: CGFloat = (frame.width - 199) / 2
        collectionView.contentInset = UIEdgeInsets(top: 0, left: sideInset, bottom: 0, right: sideInset)
        collectionView.scrollIndicatorInsets = collectionView.contentInset
    }
    
    private func setupLayout() {
        addSubview(backgroundView)
        addSubviews([topBarView, emptyLibraryView, dayContainerView, colorPickerView, bookTailImageView, collectionView, bookTitleContainerView, progressView, addRecordBtn, firstImpressionContainerView, addButton])
        
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        topBarView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(23)
        }
        
        colorPickerView.snp.makeConstraints {
            $0.top.equalTo(topBarView.colorButton.snp.bottom).offset(12)
            $0.leading.equalToSuperview().inset(20)
            $0.width.equalTo(185)
            $0.height.equalTo(53)
        }
        
        dayContainerView.snp.makeConstraints {
            $0.top.equalTo(topBarView.snp.bottom).offset(20)
            $0.centerX.equalTo(collectionView)
        }
        
        emptyLibraryView.snp.makeConstraints {
            $0.top.equalTo(topBarView.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(175)
        }
        
        bookTailImageView.snp.makeConstraints {
            $0.top.equalTo(dayContainerView.snp.bottom).offset(-1)
            $0.centerX.equalTo(dayContainerView)
            $0.size.equalTo(10)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(dayContainerView.snp.bottom).offset(17)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(284)
        }
        
        bookTitleContainerView.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.bottom).offset(19)
            $0.horizontalEdges.equalToSuperview().inset(22)
        }
        
        progressView.snp.makeConstraints {
            $0.top.equalTo(bookTitleContainerView.snp.bottom).offset(9)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(28)
        }
        
        addRecordBtn.snp.makeConstraints {
            $0.top.equalTo(progressView.snp.bottom).offset(20)
            $0.centerX.equalTo(firstImpressionContainerView)
        }
        
        firstImpressionContainerView.snp.makeConstraints {
            $0.top.equalTo(addRecordBtn.snp.bottom).offset(30)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        addButton.snp.makeConstraints {
            $0.width.height.equalTo(45)
            $0.trailing.equalToSuperview().inset(27)
            $0.bottom.equalToSuperview().inset(MainTabBarSize.height + 30)
        }
    }
    
    private func bind() {
        colorPickerView.colorSelected
            .map { .colorSelected($0) }
            .bind(to: actionTriggers)
            .disposed(by: disposeBag)
        
        addButton.rx.tap
            .map { .addBookButtonTapped }
            .bind(to: actionTriggers)
            .disposed(by: disposeBag)
        
        emptyLibraryView.rx.tap
            .map { .emptyLibraryViewTapped }
            .bind(to: actionTriggers)
            .disposed(by: disposeBag)
        
        topBarView.colorButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.toggleColorPicker()
            })
            .disposed(by: disposeBag)
        
        addRecordBtn.rx.tap
            .map { .addRecordBtnTapped }
            .bind(to: actionTriggers)
            .disposed(by: disposeBag)
    }
    
    private func toggleColorPicker() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            let isHidden = self.colorPickerView.alpha == 0
            self.colorPickerView.alpha = isHidden ? 1 : 0
        }
    }
    
    @discardableResult
    func setupDI(action: PublishRelay<HomeTriggerType>) -> Self {
        actionTriggers
            .bind(to: action)
            .disposed(by: disposeBag)
        
        topBarView
            .setupDI(action: action)
        
        return self
    }
    
    @discardableResult
    func setupDI(colorType: Observable<ColorType>) -> Self {
        colorType
            .withUnretained(self)
            .subscribe(onNext: { `self`, type in
                self.topBarView.colorButton.backgroundColor = type.buttonColor
                UserDefaults.standard.set(type.rawValue, forKey: "backgroundColor")
                self.updateBackgroundGradient(colors: type.gradientColors)
            })
            .disposed(by: disposeBag)
        
        return self
    }
    
    @discardableResult
    func setupDI(readingBooks: Observable<[ReadingBook]>) -> Self {
        readingBooks
            .withUnretained(self)
            .subscribe(onNext: { `self`, books in
                self.readingBooks = books
                self.setupBookTitle()
                self.collectionView.reloadData()
                
                // 초기 스크롤 위치 설정 (첫 번째 책을 가운데로)
                if !books.isEmpty {
                    DispatchQueue.main.async {
                        self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: false)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        return self
    }
    
    @discardableResult
    func setupDI(editMode: BehaviorRelay<EditMode>) -> Self {
        editMode
            .withUnretained(self)
            .subscribe(onNext: { `self`, mode in
                self.editMode = mode
                self.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        return self
    }
    
    // MARK: - Public Methods
    private func setupDayLabel(_ book: ReadingBook) {
        let calculateDaysAgo = calculateDaysAgo(from: book.recentEdit)
        let fullText = "\(calculateDaysAgo)일 전에 읽다만 책이에요"
        let attributedString = NSMutableAttributedString(string: fullText)
        let daysAgo = "\(calculateDaysAgo)일"
        let daysAgoRange = (fullText as NSString).range(of: daysAgo)
        
        attributedString.addAttribute(.foregroundColor,
                                      value: UIColor.black,
                                      range: daysAgoRange)
        
        dayLabel.attributedText = attributedString
    }
    
    private func calculateDaysAgo(from dateString: String) -> Int {
        let formatter = DateFormatter().then {
            $0.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
            $0.timeZone = TimeZone.current
        }
        
        guard let date = formatter.date(from: dateString) else { return 0 }
        
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day], from: date, to: now)
        
        return components.day ?? 0
    }
    
    private func setupBookTitle() {
        defer { setupBookInfoViews(readingBooks.isEmpty) }
        
        guard !readingBooks.isEmpty, currentIndex < readingBooks.count else {
            return
        }
        
        let book = readingBooks[currentIndex]
        titleLabel.text = book.title
        authorLabel.text = book.author
        progressView.progress = CGFloat(book.progress.toInt)
        impressionContentLabel.text = book.firstImpression
        setupDayLabel(book)
    }
    
    private func setupBookInfoViews(_ isHidden: Bool) {
        dayContainerView.isHidden = isHidden
        collectionView.isHidden = isHidden
        progressView.isHidden = isHidden
        addRecordBtn.isHidden = isHidden
        firstImpressionContainerView.isHidden = isHidden
        bookTitleContainerView.isHidden = isHidden
        
        emptyLibraryView.isHidden = !isHidden
    }
    
    func updateBackgroundGradient(colors: [CGColor]) {
        backgroundView.updateGradient(colors: colors)
    }
    
    private func scrollToCenterItem(at index: Int, animated: Bool = true) {
        guard index >= 0 && index < readingBooks.count else { return }
        
        // 레이아웃 업데이트 후 정확한 위치 계산
        collectionView.layoutIfNeeded()
        
        let indexPath = IndexPath(item: index, section: 0)
        
        // 해당 셀의 실제 layoutAttributes 가져오기
        if let attributes = collectionView.layoutAttributesForItem(at: indexPath) {
            let cellCenterX = attributes.center.x
            let collectionViewCenterX = collectionView.bounds.width / 2
            let targetOffsetX = cellCenterX - collectionViewCenterX
            
            collectionView.setContentOffset(CGPoint(x: targetOffsetX, y: 0), animated: animated)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension HomeView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return readingBooks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReadingBookCell.identifier, for: indexPath) as! ReadingBookCell
        let book = readingBooks[indexPath.item]
        cell.configure(with: book, editMode: editMode)
        
        cell.deleteBtn.rx.tap
            .map { .deleteBtnTapped(book.mybookId) }
            .bind(to: actionTriggers)
            .disposed(by: cell.disposeBag)
        return cell
    }
}

// MARK: - UIScrollViewDelegate
extension HomeView: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateCurrentIndex()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let threshold: CGFloat = 50
        
        var newIndex = currentIndex
        
        if velocity.x > 0.5 || (targetContentOffset.pointee.x - scrollView.contentOffset.x) > threshold {
            newIndex = min(currentIndex + 1, readingBooks.count - 1)
        } else if velocity.x < -0.5 || (targetContentOffset.pointee.x - scrollView.contentOffset.x) < -threshold {
            newIndex = max(currentIndex - 1, 0)
        }
        
        // 기본 스크롤 동작 방지
        targetContentOffset.pointee = scrollView.contentOffset
        
        if currentIndex != newIndex {
            currentIndex = newIndex
            setupBookTitle()
            
            // 레이아웃 업데이트 후 스크롤
            DispatchQueue.main.async {
                self.collectionView.performBatchUpdates({
                    self.collectionView.collectionViewLayout.invalidateLayout()
                }) { _ in
                    self.scrollToCenterItem(at: newIndex, animated: true)
                }
            }
        }
    }
    
    private func updateCurrentIndex() {
        // 현재 보이는 셀들 중에서 중앙에 가장 가까운 셀 찾기
        let visibleCells = collectionView.visibleCells
        let collectionViewCenter = collectionView.frame.width / 2 + collectionView.contentOffset.x
        
        var closestCell: UICollectionViewCell?
        var minDistance: CGFloat = CGFloat.greatestFiniteMagnitude
        
        for cell in visibleCells {
            let cellCenter = cell.frame.midX
            let distance = abs(collectionViewCenter - cellCenter)
            
            if distance < minDistance {
                minDistance = distance
                closestCell = cell
            }
        }
        
        if let cell = closestCell,
           let indexPath = collectionView.indexPath(for: cell),
           currentIndex != indexPath.item {
            
            currentIndex = indexPath.item
            
            // 책 정보 업데이트 추가
            setupBookTitle()
            
            // 셀 크기 업데이트
            DispatchQueue.main.async {
                self.collectionView.collectionViewLayout.invalidateLayout()
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HomeView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 가운데 아이템인지 확인
        let isCenterItem = indexPath.item == currentIndex
        
        if isCenterItem {
            return CGSize(width: 199, height: 284)
        } else {
            return CGSize(width: 161, height: 230)
        }
    }
}

extension String {
    var toInt: Int {
        return Int(self) ?? 0
    }
}
