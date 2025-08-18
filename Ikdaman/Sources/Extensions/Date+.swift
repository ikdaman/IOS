//
//  Date+.swift
//  Ikdaman
//
//  Created by 이재혁 on 8/8/25.
//

import Foundation

extension Date {
    /// 현재 날짜를 ISO8601 형식의 문자열로 반환
    var iso8601String: String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }
    
    static var currentISO8601String: String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: Date())
    }
}
