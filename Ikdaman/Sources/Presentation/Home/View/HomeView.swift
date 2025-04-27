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
    }
    
    // MARK: - Public Methods
    func updateBackgroundGradient(colors: [CGColor]) {
        backgroundView.updateGradient(colors: colors)
    }
}
