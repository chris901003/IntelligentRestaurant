//
//  CustomerSearchModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/5/6.
//

import Foundation

/// 客戶搜尋商家使用
struct CustomerSearchMerchantModel: Encodable {
    var name: String
    var customerUid: String
}

/// 客戶獲取詳細店家資料使用
struct CustomerFetchMerchantDetailModel: Encodable {
    var customerUid: String
    var merchantUid: String
}
