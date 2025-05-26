//
//  SignUpViewController.swift
//  Ikdaman
//
//  Created by Soo on 4/22/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then
import AuthenticationServices
import GoogleSignIn

class SignUpViewController: BaseViewController {
    //MARK: - Properties
    var disposeBag = DisposeBag()
    private let viewModel: SignUpViewModel
    
    //MARK: - UI
    var loginContainerView = UIView().then {
        $0.isHidden = false
    }

    var completeContainerView = UIView().then {
        $0.isHidden = true
    }
    var googleLoginButton = IconTextButton(title: "구글로 시작하기",
                                           image: UIImage(named: "GmailLogo"),
                                           backgroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
                                           textColor: .black,
                                           borderColor: #colorLiteral(red: 0.8196078431, green: 0.8196078431, blue: 0.8196078431, alpha: 1))
    var naverLoginButton = IconTextButton(title: "네이버로 시작하기",
                                          image: UIImage(named: "MailLogo"),
                                          backgroundColor: #colorLiteral(red: 0.3529411765, green: 0.7647058824, blue: 0.4039215686, alpha: 1),
                                          textColor: .white)
    var kakaoLoginButton = IconTextButton(title: "카카오로 시작하기",
                                          image: UIImage(named: "KakaoLogo"),
                                          backgroundColor: #colorLiteral(red: 0.9803921569, green: 0.8980392157, blue: 0.3019607843, alpha: 1),
                                          textColor: .black)
    var appleLoginButton = IconTextButton(title: "Sign up with Apple",
                                          image: UIImage(named: "AppleLogo"),
                                          backgroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),
                                          textColor: .white)
    
    let loginBookImage = UIImageView().then {
        $0.image = UIImage(named: "BookLogo")
    }
    
    let ikdamanLabel = UILabel().then {
        $0.text = "마음가는 대로 읽는 즐거움\n읽다만."
        $0.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        $0.textAlignment = .center
        $0.numberOfLines = 2
    }
    
    let guideLabel = UILabel().then {
        $0.text = "읽다만에 로그인하고\n더 즐거운 독서를 시작해보세요"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textAlignment = .center
        $0.numberOfLines = 2
    }
    
    var guideLabel2 = UILabel().then {
        $0.text = "가입시 이용약관 및 개인정보처리방침에 동의하게 됩니다."
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
    }
    
    var guideNicknameLabel = UILabel().then {
        $0.text = "닉네임을 입력해주세요."
        $0.textColor = .black
        $0.font = .systemFont(ofSize: 16)
    }
    
    var nicknameTextField = UITextField().then {
        $0.borderStyle = .line
    }
    var isVaildNicknameLabel = UILabel().then {
        $0.text = "사용가능한 닉네임입니다."
        $0.textColor = .black
        $0.font = .systemFont(ofSize: 16)
    }
    
    //MARK: - Init
    init(viewModel: SignUpViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        bind()
    }
    
    private func bind() {
        let input = SignUpViewModelInput(signUpAction:
                                            Observable.merge(
                                                googleLoginButton.rx.tap.map { SnsType.google(viewController: self) },
                                                naverLoginButton.rx.tap.map { SnsType.naver },
                                                kakaoLoginButton.rx.tap.map { SnsType.kakao },
                                                appleLoginButton.rx.tap.map { SnsType.apple }))
        
        let _ = viewModel.transform(input: input)
    }
}

//MARK: - Layout
extension SignUpViewController {
    private func setupViews() {
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        view.addSubview(loginContainerView)
        loginContainerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        loginContainerView.addSubview(loginBookImage)
        loginBookImage.snp.makeConstraints {
            $0.top.equalToSuperview().offset(158)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(90)
        }
        
        loginContainerView.addSubview(ikdamanLabel)
        ikdamanLabel.snp.makeConstraints {
            $0.top.equalTo(loginBookImage.snp.bottom).offset(36)
            $0.centerX.equalToSuperview()
        }
        
        loginContainerView.addSubview(guideLabel)
        guideLabel.snp.makeConstraints {
            $0.top.equalTo(ikdamanLabel.snp.bottom).offset(19)
            $0.centerX.equalToSuperview()
        }
        
        loginContainerView.addSubview(guideLabel2)
        guideLabel2.snp.makeConstraints {
            $0.top.equalTo(guideLabel.snp.bottom).offset(137)
            $0.centerX.equalToSuperview()
        }
              
        loginContainerView.addSubview(googleLoginButton)
        googleLoginButton.snp.makeConstraints {
            $0.top.equalTo(guideLabel2.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(50)
        }
        
        loginContainerView.addSubview(naverLoginButton)
        naverLoginButton.snp.makeConstraints {
            $0.top.equalTo(googleLoginButton.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(50)
        }
        
        loginContainerView.addSubview(kakaoLoginButton)
        kakaoLoginButton.snp.makeConstraints {
            $0.top.equalTo(naverLoginButton.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(50)
        }
        
        loginContainerView.addSubview(appleLoginButton)
        appleLoginButton.snp.makeConstraints {
            $0.top.equalTo(kakaoLoginButton.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(50)
        }
        
        view.addSubview(completeContainerView)
        completeContainerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        let completeImageView = UIImageView().then {
            $0.image = UIImage(named: "CompleteLogin")
        }
        completeContainerView.addSubview(completeImageView)
        completeImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(250)
        }
    }
    
}
