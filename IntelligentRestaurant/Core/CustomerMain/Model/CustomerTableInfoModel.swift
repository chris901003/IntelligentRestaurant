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
//    var id: String { merchantUid }
}

struct RemainTime: Codable {
    var tableName: String
    var remainTime: String
    
    // 把所有桌子的時間做排序，最短的移到前面，
    static func sortByTime(_ t1: RemainTime, _ t2: RemainTime) -> Bool {
        return t1.remainTime < t2.remainTime
    }
}

extension CustomerTableInfoModel {
    init(merchantUid: String) {
        self.merchantUid = merchantUid
        self.merchantName = ""
        self.remainTime = []
//        self.uid = UUID().uuidString
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
            // TODO: 不知道這裡為什麼需要merchantUid
            self.merchantUid = ""
//            self.merchantUid = ShareInfoManager.shared.merchant.uid
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
