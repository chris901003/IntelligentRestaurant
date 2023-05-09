//
//  CustomerTableInfoModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/5/5.
//

import Foundation

struct CustomerTableInfoModel: Codable {
    var merchantUid: String
    var merchantName: String
    var remainTime: [RemainTime]
}

struct RemainTime: Codable, Hashable {
    var tableName: String
    var remainTime: String
}

extension CustomerTableInfoModel {
    init(merchantUid: String) {
        self.merchantUid = merchantUid
        self.merchantName = ""
        self.remainTime = []
    }
}

extension CustomerTableInfoModel {
    
    enum CodingKeys: CodingKey {
        case merchantUid, merchantName, remainTime
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let merchantUid = try? container.decode(String.self, forKey: .merchantUid) {
            self.merchantUid = merchantUid
        } else {
            self.merchantUid = ""
        }
        if let merchantName = try? container.decode(String.self, forKey: .merchantName) {
            self.merchantName = merchantName
        } else {
            self.merchantName = ""
        }
        if let remainTime = try? container.decode([RemainTime].self, forKey: .remainTime) {
            self.remainTime = remainTime
        } else {
            self.remainTime = []
        }
    }
}
