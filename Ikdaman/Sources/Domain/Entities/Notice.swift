//
//  Notice.swift
//  Ikdaman
//
//  Created by Soo on 6/9/25.
//

struct Notices: Codable {
    var notices: [Notice]
    let nowPage: Int
    let totalPage: Int
}

struct Notice: Codable {
    let noticeId: Int
    let title: String
    let content: String
    var isExpanded: Bool = false
}
