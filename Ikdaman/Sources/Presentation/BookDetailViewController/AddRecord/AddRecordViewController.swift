//
//  AddRecordViewController.swift
//  Ikdaman
//
//  Created by Soo on 9/8/25.
//

import UIKit
import RxSwift
import RxRelay
import Moya

enum RecordInputType {
    case firstImpression   // 첫인상
    case progress          // 진행도 + 생각
    case completion        // 완독 기록
    
    var title: String {
        switch self {
        case .firstImpression:
            return "이 책의 첫인상"
        case .progress:
            return "2024년 12월 23일 22시 15분의 기록✏️"
        case .completion:
            return "완독을 축하드려요!🥳"
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
    
    var topTitle: String {
        switch self {
        case .firstImpression:
            return "기록 추가하기"
        case .progress:
            return "기록 추가하기"
        case .completion:
            return "완독 추가하기"
        }
    }
}

class AddRecordViewController: BaseViewController {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let viewType: RecordInputType
    private let viewModel: DefaultAddRecordViewModel
    
    // MARK: - UI
    private let titleLabel = UILabel().then {
        $0.font = .pretendard(.bold, size: 20)
        $0.textColor = .black
        $0.numberOfLines = 0
    }
    
    private let subtitleLabel = UILabel().then {
        $0.font = .pretendard(.medium, size: 12)
        $0.textColor = .black
        $0.numberOfLines = 0
    }
    
    private lazy var textView = UITextView().then {
        $0.font = .pretendard(.regular, size: 13)
        $0.backgroundColor = #colorLiteral(red: 0.9607843757, green: 0.9607843757, blue: 0.9607843757, alpha: 1)
        $0.layer.cornerRadius = 10
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.4).cgColor
        $0.delegate = self
        $0.textContainerInset = UIEdgeInsets(top: 17, left: 15, bottom: 52, right: 15)
    }
    
    private let placeholderLabel = UILabel().then {
        $0.font = .pretendard(.regular, size: 13)
        $0.textColor = #colorLiteral(red: 0.2000000477, green: 0.2000000477, blue: 0.2000000477, alpha: 1)
    }
    
    private var currentTextCount = UILabel().then {
        $0.font = .pretendard(.regular, size: 12)
        $0.textColor = #colorLiteral(red: 0.1725490093, green: 0.1725490093, blue: 0.1725490093, alpha: 1)
        $0.text = "0/500"
    }
    
    private let confirmButton = UIButton(type: .system).then {
        $0.setTitle("확인", for: .normal)
        $0.backgroundColor = .black
        $0.setTitleColor(.white, for: .normal)
        $0.layer.cornerRadius = 10
    }
    
    private let pageView = PageInputView()
    
    init(viewModel: DefaultAddRecordViewModel) {
        self.viewModel = viewModel
        self.viewType = viewModel.type
        super.init()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomBackButton()
        setupUI()
        bindViewModel()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        titleLabel.text = viewType.title
        subtitleLabel.text = "\(viewModel.bookTitle ?? "") / \(viewModel.bookAuthor ?? "")"
        placeholderLabel.text = viewModel.type.placeholder
        
        let topBarView = CustomTopBarView(centerTitle: viewModel.type.topTitle)
        view.addSubviews([topBarView, titleLabel, textView, placeholderLabel, currentTextCount, confirmButton])
        view.addSubview(subtitleLabel)
        
        // Layout
        topBarView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.leading.trailing.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(topBarView.snp.bottom).offset(30)
            $0.left.right.equalToSuperview().inset(20)
        }
        
        switch viewType {
        case .firstImpression:
            let descriptionLabel = UILabel().then {
                $0.text = "* 첫인상은 추후 수정과 삭제가 어려워요.\n나의 첫 생각을 간직하기 위함이니 참고해주세요.☺️"
                $0.font = .pretendard(.regular, size: 12)
                $0.textColor = #colorLiteral(red: 0.5333333611, green: 0.5333333611, blue: 0.5333333611, alpha: 1)
                $0.numberOfLines = 0
            }
            view.addSubviews([subtitleLabel, descriptionLabel])
            
            subtitleLabel.snp.makeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom).offset(10)
                $0.left.right.equalToSuperview().inset(20)
            }
            
            textView.snp.makeConstraints {
                $0.top.equalTo(subtitleLabel.snp.bottom).offset(20)
                $0.left.right.equalToSuperview().inset(20)
                $0.height.equalTo(200)
            }
            
            placeholderLabel.snp.makeConstraints {
                $0.top.equalTo(textView.snp.top).offset(17)
                $0.left.right.equalTo(textView).inset(15)
            }
            
            currentTextCount.snp.makeConstraints {
                $0.bottom.equalTo(textView.snp.bottom).inset(17)
                $0.trailing.equalTo(textView.snp.trailing).inset(16)
            }
            
            descriptionLabel.snp.makeConstraints {
                $0.top.equalTo(textView.snp.bottom).offset(17)
                $0.leading.equalToSuperview().offset(20)
            }
        case .progress:
            let currentPageLabel = UILabel().then {
                $0.text = "어디까지 읽으셨나요?"
                $0.font = .pretendard(.semiBold, size: 14)
                $0.textColor = .black
            }
            
            let readLabel = UILabel().then {
                $0.text = "독서하며 든 생각"
                $0.font = .pretendard(.semiBold, size: 14)
                $0.textColor = .black
            }
            
            pageView.currentPageField.text = "\(viewModel.nowPage ?? 0)"
            pageView.totalPageLabel.text = "/ \(viewModel.totalPage ?? 0)"
            
            view.addSubviews([subtitleLabel, currentPageLabel, pageView, readLabel])
            
            subtitleLabel.snp.makeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom).offset(10)
                $0.left.right.equalToSuperview().inset(20)
            }
            
            currentPageLabel.snp.makeConstraints {
                $0.top.equalTo(subtitleLabel.snp.bottom).offset(40)
                $0.leading.equalToSuperview().offset(20)
            }
            
            pageView.snp.makeConstraints {
                $0.top.equalTo(currentPageLabel.snp.bottom).offset(10)
                $0.leading.equalToSuperview().offset(20)
            }
            
            readLabel.snp.makeConstraints {
                $0.top.equalTo(pageView.snp.bottom).offset(50)
                $0.leading.equalToSuperview().offset(20)
            }
            
            textView.snp.makeConstraints {
                $0.top.equalTo(readLabel.snp.bottom).offset(20)
                $0.left.right.equalToSuperview().inset(20)
                $0.height.equalTo(200)
            }
            
            placeholderLabel.snp.makeConstraints {
                $0.top.equalTo(textView.snp.top).offset(17)
                $0.left.right.equalTo(textView).inset(15)
            }
            
            currentTextCount.snp.makeConstraints {
                $0.bottom.equalTo(textView.snp.bottom).inset(17)
                $0.trailing.equalTo(textView.snp.trailing).inset(16)
            }
            
        case .completion:
            let completeLabel = UILabel().then {
                $0.text = "완독 후의 생각"
                $0.font = .pretendard(.semiBold, size: 14)
                $0.textColor = .black
            }
            
            view.addSubviews([completeLabel])
            
            completeLabel.snp.makeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom).offset(30)
                $0.leading.equalToSuperview().offset(20)
            }
            
            textView.snp.makeConstraints {
                $0.top.equalTo(completeLabel.snp.bottom).offset(10)
                $0.left.right.equalToSuperview().inset(20)
                $0.height.equalTo(200)
            }
            
            placeholderLabel.snp.makeConstraints {
                $0.top.equalTo(textView.snp.top).offset(17)
                $0.left.right.equalTo(textView).inset(15)
            }
            
            currentTextCount.snp.makeConstraints {
                $0.bottom.equalTo(textView.snp.bottom).inset(17)
                $0.trailing.equalTo(textView.snp.trailing).inset(16)
            }
        }
        
        confirmButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-36)
            $0.height.equalTo(50)
        }
    }
    
    private func bindViewModel() {
        let input = AddRecordViewModelInput(
            tapConfirm: confirmButton.rx.tap.asObservable(),
            nowPageText: (viewType == .progress ? (pageView.currentPageField.rx.text.asObservable()) : .empty())
        )
        
        let output = viewModel.transform(input: input)
        
        output.completeSave
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popToRootViewController(animated: false)
            })
            .disposed(by: disposeBag)
        
        output.error
            .subscribe(onNext: { error in
                print("저장 실패: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
}
extension AddRecordViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        viewModel.inputText = textView.text
        currentTextCount.text = "\(textView.text.count)/500"
    }
}

protocol AddRecordViewModel {
    func transform(input: AddRecordViewModelInput) -> AddRecordViewModelOutput
}

struct AddRecordViewModelInput {
    let tapConfirm: Observable<Void>
    let nowPageText: Observable<String?> // ✅ 현재 페이지 입력 바인딩
}

struct AddRecordViewModelOutput {
    let completeSave: PublishRelay<Void>
    let error: PublishRelay<Error>
}

final class DefaultAddRecordViewModel: AddRecordViewModel {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let addRecordUseCase: AddRecordUseCase
    let type: RecordInputType
    let bookId: Int
    var inputText: String = ""
    var createdAt: Date = Date()
    var bookTitle: String? = nil
    var bookAuthor: String? = nil
    var totalPage: Int? = nil
    var nowPage: Int? = nil
    
    private let nowPageRelay = BehaviorRelay<Int?>(value: nil) // ✅ 현재 페이지 저장
    
    // MARK: - Init
    init(addRecordUseCase: AddRecordUseCase, type: RecordInputType, bookId: Int, bookTitle: String? = nil, bookAuthor: String? = nil, totalPage: Int? = nil, nowPage: Int? = nil) {
        self.addRecordUseCase = addRecordUseCase
        self.type = type
        self.bookId = bookId
        self.bookTitle = bookTitle
        self.bookAuthor = bookAuthor
        self.totalPage = totalPage
        self.nowPage = nowPage
    }
    
    // MARK: - Transform
    func transform(input: AddRecordViewModelInput) -> AddRecordViewModelOutput {
        let completeSave = PublishRelay<Void>()
        let error = PublishRelay<Error>()
        
        // ✅ TextField 값 → nowPageRelay
        input.nowPageText
            .map { text -> Int? in
                guard let t = text, let page = Int(t) else { return nil }
                return page
            }
            .bind(to: nowPageRelay)
            .disposed(by: disposeBag)
        
        // ✅ 확인 버튼 탭 → 서버 저장
        input.tapConfirm
            .flatMapLatest { [weak self] _ -> Observable<Response> in
                guard let self = self else { return .empty() }
                
                switch self.type {
                case .firstImpression:
                    return self.addRecordUseCase
                        .addFirstImpression(bookId:self.bookId, impression: self.inputText, createdAt: self.createdAt)
                    
                case .progress:
                    guard let page = self.nowPageRelay.value else {
                        return .error(NSError(domain: "AddRecord", code: -1, userInfo: [NSLocalizedDescriptionKey: "현재 페이지 정보 없음"]))
                    }
                    return self.addRecordUseCase
                        .addProgress(bookId:self.bookId, page: page, content: self.inputText, createdAt: self.createdAt)
                    
                case .completion:
                    return self.addRecordUseCase
                        .addCompletion(bookId:self.bookId, review: self.inputText, createdAt: self.createdAt)
                }
            }
            .subscribe(onNext: { _ in
                completeSave.accept(())
            }, onError: { err in
                error.accept(err)
            })
            .disposed(by: disposeBag)
        
        return AddRecordViewModelOutput(completeSave: completeSave, error: error)
    }
}

class PageInputView: UIView {
    let currentPageField = UITextField().then {
        $0.font = .pretendard(.regular, size: 14)
        $0.textColor = .black
        $0.textAlignment = .center
        $0.keyboardType = .numberPad
        $0.backgroundColor = #colorLiteral(red: 0.9607843757, green: 0.9607843757, blue: 0.9607843757, alpha: 1)
        $0.layer.cornerRadius = 5
        $0.clipsToBounds = true
    }
    
    let totalPageLabel = UILabel().then {
        $0.font = .pretendard(.bold, size: 14)
        $0.textColor = #colorLiteral(red: 0.650980413, green: 0.650980413, blue: 0.650980413, alpha: 1)
        $0.textAlignment = .center
        $0.textColor = .gray
        $0.backgroundColor = #colorLiteral(red: 0.9607843757, green: 0.9607843757, blue: 0.9607843757, alpha: 1)
        $0.layer.cornerRadius = 5
        $0.clipsToBounds = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        addSubviews([currentPageField, totalPageLabel])
        
        currentPageField.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.equalTo(80)   // 첫 박스 너비
            $0.height.equalTo(44)
        }
        
        totalPageLabel.snp.makeConstraints {
            $0.leading.equalTo(currentPageField.snp.trailing).offset(5)
            $0.top.bottom.trailing.equalToSuperview()
            $0.width.equalTo(80)   // 두 번째 박스 너비
            $0.height.equalTo(44)
        }
    }
    
    func configure(totalPage: Int) {
        totalPageLabel.text = "/ \(totalPage)"
    }
}
