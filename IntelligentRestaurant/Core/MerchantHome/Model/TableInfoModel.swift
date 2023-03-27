//
//  TableInfoModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/3/13.
//

import Foundation

/// 一張桌子中有哪些食物資料
struct TableInfoModel: Identifiable {
    var uid: String = ""
    var name: String = ""
    var foodsStatusUid: [String] = []
    var id: String { uid }
}
