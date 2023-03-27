//
//  ModelWeightModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/3/13.
//

import Foundation

/// 權重資料型態
struct ModelWeightsModel: Codable, Identifiable, Equatable {
    
    var uid: String = ""
    var name: String = ""
    var weightsInfoUid: [String] = []
    var id: String { uid }
}

/// 每個權重會擁有的資料
struct ModelWeightInfoModel: Codable, Identifiable, Equatable {
    
    var uid: String = ""
    var name: String = ""
    var reliability: String = ""
    var someNote: String = ""
    var isSelected: Bool = false
    var id: String { uid }
}
