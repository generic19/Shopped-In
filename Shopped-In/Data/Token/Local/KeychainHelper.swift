//
//  KeychainHelper.swift
//  Shopped-In
//
//  Created by Omar Abdelaziz on 01/06/2025.
//

import Foundation
import Security

final class KeychainHelper {
    private func createQuery(service: String, account: String, data: Data? = nil) ->
    (asOriginalDic:[CFString : Any], asCFDic: CFDictionary) {
        var query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ] as [CFString : Any]
        
        if let data = data {
            query[kSecValueData] = data
        }
        
        return (query, query as CFDictionary)
    }

    func save(_ value: String, service: String, account: String) {
        let data = Data(value.utf8)
        SecItemDelete(createQuery(service: service, account: account).asCFDic)
        
        SecItemAdd(createQuery(service: service, account: account, data: data).asCFDic, nil)
    }

    func load(service: String, account: String) -> String? {
        var query = createQuery(service: service, account: account).asOriginalDic
        query[kSecReturnData] = true
        query[kSecMatchLimit] = kSecMatchLimitOne

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func delete(service: String, account: String) {
        SecItemDelete(createQuery(service: service, account: account).asCFDic)
    }
}
