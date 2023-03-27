//
//  KeyChainManager.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/3/16.
//

import Foundation

class KeyChainManager {
    
    /// 創建新的鑰匙
    static func createNewKey(name: String, key: String) -> Bool {
        guard let keyData = key.data(using: String.Encoding.utf8) else { return false }
        let query = [kSecValueData: keyData, kSecAttrAccount: name, kSecClass: kSecClassGenericPassword] as CFDictionary
        let status = SecItemAdd(query, nil)
        if status != 0 { return false }
        return true
    }
    
    /// 查詢
    static func getKey(name: String) -> Result<String, GetKeyError> {
        let query = [kSecClass: kSecClassGenericPassword, kSecAttrAccount: name, kSecReturnData: true] as CFDictionary
        var retrivedData: AnyObject? = nil
        let _ = SecItemCopyMatching(query, &retrivedData)
        guard let data = retrivedData as? Data,
              let keyInfo = String(data: data, encoding: String.Encoding.utf8) else { return .failure(.notFound) }
        return .success(keyInfo)
    }
    
    /// 更新
    static func updateKey(name: String, newKey: String) -> Bool {
        guard let newKeyData = newKey.data(using: String.Encoding.utf8) else { return false }
        let query = [kSecClass: kSecClassGenericPassword, kSecAttrAccount: name] as CFDictionary
        let updateFields = [kSecValueData: newKeyData] as CFDictionary
        let status = SecItemUpdate(query, updateFields)
        if status != 0 { return false }
        return true
    }
    
    /// 刪除
    static func deleteKey(name: String) {
        let query = [kSecClass: kSecClassGenericPassword, kSecAttrAccount: name] as CFDictionary
        SecItemDelete(query)
    }
}

extension KeyChainManager {
    
    /// 查詢時的錯誤狀態
    enum GetKeyError: LocalizedError {
        case notFound
    }
}
