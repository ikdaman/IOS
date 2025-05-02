//
//  HomeView.swift
//  Ikdaman
//
//  Created by 양원식 on 4/27/25.
//

import UIKit
import SnapKit
import Then

final class HomeView: UIView {
    
    // MARK: - UI Components
    let backgroundView = GradientBackgroundView()
    let topBarView = TopBarView()
    
    private let emptyLibraryView = EmptyLibraryView()
    private let addButton = UIButton().then {
        $0.backgroundColor = .black
        $0.layer.cornerRadius = 22.5
        $0.setImage(UIImage(systemName: "plus"), for: .normal)
        $0.tintColor = .white
    }
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupViews() {
        addSubview(backgroundView)
        addSubview(topBarView)
        addSubview(emptyLibraryView)
        addSubview(addButton)
    }
    
    private func setupLayout() {
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        topBarView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.greaterThanOrEqualTo(100)
        }
        
        emptyLibraryView.snp.makeConstraints {
            $0.top.equalTo(topBarView.snp.bottom).offset(110)
            $0.leading.trailing.equalToSuperview()
        }
        
        addButton.snp.makeConstraints {
            $0.width.height.equalTo(45)
            $0.trailing.equalToSuperview().inset(24)
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(76)
        }
    }
    
    // MARK: - Public Methods
    func updateBackgroundGradient(colors: [CGColor]) {
        backgroundView.updateGradient(colors: colors)
    }
}
