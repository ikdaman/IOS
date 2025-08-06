//
//  SearchResultsCell.swift
//  Ikdaman
//
//  Created by 이재혁 on 4/27/25.
//

import UIKit
import RxSwift

class SearchResultsCell: UITableViewCell {
    static let identifier = "SearchResultsCell"
    
    var disposeBag = DisposeBag()
    
    // MARK: - Properties
    private let bookImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "소년이 온다(개정판)"
        $0.textColor = .black
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
    }
    
    private let subtitleLabel = UILabel().then {
        $0.text = "한강"
        $0.textColor = .black
        $0.font = .systemFont(ofSize: 12, weight: .regular)
    }
    
    lazy var addBookContainerView = UIView().then {
        $0.backgroundColor = .black
        $0.layer.cornerRadius = 5
        $0.addSubviews([addBookLabel, addImageView])
        
        addBookLabel.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(5)
            $0.left.equalToSuperview().inset(12)
        }
        
        addImageView.snp.makeConstraints {
            $0.left.equalTo(addBookLabel.snp.right).offset(5)
            $0.right.equalToSuperview().inset(12)
            $0.centerY.equalTo(addBookLabel)
            $0.size.equalTo(12)
        }
    }
    
    private let addBookLabel = UILabel().then {
        $0.text = "이 책 추가"
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 12, weight: .bold)
    }
    
    private let addImageView = UIImageView().then {
        $0.image = UIImage(named: "ic_plus")
        $0.contentMode = .scaleAspectFit
    }
    
    private let addBtn = UIButton().then {
        $0.backgroundColor = UIColor(hex: "FF5252")
        $0.setTitle("이 책 추가", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
//        $0.isHidden = true
    }
    
    private let separatorLine = UIView().then {
        $0.backgroundColor = .white
    }
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        attribute()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
        bookImageView.image = nil
    }
    
    // MARK: - Methods
    private func setupLayout() {
        contentView.addSubviews([bookImageView, titleLabel, subtitleLabel, addBookContainerView, separatorLine])
        
        bookImageView.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(15)
            $0.left.equalToSuperview().inset(20)
            $0.width.equalTo(80)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(bookImageView).offset(15)
            $0.left.equalTo(bookImageView.snp.right).offset(15)
            $0.right.equalToSuperview().inset(20)
        }
        
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(3)
            $0.left.equalTo(titleLabel)
            $0.right.equalToSuperview().inset(20)
        }
        
        addBookContainerView.snp.makeConstraints {
            $0.right.bottom.equalToSuperview().inset(20)
        }
        
        separatorLine.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    private func attribute() {
        selectionStyle = .none
    }
    
    private func bind() {
//        addBookContainerView.rx.tap
//            .map { .addBook }
//            .bind(to: actionTriggers)
//            .disposed(by: disposeBag)
    }
    
    func configure(image: String, title: String, subtitle: String, isLast: Bool) {
        bookImageView.loadImage(from: image)
        titleLabel.text = title
        subtitleLabel.text = subtitle
        separatorLine.isHidden = isLast
    }
    
    // TODO: KF 또는 다른 라이브러리 사용 필요할듯
    func loadImage(from urlString: String, into imageView: UIImageView) {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = CGPoint(x: imageView.bounds.midX, y: imageView.bounds.midY)
        activityIndicator.startAnimating()
        imageView.addSubview(activityIndicator)
        
        guard let url = URL(string: urlString) else {
            print("잘못된 URL 정보: \(urlString)")
            activityIndicator.removeFromSuperview()
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                activityIndicator.removeFromSuperview()
                
                if let error = error {
                    print("이미지 다운로드 오류: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200..<300).contains(httpResponse.statusCode) else {
                    print("서버 오류 또는 잘못된 응답")
                    return
                }
                
                guard let data = data, let image = UIImage(data: data) else {
                    print("유효하지 않은 이미지 데이터")
                    return
                }
                
                imageView.image = image
            }
        }.resume()
    }
}
