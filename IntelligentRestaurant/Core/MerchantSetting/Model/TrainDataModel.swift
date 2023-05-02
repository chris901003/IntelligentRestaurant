//
//  TrainDataModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/4/22.
//

import Foundation
import SwiftUI

struct ObjectDetectionTrainDataModel: Identifiable, Codable {
    let uid: String
    let image: Data
    let labelInfo: String
    var id: String { uid }
}

/// 上傳分割訓練資料使用
struct SegmentationTrainDataModel: Identifiable, Encodable {
    let merchantUid: String
    let foodType: FoodType
    let image: UIImage
    let imageHeight: String
    let imageWidth: String
    let food: [[String]]
    let notFood: [[String]]
    var id: String { merchantUid }
}

extension SegmentationTrainDataModel {
    enum FoodType: String {
        case donburi = "Donburi"
        case soupRice = "SoupRice"
        case rice = "Rice"
        case countable = "Countable"
        case soupNoodle = "SoupNoodle"
        case noodle = "Noodle"
        case sideDish = "SideDish"
        case solidSoup = "SolidSoup"
        case soup = "Soup"
    }
}

extension SegmentationTrainDataModel {
    enum CodingKeys: String, CodingKey {
        case merchantUid, foodType, imageHeight, imageWidth, food, notFood
        case image
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.merchantUid, forKey: .merchantUid)
        try container.encode(self.foodType.rawValue, forKey: .foodType)
        let imageData = image.jpegData(compressionQuality: 0.5)
        try container.encode(imageData, forKey: .image)
        try container.encode(self.imageHeight, forKey: .imageHeight)
        try container.encode(self.imageWidth, forKey: .imageWidth)
        try container.encode(self.food, forKey: .food)
        try container.encode(self.notFood, forKey: .notFood)
    }
}
