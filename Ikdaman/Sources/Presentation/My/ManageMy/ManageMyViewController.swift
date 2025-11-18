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
    private let viewModel: ManageMyViewModel
    
    // MARK: - UI Components
    let topBarView = CustomTopBarView()
    
    private let manageMyTitleLabel = UILabel().then {
        $0.text = "내 정보 관리"
        $0.font = .systemFont(ofSize: 26, weight: .bold)
    }
    
    private let nicknameTitleLabel = UILabel().then {
        $0.text = "* 닉네임"
        $0.font = UIFont.boldSystemFont(ofSize: 14)
    }
    
    private var nicknameTextField = UITextField().then {
        $0.backgroundColor = UIColor(white: 0.95, alpha: 1)
        $0.layer.cornerRadius = 8
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: $0.frame.height))
        $0.leftView = paddingView
        $0.leftViewMode = .always
    }
    
    private var checkButton = UIButton().then {
        $0.setTitle("중복 확인", for: .normal)
        $0.backgroundColor = .gray
        $0.layer.cornerRadius = 8
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        $0.isEnabled = false
    }
    
    private let birthdateTitleLabel = UILabel().then {
        $0.text = "생년월일"
        $0.font = UIFont.boldSystemFont(ofSize: 16)
    }
    
    private let birthdateTextField = UITextField().then {
        $0.backgroundColor = UIColor(white: 0.95, alpha: 1)
        $0.layer.cornerRadius = 8
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: $0.frame.height))
        $0.leftView = paddingView
        $0.leftViewMode = .always
        $0.keyboardType = .numberPad
    }
    
    private let genderTitleLabel = UILabel().then {
        $0.text = "성별"
        $0.font = UIFont.boldSystemFont(ofSize: 16)
    }
    
    private let maleButton = UIButton().then {
        $0.setTitle("남", for: .normal)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
        $0.setTitleColor(.gray, for: .normal)
        $0.setTitleColor(.white, for: .selected)
        $0.setBackgroundColor(UIColor(white: 0.95, alpha: 1), for: .normal)
        $0.setBackgroundColor(.black, for: .selected)
    }
    
    private let femaleButton = UIButton().then {
        $0.setTitle("여", for: .normal)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
        $0.setTitleColor(.gray, for: .normal)
        $0.setTitleColor(.white, for: .selected)
        $0.setBackgroundColor(UIColor(white: 0.95, alpha: 1), for: .normal)
        $0.setBackgroundColor(.black, for: .selected)
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
    init(viewModel: ManageMyViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomBackButton()
        setupUI()
        setupLayout()
        bind()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubviews([topBarView, scrollView])
        scrollView.addSubview(contentView)

        [manageMyTitleLabel, nicknameTitleLabel, nicknameTextField, checkButton,
            birthdateTitleLabel, birthdateTextField,
            genderTitleLabel, maleButton, femaleButton,
            saveButton, logoutButton, withdrawButton
        ].forEach { contentView.addSubview($0) }
    }
    
    private func setupLayout() {
        topBarView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            $0.leading.trailing.equalToSuperview()
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(topBarView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
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
            $0.top.equalTo(nicknameTitleLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalTo(checkButton.snp.leading).offset(-8)
            $0.height.equalTo(54)
        }
        
        checkButton.snp.makeConstraints {
            $0.centerY.equalTo(nicknameTextField)
            $0.trailing.equalToSuperview().offset(-31)
            $0.width.equalTo(80)
            $0.height.equalTo(54)
        }
        
        birthdateTitleLabel.snp.makeConstraints {
            $0.top.equalTo(nicknameTextField.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        
        birthdateTextField.snp.makeConstraints {
            $0.top.equalTo(birthdateTitleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(54)
        }
        
        genderTitleLabel.snp.makeConstraints {
            $0.top.equalTo(birthdateTextField.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        
        maleButton.snp.makeConstraints {
            $0.top.equalTo(genderTitleLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
            $0.width.equalTo(80)
            $0.height.equalTo(54)
        }
        
        femaleButton.snp.makeConstraints {
            $0.top.equalTo(genderTitleLabel.snp.bottom).offset(10)
            $0.leading.equalTo(maleButton.snp.trailing).offset(10)
            $0.width.equalTo(80)
            $0.height.equalTo(54)
        }
        
        saveButton.snp.makeConstraints {
            $0.top.equalTo(maleButton.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(50)
        }
        
        logoutButton.snp.makeConstraints {
            $0.top.equalTo(saveButton.snp.bottom).offset(40)
            $0.leading.equalToSuperview().offset(20)
        }
        
        withdrawButton.snp.makeConstraints {
            $0.top.equalTo(logoutButton.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
        }
    }
    
    private func bind() {
        
        let genderSelected = Observable.merge(maleButton.rx.tap.map{ "male" }.asObservable(), femaleButton.rx.tap.map{ "female" }.asObservable())
        let isNicknameChecked = BehaviorSubject<Bool>(value: true)
        
        genderSelected.subscribe(onNext :{ [weak self] gender in
            self?.maleButton.isSelected = (gender == "male")
            self?.femaleButton.isSelected = (gender == "female")
        }).disposed(by: disposeBag)
        
        nicknameTextField.rx.text.orEmpty
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }

                // ✅ 10자 초과 방지 (한글자씩 사라지는 문제 없음)
                if text.count > 10 {
                    let limited = String(text.prefix(10))
                    self.nicknameTextField.text = limited
                }

                // 닉네임 입력 시 중복확인 다시 필요
                if text.count > 0 {
                    isNicknameChecked.onNext(false)
                }

                // 중복확인 버튼 상태 갱신
                self.checkButton.isEnabled = text.count > 0
                self.checkButton.backgroundColor = self.checkButton.isEnabled ? .black : .gray
            })
            .disposed(by: disposeBag)
        
        birthdateTextField.rx.text.orEmpty
            .distinctUntilChanged()
            .map { String($0.prefix(8)) } // 8글자 제한
            .bind(to: birthdateTextField.rx.text)
            .disposed(by: disposeBag)

        birthdateTextField.rx.text.orEmpty
            .filter { $0.count == 8 } // 8자리 완성되면
            .subscribe(onNext: { [weak self] input in
                guard let self else { return }
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyyMMdd"
                formatter.locale = Locale(identifier: "ko_KR")

                if let date = formatter.date(from: input) {
                    formatter.dateFormat = "yyyy-MM-dd"
                    self.birthdateTextField.text = formatter.string(from: date)
                }
            })
            .disposed(by: disposeBag)
        
        // 생년월일 텍스트 필드 상태
        let isBirthdateValid = birthdateTextField.rx.text.orEmpty
            .map { [weak self] text -> Bool in
                guard let self = self else { return false }
                print("입력된 날짜:", text)
                let date = self.formatDate(from: text)
                print("변환된 결과:", date as Any)
                return date != nil
            }
            .share(replay: 1)
        
        let input = ManageMyViewModelInput(
            viewWillAppear: self.rx.methodInvoked(#selector(UIViewController.viewWillAppear(_:)))
                    .map { _ in }
                    .asObservable(),
            nicknameChanged: nicknameTextField.rx.text.orEmpty.asObservable(),
            birthdateChanged: birthdateTextField.rx.text.orEmpty.asObservable(),
            genderSelected: genderSelected,
            saveTapped: saveButton.rx.tap.asObservable(),
            logoutTapped: logoutButton.rx.tap.asObservable(),
            withdrawTapped: withdrawButton.rx.tap.asObservable(),
            checkNicknameTapped: checkButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.user
            .take(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] user in
                self?.nicknameTextField.placeholder = user.nickname
                self?.birthdateTextField.placeholder = user.birthdate ?? ""
            
                self?.maleButton.isSelected = user.gender == "male"
                self?.femaleButton.isSelected = user.gender == "female"
            })
            .disposed(by: disposeBag)
        
        // 닉네임 중복 확인 결과 처리
        output.nicknameCheckResult
            .emit(onNext: { [weak self] isAvailable in
                let message = isAvailable ? "사용 가능한 닉네임입니다." : "이미 사용 중인 닉네임입니다."
                let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                self?.present(alert, animated: true)
                
                // ✅ 사용 가능할 때만 true
                isNicknameChecked.onNext(isAvailable)
            })
            .disposed(by: disposeBag)

        output.saveCompleted
            .emit(onNext: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }).disposed(by: disposeBag)
        
        Observable.combineLatest(isNicknameChecked, isBirthdateValid)
            .map { isNicknameOK, isBirthOK in
                return isNicknameOK && isBirthOK
            }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isEnabled in
                self?.saveButton.isEnabled = isEnabled
                self?.saveButton.backgroundColor = isEnabled ? .black : .gray
            })
            .disposed(by: disposeBag)
        
        Observable.merge(output.logoutCompleted.asObservable(),
                         output.withdrawCompleted.asObservable())
            .bind(onNext: { [weak self] in
                self?.navigateToSignup()
            })
            .disposed(by: disposeBag)
    }
    
    private func formatDate(from string: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        inputFormatter.locale = Locale(identifier: "ko_KR")
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy-MM-dd"
        outputFormatter.locale = Locale(identifier: "ko_KR")
        
        if let date = inputFormatter.date(from: string.trimmingCharacters(in: .whitespacesAndNewlines)) {
            return outputFormatter.string(from: date)
        }
        return nil
    }
    
    private func navigateToSignup() {
        let signupViewModel = DefaultSignUpViewModel()
        let signupVC = SignUpViewController(viewModel: signupViewModel)
        let nav = SignUpViewController(viewModel: DefaultSignUpViewModel())

        guard let sceneDelegate = UIApplication.shared.connectedScenes
                .first?.delegate as? SceneDelegate else { return }

        sceneDelegate.window?.rootViewController = nav
        sceneDelegate.window?.makeKeyAndVisible()
    }
}
