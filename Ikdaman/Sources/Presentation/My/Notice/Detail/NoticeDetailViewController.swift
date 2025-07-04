//
//  NoticeDetailViewController.swift
//  Ikdaman
//
//  Created by Soo on 6/9/25.
//

import UIKit
import SnapKit
import RxSwift

final class NoticeDetailViewController: UIViewController {

    private let viewModel: NoticeDetailViewModel

    private let titleLabel = UILabel().then {
        $0.textColor = .black
    }
    private let dateLabel = UILabel().then {
        $0.textColor = .black
    }
    private let contentLabel = UILabel().then {
        $0.textColor = .black
    }
    private let backButton = UIButton(type: .system)
    
    private let disposeBag = DisposeBag()

    init(viewModel: NoticeDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        viewModel.loadNotices(id: 1)
    }

    private func setupUI() {
        view.backgroundColor = .white
        title = "공지사항"

        titleLabel.font = .boldSystemFont(ofSize: 18)
        dateLabel.font = .systemFont(ofSize: 14)
        dateLabel.textColor = .gray
        contentLabel.font = .systemFont(ofSize: 16)
        contentLabel.numberOfLines = 0

        backButton.setTitle("목록", for: .normal)
        backButton.setTitleColor(.white, for: .normal)
        backButton.backgroundColor = .black
        backButton.layer.cornerRadius = 8
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        [titleLabel, dateLabel, contentLabel, backButton].forEach { view.addSubview($0) }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        backButton.snp.makeConstraints {
            $0.top.equalTo(contentLabel.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(100)
            $0.height.equalTo(44)
        }
    }

    private func bind() {
        viewModel.notice
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] notice in
                self?.titleLabel.text = notice.title
                self?.dateLabel.text = "25.05.31"
                self?.contentLabel.text = notice.content
            })
            .disposed(by: disposeBag)
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}
