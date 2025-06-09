//
//  NoticeViewController.swift
//  Ikdaman
//
//  Created by 김민수 on 6/8/25.
//

import UIKit
import SnapKit
import RxSwift

final class NoticeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let tableView = UITableView()
    private let viewModel: NoticeViewModel
    private let disposeBag = DisposeBag()

    init(viewModel: NoticeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.loadNotices(page: 1)
    }

    private func setupUI() {
        title = "공지사항"
        view.backgroundColor = .black

        tableView.register(NoticeCell.self, forCellReuseIdentifier: NoticeCell.id)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = .zero

        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    private func bindViewModel() {
        viewModel.reloadTrigger
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.notices?.notices.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoticeCell.id, for: indexPath) as? NoticeCell else { return UITableViewCell() }
        if let notice = viewModel.notices?.notices[indexPath.row] {
            cell.configure(index: indexPath.row, notice: notice)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selected = viewModel.notices?.notices[indexPath.row].noticeId {
            let detailVM = NoticeDetailViewModel(fetchUseCase: viewModel.fetchUseCase, id: selected)
            let detailVC = NoticeDetailViewController(viewModel: detailVM)
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}
