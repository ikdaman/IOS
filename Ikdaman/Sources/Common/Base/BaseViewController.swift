//
//  BaseViewController.swift
//  Ikdaman
//
//  Created by 김창규 on 2/11/25.
//

import UIKit
import SnapKit
import Then

class BaseViewController: UIViewController {
    // MARK: - Properties
    
    // MARK: - Init
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 254/255, green: 246/255, blue: 238/255, alpha: 1)
    }
}

// MARK: - Base Functions
extension BaseViewController {
    
}
