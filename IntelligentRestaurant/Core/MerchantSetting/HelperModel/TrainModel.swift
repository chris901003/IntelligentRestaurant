//
//  ObjectDetectionTrainModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/4/29.
//

import Foundation

/// 接收發出訓練的結果
struct TrainQueryResultModel: Decodable {
    let status: String
    let trainType: TrainType
    let startTime: String
}

extension TrainQueryResultModel {
    enum CodingKeys: CodingKey {
        case status, trainType, startTime
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let status = try? container.decode(String.self, forKey: .status) {
            self.status = status
        } else {
            self.status = ""
        }
        if let trainTypeName = try? container.decode(String.self, forKey: .trainType) {
            self.trainType = .init(rawValue: trainTypeName)!
        } else {
            self.trainType = .unknow
        }
        if let startTime = try? container.decode(String.self, forKey: .startTime) {
            self.startTime = startTime
        } else {
            self.startTime = Date().description
        }
    }
}

extension TrainQueryResultModel {
    enum TrainType: String {
        case objectDetection = "第一階段"
        case segmentation = "第二階段"
        case unknow = "未知"
    }
}
