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
    private var disposeBag = DisposeBag()
    
    private lazy var headerView = UIView().then {
        $0.backgroundColor = .white
        
        $0.addSubview(greetingLabel)
        greetingLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(47 + 78) // safeArea 높이 + 상단 여백
            $0.leading.equalToSuperview().inset(34)
            $0.bottom.equalToSuperview().inset(24) // GUI에 나와있지 않아 임의값 설정
        }
    }
    
    private let greetingLabel = UILabel().then {
        $0.text = "닉네임님\n안녕하세요!"
        $0.textColor = .black
        $0.font = .systemFont(ofSize: 24, weight: .bold) // 700
        $0.numberOfLines = 2
    }
    
    lazy var tableView = UITableView().then {
        $0.backgroundColor = .white
        $0.separatorStyle = .none
        $0.register(SettingsTableViewCell.self, forCellReuseIdentifier: SettingsTableViewCell.identifier)
        $0.register(SwitchTableViewCell.self, forCellReuseIdentifier: SwitchTableViewCell.identifier)
        $0.register(TimeTableViewCell.self, forCellReuseIdentifier: TimeTableViewCell.identifier)
    }
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
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
            $0.top.equalTo(headerView.snp.bottom).offset(24)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    @discardableResult
    func setupDI(sections: Observable<[Section]>) -> Self {
        let dataSource = RxTableViewSectionedReloadDataSource<Section>(
                configureCell: { dataSource, tableView, indexPath, item in
                    switch item {
                    case .arrow(let title):
                        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewCell.identifier, for: indexPath) as! SettingsTableViewCell
                        cell.configure(with: title)
                        return cell
                        
                    case .toggle(let title, let isOn):
                        let cell = tableView.dequeueReusableCell(withIdentifier: SwitchTableViewCell.identifier, for: indexPath) as! SwitchTableViewCell
                        cell.configure(with: title, isOn: isOn)
                        return cell
                        
                    case .time(let title, let time):
                        let cell = tableView.dequeueReusableCell(withIdentifier: TimeTableViewCell.identifier, for: indexPath) as! TimeTableViewCell
                        cell.configure(with: title, time: time)
                        return cell
                    }
                }
            )
            
            // 헤더 설정 (필요시)
            dataSource.titleForHeaderInSection = { dataSource, index in
                return "" // 헤더 타이틀이 필요하면 추가
            }
            
            // 바인딩
            sections
                .bind(to: tableView.rx.items(dataSource: dataSource))
                .disposed(by: disposeBag)
        
        return self
    }
}
