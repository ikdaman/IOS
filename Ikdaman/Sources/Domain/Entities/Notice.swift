//
//  Notice.swift
//  Ikdaman
//
//  Created by Soo on 6/9/25.
//

struct Notices: Codable {
    var notices: [Notice]
    let hasNext: Bool
    let currentPage: Int
    let totalPages: Int
}

struct Notice: Codable {
    let noticeId: Int
    let title: String
    let uploadedAt: String
    var isExpanded: Bool? = false
}
