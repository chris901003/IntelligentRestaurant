//
//  TrainDataModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/4/22.
//

import Foundation

struct ObjectDetectionTrainDataModel: Identifiable, Codable {
    let uid: String
    let image: Data
    let labelInfo: String
    var id: String { uid }
}
