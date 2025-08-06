//
//  NoticeViewController.swift
//  Ikdaman
//
//  Created by 김민수 on 6/8/25.
//

import UIKit
import SnapKit
import RxSwift

final class NoticeViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    let topBarView = CustomTopBarView()
    
    private let noticeLabel = UILabel().then {
        $0.text = "공지사항"
        $0.font = UIFont.systemFont(ofSize: 26, weight: .medium)
    }
    private let tableView = UITableView().then {
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 80
    }
    private let paginationView = UIStackView()
    private var viewModel: NoticeViewModel
    private let disposeBag = DisposeBag()
    
    init(viewModel: NoticeViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.loadNotices(page: nil, limit: nil)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(topBarView)
        topBarView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            $0.leading.trailing.equalToSuperview()
        }
        
        // Title
        view.addSubview(noticeLabel)
        noticeLabel.snp.makeConstraints {
            $0.top.equalTo(topBarView.snp.bottom)
            $0.leading.equalToSuperview().offset(23)
        }
        
        // TableView
        tableView.register(NoticeCell.self, forCellReuseIdentifier: NoticeCell.id)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = .zero
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(noticeLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(120)
        }
        
        // Pagination
        paginationView.axis = .horizontal
        paginationView.spacing = 15
        paginationView.alignment = .center
        paginationView.distribution = .equalSpacing
        var pagination = ["<", "1", ">"]
        if let totalPage = viewModel.notices?.totalPages, totalPage > 1 {
            for page in 2...totalPage {
                pagination.insert("\(page)", at: page)
            }
        }
        
        pagination.forEach { title in
            let button = UIButton()
            button.setTitle(title, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 14)
            
            if Int(title) != nil {
                button.snp.makeConstraints {
                    $0.width.equalTo(7)
                }
                
                button.rx.tap
                    .subscribe(onNext: { [weak self] _ in
                        self?.viewModel.loadNotices(page: Int(title), limit: 10)
                    }).disposed(by: disposeBag)
            }
            paginationView.addArrangedSubview(button)
        }
        view.addSubview(paginationView)
        paginationView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(113)
            $0.height.equalTo(24)
        }
    }
    
    private func bindViewModel() {
        viewModel.reloadTrigger
            .subscribe { [weak self] _ in
                self?.tableView.reloadData()
            }.disposed(by: disposeBag)
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.notices?.notices.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoticeCell.id, for: indexPath) as? NoticeCell else {
            return UITableViewCell()
        }
        if let notices = viewModel.notices?.notices[indexPath.row] {
            cell.configure(with: notices)
        }
        return cell
    }
    
    // MARK: - Expand Logic
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard var notices = viewModel.notices?.notices else { return }
//
//        for i in 0..<notices.count {
//            if i == indexPath.row {
//                // 선택한 셀만 toggle
//                let isCurrentlyExpanded = notices[i].isExpanded ?? false
//                notices[i].isExpanded = !isCurrentlyExpanded
//            } else {
//                // 나머지는 다 닫기
//                notices[i].isExpanded = false
//            }
//        }
//        viewModel.notices?.notices = notices
//        tableView.reloadRows(at: [indexPath], with: .automatic)
        guard var notices = viewModel.notices?.notices else { return }

        for i in 0..<notices.count {
            notices[i].isExpanded = (i == indexPath.row) ? !(notices[i].isExpanded ?? false) : false
        }

        // 🔥 반드시 다시 할당해야 viewModel의 데이터가 갱신됨
        viewModel.notices?.notices = notices

        // 애니메이션 reload
        tableView.beginUpdates()
        tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
}
