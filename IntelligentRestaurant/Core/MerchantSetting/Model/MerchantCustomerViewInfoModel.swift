//
//  MerchantCustomerViewInfoModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/3/17.
//

import Foundation

/// 商家允許客戶看到的資料
struct MerchantCustomViewInfoModel: Identifiable, Codable {
    
    var uid: String
    var infoShowFilters: [String] = []
    var id: String { uid }
}
