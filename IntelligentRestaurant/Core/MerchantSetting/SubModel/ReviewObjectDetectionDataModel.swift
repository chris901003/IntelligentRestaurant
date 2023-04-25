//
//  ReviewObjectDetectionDataModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/4/25.
//

import Foundation

/// 接收已上傳目標檢測訓練資料格式
struct ReviewObjectDetectionDataModel {
    let image: String
    let anno: String
}

/// 發送請求已上傳目標檢測訓練資料格式
struct fetchObjectDetectionTrainInfoModel {
    let merchantUid: String
    let page: Int
    let gap: Int
}
