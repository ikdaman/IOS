//
//  ManageMyViewController.swift
//  Ikdaman
//
//  Created by Soo on 4/28/25.
//

import UIKit
import RxSwift
import RxCocoa

class ManageMyViewController: BaseViewController {
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
//    private let viewModel: MyViewModel
    
    // MARK: - UI Components
    private let manageMyTitleLabel = UILabel().then {
        $0.text = "내 정보 관리"
        $0.font = .systemFont(ofSize: 26, weight: .bold)
    }
    private let nicknameTitleLabel = UILabel().then {
        $0.text = "* 닉네임"
        $0.font = UIFont.boldSystemFont(ofSize: 14)
    }
    private let nicknameTextField = UITextField().then {
        $0.placeholder = "닉네임"
        $0.backgroundColor = UIColor(white: 0.95, alpha: 1)
        $0.layer.cornerRadius = 8
    }
    private let checkButton = UIButton().then {
        $0.setTitle("중복 확인", for: .normal)
        $0.backgroundColor = .gray
        $0.layer.cornerRadius = 8
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14)
    }
    
    private let birthdateTitleLabel = UILabel().then {
        $0.text = "생년월일"
        $0.font = UIFont.boldSystemFont(ofSize: 16)
    }
    private let birthdateTextField = UITextField().then {
        $0.placeholder = "생년월일"
        $0.backgroundColor = UIColor(white: 0.95, alpha: 1)
        $0.layer.cornerRadius = 8
    }
    
    private let genderTitleLabel = UILabel().then {
        $0.text = "성별"
        $0.font = UIFont.boldSystemFont(ofSize: 16)
    }
    private let maleButton = UIButton().then {
        $0.setTitle("남", for: .normal)
        $0.setTitleColor(.gray, for: .normal)
        $0.backgroundColor = UIColor(white: 0.95, alpha: 1)
        $0.layer.cornerRadius = 8
    }
    private let femaleButton = UIButton().then {
        $0.setTitle("여", for: .normal)
        $0.setTitleColor(.gray, for: .normal)
        $0.backgroundColor = UIColor(white: 0.95, alpha: 1)
        $0.layer.cornerRadius = 8
    }
    
    private let saveButton = UIButton().then {
        $0.setTitle("저장하기", for: .normal)
        $0.backgroundColor = .black
        $0.layer.cornerRadius = 12
        $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    }
    
    private let logoutButton = UIButton().then {
        $0.setTitle("로그아웃", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14)
    }
    private let withdrawButton = UIButton().then {
        $0.setTitle("회원탈퇴", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14)
    }
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // MARK: - Init
    override init() {
//        self.viewModel = viewModel
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.topItem?.title = ""
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        [manageMyTitleLabel, nicknameTitleLabel, nicknameTextField, checkButton,
            birthdateTitleLabel, birthdateTextField,
            genderTitleLabel, maleButton, femaleButton,
            saveButton, logoutButton, withdrawButton
        ].forEach { contentView.addSubview($0) }
    }
    
    private func setupLayout() {
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.greaterThanOrEqualToSuperview()
        }
        
        manageMyTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(29)
            $0.leading.equalToSuperview().inset(23)
        }
        
        nicknameTitleLabel.snp.makeConstraints {
            $0.top.equalTo(manageMyTitleLabel.snp.bottom).offset(37)
            $0.leading.equalToSuperview().offset(20)
        }
        
        nicknameTextField.snp.makeConstraints {
            $0.top.equalTo(nicknameTitleLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalTo(checkButton.snp.leading).offset(-8)
            $0.height.equalTo(48)
        }
        
        checkButton.snp.makeConstraints {
            $0.centerY.equalTo(nicknameTextField)
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.equalTo(80)
            $0.height.equalTo(40)
        }
        
        birthdateTitleLabel.snp.makeConstraints {
            $0.top.equalTo(nicknameTextField.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
        }
        
        birthdateTextField.snp.makeConstraints {
            $0.top.equalTo(birthdateTitleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }
        
        genderTitleLabel.snp.makeConstraints {
            $0.top.equalTo(birthdateTextField.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
        }
        
        maleButton.snp.makeConstraints {
            $0.top.equalTo(genderTitleLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(20)
            $0.width.equalTo(80)
            $0.height.equalTo(48)
        }
        
        femaleButton.snp.makeConstraints {
            $0.top.equalTo(genderTitleLabel.snp.bottom).offset(8)
            $0.leading.equalTo(maleButton.snp.trailing).offset(16)
            $0.width.equalTo(80)
            $0.height.equalTo(48)
        }
        
        saveButton.snp.makeConstraints {
            $0.top.equalTo(maleButton.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(56)
        }
        
        logoutButton.snp.makeConstraints {
            $0.top.equalTo(saveButton.snp.bottom).offset(40)
            $0.leading.equalToSuperview().offset(20)
        }
        
        withdrawButton.snp.makeConstraints {
            $0.top.equalTo(logoutButton.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
        }
    }
}
