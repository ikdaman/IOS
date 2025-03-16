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
//        let input = MyViewModelInput(
//            setupTableView: () // userId
//        )
        let input = MyViewModelInput(viewDidLoad: requestTrigger.asObservable())
        let output = viewModel.transform(input: input)
        
        subView
            .setupDI(sections: output.sections)
        
        output.sections
//        output.books
//            .bind { [weak self] _ in
//                // tableView 업데이트
//            }.disposed(by: disposeBag)
    }
}

extension MyViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 1))
        footerView.backgroundColor = #colorLiteral(red: 0.937312007, green: 0.937312007, blue: 0.937312007, alpha: 1)
        return section != 2 ? footerView : nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        16
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
}
