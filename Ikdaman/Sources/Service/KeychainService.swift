//
//  KeychainService.swift
//  Ikdaman
//
//  Created by Soo on 6/16/25.
//

import Security
import Foundation

enum KeyChainType: String {
    case accessToken
    case refreshToken
}

final class KeychainService {

    static let shared = KeychainService()
    private init() {}

    func save(_ value: String, forKey key: KeyChainType) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }

        // 기존 데이터 삭제 (중복 저장 방지)
        let _ = delete(forKey: key)

        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key.rawValue,
            kSecValueData as String   : data
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    func load(forKey key: KeyChainType) -> String? {
        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key.rawValue,
            kSecReturnData as String  : true,
            kSecMatchLimit as String  : kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == errSecSuccess,
           let data = dataTypeRef as? Data,
           let result = String(data: data, encoding: .utf8) {
            return result
        }
        return nil
    }

    func delete(forKey key: KeyChainType) -> Bool {
        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key.rawValue
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}
