//
//  FoodStatusInfoModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/3/11.
//

import Foundation

/// 食物當前狀態
struct FoodStatusInfoModel: Identifiable {
    var uid: String
    var name: String
    var trackId: String
    var foodRemain: String
    var foodRemainTime: String
    var foodRemainLine: [String]
    var timeLine: [Int]
    var id: String { uid }
    
    init(uid: String, name: String, trackId: String, foodRemain: String, foodRemainTime: String, foodRemainLine: [String]) {
        self.uid = uid
        self.name = name
        self.trackId = trackId
        self.foodRemain = foodRemain
        self.foodRemainTime = foodRemainTime
        self.foodRemainLine = foodRemainLine
        self.timeLine = [Int](0..<foodRemainLine.count)
    }
}

extension FoodStatusInfoModel {
    
    /// 將資料轉成畫圖使用的資料
    func convertToFoodStatusChartModel() -> [FoodStatusChartModel] {
        var result: [FoodStatusChartModel] = []
        for idx in 0..<self.foodRemainLine.count {
            result.append(.init(remain: self.foodRemainLine[idx], time: self.timeLine[idx]))
        }
        return result
    }
}

struct FoodStatusChartModel: Identifiable {
    var id = UUID()
    var remain: Int
    var time: Int
    
    init(remain: String, time: Int) {
        var tmpRemain = remain
        let _  = tmpRemain.popLast()
        self.remain = Int(tmpRemain) ?? 0
        self.time = time
    }
    
    init(remain: Int, time: Int) {
        self.remain = remain
        self.time = time
    }
}
