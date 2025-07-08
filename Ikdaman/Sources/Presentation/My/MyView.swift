//
//  MyView.swift
//  Ikdaman
//
//  Created by 이재혁 on 3/3/25.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

extension Section: SectionModelType {
    typealias Item = CellType
    
    init(original: Section, items: [Item]) {
        self = original
        self.items = items
    }
}

class MyView: UIView {
    // MARK: - Properties
    let toggleRelay = PublishRelay<Bool>()
    let timeTapRelay = PublishRelay<Void>()
    private var disposeBag = DisposeBag()
    
    private lazy var headerView = UIView().then {
        $0.backgroundColor = .white
        
        $0.addSubview(greetingLabel)
        greetingLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(UIApplication.shared.topPadding + 85) // safeArea 높이 + 상단 여백
            $0.leading.equalToSuperview().inset(23)
            $0.trailing.equalToSuperview().inset(61)
            $0.bottom.equalToSuperview()// GUI에 나와있지 않아 임의값 설정
        }
    }
    
    lazy var greetingLabel = UILabel().then {
        $0.textColor = .black
        $0.font = .systemFont(ofSize: 26, weight: .bold) // 700
        $0.numberOfLines = 2
    }
    
    lazy var tableView = UITableView().then {
        $0.backgroundColor = .white
        $0.separatorStyle = .none
        $0.contentInset = .zero
        $0.sectionHeaderTopPadding = 0
        $0.register(SettingsTableViewCell.self, forCellReuseIdentifier: SettingsTableViewCell.identifier)
        $0.register(AlarmSettingTableViewCell.self, forCellReuseIdentifier: AlarmSettingTableViewCell.identifier)
    }
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    private func setupLayout() {
        addSubview(headerView)
        addSubview(tableView)
        headerView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    private func bind() {

    }
    
    @discardableResult
    func setupDI(sections: Observable<[Section]>) -> Self {
        let dataSource = RxTableViewSectionedReloadDataSource<Section>(
            configureCell: { [weak self] dataSource, tableView, indexPath, item in
                switch item {
                case .arrow(let title):
                    let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewCell.identifier, for: indexPath) as! SettingsTableViewCell
                    cell.configure(with: title, showArrow: title == "내 정보 관리" )
                    return cell
                case .alarm:
                    let cell = tableView.dequeueReusableCell(withIdentifier: AlarmSettingTableViewCell.identifier, for: indexPath) as! AlarmSettingTableViewCell
                    cell.configureBindings()
                    cell.toggleRelay
                        .bind(to: self?.toggleRelay ?? .init())
                        .disposed(by: cell.disposeBag)
                    
                    cell.timeTapRelay
                        .bind(to: self?.timeTapRelay ?? .init())
                        .disposed(by: cell.disposeBag)
                    return cell
                }
            }
        )
            
            // 바인딩
            sections
                .bind(to: tableView.rx.items(dataSource: dataSource))
                .disposed(by: disposeBag)
        
        return self
    }
    
}
