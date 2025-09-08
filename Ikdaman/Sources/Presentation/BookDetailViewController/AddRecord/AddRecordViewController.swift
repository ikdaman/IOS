//
//  AddRecordViewController.swift
//  Ikdaman
//
//  Created by Soo on 9/8/25.
//

import UIKit
import RxSwift

enum RecordInputType {
    case firstImpression   // 첫인상
    case progress          // 진행도 + 생각
    case completion        // 완독 기록
    
    var title: String {
        switch self {
        case .firstImpression:
            return "이 책의 첫인상"
        case .progress:
            return "진행도 기록하기"
        case .completion:
            return "완독을 축하드려요! 🎉"
        }
    }
    
    var placeholder: String {
        switch self {
        case .firstImpression:
            return "처음 책을 보고 들었던 생각을 짧게 적어보세요."
        case .progress:
            return "독서 중 떠오르는 생각을 마음 가는대로 적어보세요."
        case .completion:
            return "이 책이 당신에게 어떤 의미로 남았나요?"
        }
    }
}

class AddRecordViewController: BaseViewController {
    
    // MARK: - Properties
    let topBarView = CustomTopBarView(
        centerTitle: "기록 추가하기"
    )
    private let disposeBag = DisposeBag()
    
    private let viewModel: RecordInputViewModel
    
    // MARK: - UI
    private let titleLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 20)
        $0.textColor = .black
        $0.numberOfLines = 0
    }
    
    private let subtitleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .darkGray
        $0.numberOfLines = 0
    }
    
    private lazy var textView = UITextView().then {
        $0.font = .systemFont(ofSize: 16)
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.4).cgColor
        $0.delegate = self
        $0.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
    }
    
    private let placeholderLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16)
        $0.textColor = .lightGray
    }
    
    private let confirmButton = UIButton(type: .system).then {
        $0.setTitle("확인", for: .normal)
        $0.backgroundColor = .black
        $0.setTitleColor(.white, for: .normal)
        $0.layer.cornerRadius = 10
    }
    init(viewModel: RecordInputViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomBackButton()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        titleLabel.text = viewModel.type.title
        subtitleLabel.text = "1111"
        placeholderLabel.text = viewModel.type.placeholder
        
        view.addSubview(topBarView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(textView)
        textView.addSubview(placeholderLabel)
        view.addSubview(confirmButton)
        
        // Layout
        topBarView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.leading.trailing.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(topBarView.snp.bottom).offset(30)
            $0.left.right.equalToSuperview().inset(20)
        }
        
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.left.right.equalToSuperview().inset(20)
        }
        
        textView.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(20)
            $0.left.right.equalToSuperview().inset(20)
            $0.height.equalTo(200)
        }
        
        placeholderLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.left.equalToSuperview().offset(6)
        }
        
        confirmButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            $0.height.equalTo(50)
        }
        
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
    }
    
    private func bindViewModel() {
        // 필요하다면 ViewModel → View 데이터 바인딩
    }
    
    @objc private func confirmTapped() {
        viewModel.confirmAction()
    }
}
extension AddRecordViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        viewModel.inputText = textView.text
    }
}

final class RecordInputViewModel {
    let type: RecordInputType
    var inputText: String = ""
    
    init(type: RecordInputType) {
        self.type = type
    }
    
    func confirmAction() {
        // 서버 저장 / 화면 이동 등 공통 처리
        print("저장됨: \(inputText)")
    }
}
