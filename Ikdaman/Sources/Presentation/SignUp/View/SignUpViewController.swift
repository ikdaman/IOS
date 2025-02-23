//
//  SignUpViewController.swift
//  Ikdaman
//
//  Created by 김민수 on 2/23/25.
//

import UIKit
import RxSwift
import SnapKit
import Then

class SingUpViewController: BaseViewController {
    //MARK: - Properties
    var disposeBag = DisposeBag()
//    private let viewModel: LoginViewModel
    
    //MARK: - UI
    var googleLoginButton = UIButton().then {
        $0.setTitle("구글로그인", for: .normal)
    }
    var naverLoginButton = UIButton().then {
        $0.setTitle("네이버로그인", for: .normal)
    }
    var kakaoLoginButton = UIButton().then {
        $0.setTitle("카카오로그인", for: .normal)
    }
    var appleLoginButton = UIButton().then {
        $0.setTitle("애플로그인", for: .normal)
    }
    
    var loginBookImage = UIImageView().then {
        $0.image = UIImage(named: "LoginBookImage")
    }
    
    var guideLabel = UILabel().then {
        $0.text = "가입시 이용약관 및 개인정보처리방침에 동의하게 됩니다."
    }
    
    //MARK: - Init
    override init() {
//        self.viewModel = viewModel
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        initialLayout()
        
        bind()
    }
    
    private func bind() {
//        let input = HomeViewModelInput(
//            fetchBooks: Observable.just(0) // userId
//        )
//        let output = viewModel.transform(input: input)
//
//        output.books
//            .bind { [weak self] books in
//                // tableView 업데이트
//            }.disposed(by: disposeBag)
    }
}

//MARK: - Layout
extension SingUpViewController {
    private func setupViews() {
        view.backgroundColor = #colorLiteral(red: 0.99973768, green: 0.9656706452, blue: 0.9285165668, alpha: 1)
        
        view.addSubview(loginBookImage)
        loginBookImage.snp.makeConstraints {
            $0.top.equalToSuperview().offset(204)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(165)
            $0.width.equalTo(191)
        }
        
        view.addSubview(guideLabel)
        guideLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(479)
            $0.centerX.equalToSuperview()
        }
              
        view.addSubview(googleLoginButton)
        googleLoginButton.snp.makeConstraints {
            $0.top.equalTo(guideLabel.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(360)
            $0.height.equalTo(60)
        }
        
        view.addSubview(naverLoginButton)
        naverLoginButton.snp.makeConstraints {
            $0.top.equalTo(googleLoginButton.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(360)
            $0.height.equalTo(60)
        }
        
        view.addSubview(kakaoLoginButton)
        kakaoLoginButton.snp.makeConstraints {
            $0.top.equalTo(naverLoginButton.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(360)
            $0.height.equalTo(60)
        }
        
        view.addSubview(appleLoginButton)
        appleLoginButton.snp.makeConstraints {
            $0.top.equalTo(kakaoLoginButton.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(360)
            $0.height.equalTo(60)
        }
    }
    
    private func initialLayout() {
        
    }
}
