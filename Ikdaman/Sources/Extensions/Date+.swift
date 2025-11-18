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
    
    /// UTC 기준 ISO 8601 문자열 반환
    var utcString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'" // ISO 8601
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: self)
    }
    
    func toString(format: String = "yy/MM/dd HH:mm") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "ko_KR") // 한국 시간
        formatter.timeZone = TimeZone.current
        return formatter.string(from: self)
    }
}
