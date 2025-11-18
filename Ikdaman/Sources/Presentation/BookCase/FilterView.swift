//
//  FilterView.swift
//  Ikdaman
//
//  Created by Soo on 11/18/25.
//

import UIKit
import RxSwift
import RxCocoa

enum FilterType: String, CaseIterable {
    case all = "전체"
    case completed = "🎵완독한 책"
    case inProgress = "📖독서중인 책"
    
    var status: String? {
        switch self {
        case .completed:
            return "completed"
        case .inProgress:
            return "in-progress"
        default:
            return nil
        }
    }
}

class FilterView: UIView {
    
    private let stackView = UIStackView()
    private var buttons: [UIButton] = []
    private var selectedFilter: FilterType = .all

    let filterTapped = PublishRelay<FilterType>()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        updateButtonStates()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        updateButtonStates()
    }

    private func setupView() {
        stackView.axis = .horizontal
        stackView.spacing = 10
        addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        FilterType.allCases.forEach { filter in
            let width: CGFloat
            switch filter {
            case .all:
                width = 24
            case .completed:
                width = 68
            case .inProgress:
                width = 80
            }
            
            let button = UIButton(type: .custom).then {
                let title = filter.rawValue

                // 초기(비선택) 상태 attributed title 설정
                $0.setAttributedTitle(makeAttributedTitle(title, isSelected: filter == selectedFilter), for: .normal)
                // 선택 상태용도 미리 설정해두면 update 시 덜 복잡
                $0.setAttributedTitle(makeAttributedTitle(title, isSelected: true), for: .selected)

                $0.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            }

            buttons.append(button)
            button.tag = buttons.count - 1
            stackView.addArrangedSubview(button)

            button.snp.makeConstraints {
                $0.width.equalTo(width)
            }
        }
    }

    @objc private func buttonTapped(_ sender: UIButton) {
        let selected = FilterType.allCases[sender.tag]
        guard selected != selectedFilter else { return }
        selectedFilter = selected
        updateButtonStates()
        filterTapped.accept(selectedFilter)
    }

    private func updateButtonStates() {
        for (index, button) in buttons.enumerated() {
            let filter = FilterType.allCases[index]
            let isSelected = filter == selectedFilter
            
            button.isSelected = isSelected
            
            button.setAttributedTitle(
                makeAttributedTitle(filter.rawValue, isSelected: isSelected),
                for: .normal
            )
        }
    }

    func setFilter(_ filter: FilterType) {
        selectedFilter = filter
        updateButtonStates()
    }

    func getSelectedFilter() -> FilterType {
        return selectedFilter
    }
    
    private func makeAttributedTitle(_ title: String, isSelected: Bool) -> NSAttributedString {
        let color: UIColor = isSelected ? .white : UIColor(white: 1.0, alpha: 0.6)
        let font = UIFont.pretendard(.medium, size: 14)

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .kern: -0.56
        ]
        return NSAttributedString(string: title, attributes: attributes)
    }

}
