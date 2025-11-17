//
//  String+.swift
//  Ikdaman
//
//  Created by Soo on 11/17/25.
//

import Foundation

extension String {
    func aladinHighResURL() -> String {
        // cover500이 이미 있으면 그대로 반환
        if self.contains("cover500") { return self }
        
        var newURL = self
        
        // 알라딘 표준 경로 변환
        let patterns = ["coversum", "cover", "cover100", "cover200"]
        for pattern in patterns {
            if newURL.contains(pattern) {
                newURL = newURL.replacingOccurrences(of: pattern, with: "cover500")
                return newURL
            }
        }
        
        // 패턴이 없는 경우도 cover500을 붙여 시도
        if let lastSlash = newURL.lastIndex(of: "/") {
            let prefix = newURL[..<lastSlash]
            let filename = newURL[lastSlash...]
            return "\(prefix)/cover500\(filename)"
        }

        return newURL
    }
}
