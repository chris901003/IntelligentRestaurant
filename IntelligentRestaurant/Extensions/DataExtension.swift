//
//  DataExtension.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/4/15.
//

import Foundation

extension Data {
    
    /// 將資料轉換成String格式，可以支援當中有中文
    public func tranformToString() -> String? {
        guard let message = String(data: self, encoding: .utf8),
              let jsonData = message.data(using: .utf8),
              let messageString = try? JSONDecoder().decode(String.self, from: jsonData) else { return nil }
        return messageString
    }
}
