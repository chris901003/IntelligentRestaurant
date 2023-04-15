//
//  MerchantRoomSpaceSubModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/4/15.
//

import Foundation

// 在MerchantRoomSapceViewModel中使用

/// 多提供是否被刪除的狀態
struct MerchantRoomSpaceItemModelExt: Identifiable, Equatable {
    var info: MerchantRoomSpaceItemModel
    var isDelete: Bool
    var id: String { info.id }
    
    init(info: MerchantRoomSpaceItemModel, isDelete: Bool = false) {
        self.info = info
        self.isDelete = isDelete
    }
}

/// 在進行初始化請求全部桌子時會使用到的格式
struct AllTableInfoQueryModel: Codable {
    let merchantUid: String
}

/// 在接收所有桌子資料時會使用到的格式
struct AllTableInfoReturnedModel: Codable {
    let results: [MerchantRoomSpaceItemModel]
}
