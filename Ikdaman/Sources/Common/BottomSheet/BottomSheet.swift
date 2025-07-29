//
//  BottomSheet.swift
//  Ikdaman
//
//  Created by 이재혁 on 6/9/25.
//

import UIKit
import SnapKit
import Then

// MARK: - Protocol
protocol BottomSheetDelegate: AnyObject {
    func bottomSheetDidRequestClose(_ controller: BottomSheetViewController)
}

// MARK: - 재사용 가능한 BottomSheetViewController
class BottomSheetViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: BottomSheetDelegate?
    
    private let bottomSheetHeight: CGFloat
    private let contentView: UIView
    
    // MARK: - UI Elements
    private lazy var containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 16
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.1
        $0.layer.shadowOffset = CGSize(width: 0, height: -2)
        $0.layer.shadowRadius = 8
    }
    
    // MARK: - Initialization
    init(contentView: UIView, height: CGFloat) {
        self.contentView = contentView
        self.bottomSheetHeight = height
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presentBottomSheet()
    }
    
    // MARK: - Public Methods
    func show() {
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
        
        guard let topViewController = getTopViewController() else { return }
        topViewController.present(self, animated: true)
    }
    
    func hide() {
        dismissBottomSheet {
            self.dismiss(animated: true)
        }
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        view.addSubview(containerView)
        containerView.addSubview(contentView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(bottomSheetHeight)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        view.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        containerView.addGestureRecognizer(panGesture)
    }
    
    private func presentBottomSheet() {
        containerView.transform = CGAffineTransform(translationX: 0, y: bottomSheetHeight)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.containerView.transform = .identity
        }
    }
    
    private func dismissBottomSheet(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
            self.containerView.transform = CGAffineTransform(translationX: 0, y: self.bottomSheetHeight)
        } completion: { _ in
            completion()
        }
    }
    
    private func getTopViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return nil
        }
        
        return getTopViewController(from: window.rootViewController)
    }
    
    private func getTopViewController(from viewController: UIViewController?) -> UIViewController? {
        if let navigationController = viewController as? UINavigationController {
            return getTopViewController(from: navigationController.visibleViewController)
        }
        
        if let tabBarController = viewController as? UITabBarController {
            return getTopViewController(from: tabBarController.selectedViewController)
        }
        
        if let presentedViewController = viewController?.presentedViewController {
            return getTopViewController(from: presentedViewController)
        }
        
        return viewController
    }
    
    // MARK: - Actions
    @objc private func backgroundTapped(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        if !containerView.frame.contains(location) {
            delegate?.bottomSheetDidRequestClose(self)
        }
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        
        switch gesture.state {
        case .changed:
            if translation.y > 0 {
                containerView.transform = CGAffineTransform(translationX: 0, y: translation.y)
            }
            
        case .ended:
            if translation.y > 80 || velocity.y > 1000 {
                delegate?.bottomSheetDidRequestClose(self)
            } else {
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {
                    self.containerView.transform = .identity
                }
            }
            
        default:
            break
        }
    }
}

// MARK: - 책 정보 ContentView
protocol BookInfoViewDelegate: AnyObject {
    func bookInfoViewDidTapClose(_ view: BookInfoView)
    func bookInfoViewDidTapAdd(_ view: BookInfoView)
}

class BookInfoView: UIView {
    
    // MARK: - Properties
    weak var delegate: BookInfoViewDelegate?
    
    // MARK: - UI Elements
    private lazy var closeButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "xmark"), for: .normal)
        $0.tintColor = .black
        $0.backgroundColor = .clear
        $0.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
    
    private lazy var bookImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
        $0.backgroundColor = .systemGray6
        $0.image = UIImage(systemName: "book.closed")
        $0.tintColor = .systemGray3
    }
    
    private lazy var titleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.textColor = .black
        $0.numberOfLines = 2
        $0.text = "책 제목"
    }
    
    private lazy var authorLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = .systemGray
        $0.numberOfLines = 1
        $0.text = "저자"
    }
    
    private lazy var addButton = UIButton(type: .system).then {
        $0.setTitle("이 책 추가 +", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.backgroundColor = .black
        $0.layer.cornerRadius = 8
        $0.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Public Methods
    func configure(title: String, author: String, imageURL: String? = nil) {
        titleLabel.text = title
        authorLabel.text = author
        
        if let imageURL = imageURL, let url = URL(string: imageURL) {
            // 이미지 로딩 라이브러리 사용
            // bookImageView.kf.setImage(with: url)
            bookImageView.image = UIImage(systemName: "book.closed")
        } else {
            bookImageView.image = UIImage(systemName: "book.closed")
        }
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        backgroundColor = .white
        
        addSubview(closeButton)
        addSubview(bookImageView)
        addSubview(titleLabel)
        addSubview(authorLabel)
        addSubview(addButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().inset(16)
            $0.width.height.equalTo(24)
        }
        
        bookImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.width.equalTo(80)
            $0.height.equalTo(120)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(bookImageView.snp.top)
            $0.leading.equalTo(bookImageView.snp.trailing).offset(16)
            $0.trailing.equalTo(closeButton.snp.leading).offset(-8)
        }
        
        authorLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.equalTo(titleLabel.snp.leading)
            $0.trailing.equalTo(titleLabel.snp.trailing)
        }
        
        addButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }
    }
    
    // MARK: - Actions
    @objc private func closeButtonTapped() {
        delegate?.bookInfoViewDidTapClose(self)
    }
    
    @objc private func addButtonTapped() {
        delegate?.bookInfoViewDidTapAdd(self)
    }
}

// MARK: - ViewModel에서 사용하는 방법
/*
class BarcodeScanViewModel {
    private var currentBottomSheet: BottomSheetViewController?
    
    func showBookInfo(title: String, author: String, imageURL: String? = nil) {
        // 1. 책 정보 뷰 생성
        let bookInfoView = BookInfoView().then {
            $0.delegate = self
        }
        bookInfoView.configure(title: title, author: author, imageURL: imageURL)
        
        // 2. 바텀시트에 책 정보 뷰 삽입
        currentBottomSheet = BottomSheetViewController(contentView: bookInfoView, height: 205).then {
            $0.delegate = self
        }
        
        // 3. 바텀시트 표시
        currentBottomSheet?.show()
    }
    
    private func hideBottomSheet() {
        currentBottomSheet?.hide()
        currentBottomSheet = nil
        // 바코드 스캔 재개 로직
    }
}

extension BarcodeScanViewModel: BottomSheetDelegate {
    func bottomSheetDidRequestClose(_ controller: BottomSheetViewController) {
        hideBottomSheet()
    }
}

extension BarcodeScanViewModel: BookInfoViewDelegate {
    func bookInfoViewDidTapClose(_ view: BookInfoView) {
        hideBottomSheet()
    }
    
    func bookInfoViewDidTapAdd(_ view: BookInfoView) {
        // 책 추가 로직
        hideBottomSheet()
    }
}
*/
