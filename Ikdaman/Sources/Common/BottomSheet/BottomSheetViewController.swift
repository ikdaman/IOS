//
//  BottomSheetViewController.swift
//  Ikdaman
//
//  Created by 이재혁 on 8/5/25.
//

import UIKit
import RxSwift

class BottomSheetViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    private let dismissSubject = PublishSubject<Void>()
    
    // MARK: - Properties
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.clipsToBounds = true
    }
    
    private let dimmedView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        $0.alpha = 0
    }
    
    private let closeButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_close")?.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = .black
    }
    
    var didDismiss: Observable<Void> {
        return dismissSubject.asObservable()
    }
    
    // 사용자가 추가할 컨텐츠 뷰
    let contentView = UIView()
    
    // MARK: - Constants
    private let bottomSheetHeight: CGFloat = 205
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showBottomSheet()
    }
    
    // MARK: - Setup UI
    private func setupLayout() {
        view.addSubviews([dimmedView, containerView])
        containerView.addSubviews([closeButton, contentView])
        
        dimmedView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.horizontalEdges.bottom.equalToSuperview()
            $0.height.equalTo(bottomSheetHeight)
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(25)
            $0.trailing.equalToSuperview().inset(20)
            $0.size.equalTo(26)
        }
        
        contentView.snp.makeConstraints {
            $0.top.equalTo(closeButton.snp.bottom).offset(15)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(25)
        }
    }
    
    private func bind() {
        closeButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                self.dismissSubject.onNext(())
                
                self.hideBottomSheet {
                    self.dismiss(animated: false)
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Animations
    private func showBottomSheet() {
        containerView.transform = CGAffineTransform(translationX: 0, y: bottomSheetHeight)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.dimmedView.alpha = 1
            self.containerView.transform = .identity
        }
    }
    
    private func hideBottomSheet(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
            self.dimmedView.alpha = 0
            self.containerView.transform = CGAffineTransform(translationX: 0, y: self.bottomSheetHeight)
        } completion: { _ in
            completion()
        }
    }
}

// MARK: - Usage Extension
extension BottomSheetViewController {
    
    /// 바텀시트를 표시하는 정적 메서드
    /// - Parameters:
    ///   - from: 바텀시트를 표시할 부모 뷰컨트롤러
    ///   - contentView: 바텀시트에 추가할 커스텀 뷰
    @discardableResult
    static func present(customContentView: UIView) -> BottomSheetViewController {
        let bottomSheet = BottomSheetViewController()
        bottomSheet.modalPresentationStyle = .overFullScreen
        bottomSheet.modalTransitionStyle = .crossDissolve
        
        // 커스텀 뷰를 contentView에 추가
        bottomSheet.contentView.addSubview(customContentView)
        customContentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        let topVC = UIApplication.getMostTopViewController()
        topVC?.present(bottomSheet, animated: true)
        
        return bottomSheet
    }
}
