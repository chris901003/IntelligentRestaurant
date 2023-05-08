//
//  CustomerHomeViewSupportModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/5/8.
//

import Foundation

/// 用在客戶端選則過濾剩餘等待時間的資料
struct CustomerShowTableInfoCategoryModel: Identifiable {
    let id: String = UUID().uuidString
    var name: String
    var isSelected: Bool
}
