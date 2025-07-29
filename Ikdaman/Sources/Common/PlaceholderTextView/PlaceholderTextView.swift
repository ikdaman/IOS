//
//  PlaceholderTextView.swift
//  Ikdaman
//
//  Created by 이재혁 on 5/25/25.
//

import UIKit

class PlaceholderTextView: UITextView {
    
    private let placeholderLabel = UILabel().then {
        $0.numberOfLines = 0
    }
    
    var placeholder: String? {
        didSet {
            placeholderLabel.text = placeholder
        }
    }
    
    var placeholderColor: UIColor = .placeholderText {
        didSet {
            placeholderLabel.textColor = placeholderColor
        }
    }
    
    var placeholderFont: UIFont? {
        didSet {
            placeholderLabel.font = placeholderFont
        }
    }
    
    // 기본 init
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupPlaceholder()
    }
    
    // 커스텀 init
    convenience init(
        placeholder: String? = nil,
        placeholderFont: UIFont? = nil,
        placeholderColor: UIColor = .placeholderText
    ) {
        self.init(frame: .zero, textContainer: nil)
        
        self.placeholder = placeholder
        self.placeholderFont = placeholderFont ?? self.font
        self.placeholderColor = placeholderColor
        
        // 설정 적용
        placeholderLabel.text = placeholder
        placeholderLabel.font = self.placeholderFont
        placeholderLabel.textColor = placeholderColor
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPlaceholder()
    }
    
    private func setupPlaceholder() {
        addSubview(placeholderLabel)
        
        placeholderLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(17)
            $0.horizontalEdges.equalToSuperview().inset(15)
        }
        
        textContainer.lineFragmentPadding = 0
        textContainerInset = UIEdgeInsets(top: 17, left: 15, bottom: 8, right: 15)
        
        // 초기 설정
        placeholderLabel.textColor = placeholderColor
        placeholderLabel.font = placeholderFont ?? font
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textDidChange),
            name: UITextView.textDidChangeNotification,
            object: self
        )
    }
    
    @objc private func textDidChange() {
        placeholderLabel.isHidden = !text.isEmpty
    }
    
    override var text: String! {
        didSet {
            placeholderLabel.isHidden = !text.isEmpty
        }
    }
    
    override var font: UIFont? {
        didSet {
            // TextView 폰트가 변경되면 placeholder 폰트도 함께 변경 (별도 설정이 없는 경우)
            if placeholderFont == nil {
                placeholderLabel.font = font
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
