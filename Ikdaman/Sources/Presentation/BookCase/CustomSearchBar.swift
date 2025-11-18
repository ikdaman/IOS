//
//  CustomSearchBar.swift
//  Ikdaman
//
//  Created by Soo on 11/18/25.
//

import UIKit

class CustomSearchBar: UIView, UITextFieldDelegate {

    // MARK: - UI Components
    private let textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "책 제목을 검색해주세요."
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.textColor = .black
        tf.clearButtonMode = .whileEditing
        tf.returnKeyType = .search
        return tf
    }()

    let searchButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "magnifyingglass")
        button.setImage(image, for: .normal)
        button.tintColor = .darkGray
        return button
    }()

    // MARK: - Callback
    var onSearchReturn: ((String) -> Void)?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        textField.delegate = self
        setupButtonAction()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        textField.delegate = self
        setupButtonAction()
    }

    // MARK: - Setup View
    private func setupView() {
        backgroundColor = .white
        layer.cornerRadius = 5
        layer.masksToBounds = true

        addSubview(textField)
        addSubview(searchButton)

        searchButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }

        textField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalTo(searchButton.snp.leading).offset(-8)
            $0.top.bottom.equalToSuperview()
        }

        snp.makeConstraints {
            $0.height.equalTo(48)
        }
    }

    // MARK: - Button Action
    private func setupButtonAction() {
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
    }

    @objc private func searchButtonTapped() {
        onSearchReturn?(textField.text ?? "")
        textField.resignFirstResponder()
    }

    // MARK: - Public Methods
    func getSearchText() -> String {
        return textField.text ?? ""
    }

    func setDelegate(_ delegate: UITextFieldDelegate) {
        textField.delegate = delegate
    }

    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchButtonTapped()
        textField.resignFirstResponder()
        return true
    }
}
