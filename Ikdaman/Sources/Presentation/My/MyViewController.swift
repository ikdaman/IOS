//
//  MyViewController.swift
//  Ikdaman
//
//  Created by 이재혁 on 3/3/25.
//

import UIKit
import RxSwift
import RxCocoa

class MyViewController: BaseViewController {
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    private let viewModel: MyViewModel
    
    private var requestTrigger = PublishRelay<Void>()
    
    private lazy var subView = MyView().then {
        $0.tableView.rx.setDelegate(self).disposed(by: disposeBag)
        $0.greetingLabel.text = (UserDefaults.standard.nickName ?? "") + "님\n안녕하세요!"
    }
    
    // MARK: - Init
    init(viewModel: MyViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        bind()
        
        requestTrigger.accept(())
    }
    
    // MARK: - Methods
    private func setupLayout() {
        view.addSubview(subView)
        
        subView.snp.makeConstraints {
            $0.directionalEdges.equalToSuperview()
        }
    }
    
    private func bind() {
        let input = MyViewModelInput(viewDidLoad: requestTrigger.asObservable())
        let output = viewModel.transform(input: input)
        
        subView
            .setupDI(sections: output.sections)
    }
}

extension MyViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 1))
        headerView.backgroundColor = .white
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 7
        case 1:
            return 17
        case 2:
            return 21
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 10))
//        footerView.backgroundColor = #colorLiteral(red: 0.9764705882, green: 0.9764705882, blue: 0.9764705882, alpha: 1)
        footerView.backgroundColor = .systemGray
        return section != 2 ? footerView : nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        10
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 80
        case 1:
            switch indexPath.row {
            case 0:
                return 46
            case 1:
                return 77
            default:
                return 0
            }
        case 2:
            return 38
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let viewModel: ManageMyViewModel = DefaultManageMyViewModel()
            let vc = ManageMyViewController(viewModel: viewModel)
            vc.navigationItem.backButtonTitle = ""
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.section == 2, indexPath.row == 0 {
            let viewModel: NoticeViewModel = NoticeViewModel()
            let vc = NoticeViewController(viewModel: viewModel)
            vc.navigationItem.backButtonTitle = ""
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
