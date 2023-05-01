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

/// 目標檢測資料
struct ObjectDetectionModelWeightModel: Decodable, Identifiable {
    var id: String = UUID().uuidString
    var name: String
    var recommend: String
    var isChoose: Bool
    
    init() {
        self.name = ""
        self.recommend = ""
        self.isChoose = false
    }
}

extension ObjectDetectionModelWeightModel {
    enum CodingKeys: String, CodingKey {
        case name, recommend
        case isChoose = "choose"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let name = try? container.decode(String.self, forKey: .name) {
            self.name = name
        } else {
            self.name = "無法獲取名稱"
        }
        if let recommend = try? container.decode(String.self, forKey: .recommend) {
            self.recommend = recommend
        } else {
            self.recommend = "暫無"
        }
        if let choose = try? container.decode(Int.self, forKey: .isChoose) {
            switch choose {
            case 1:
                self.isChoose = true
            default:
                self.isChoose = false
            }
        } else {
            self.isChoose = false
        }
    }
}

/// 更新目標檢測權重所需資料
struct ObjectDetectionWeightModelRenameModel: Encodable {
    let merchantUid: String
    let oldName: String
    let newName: String
    let recommend: String
}

/// 更換使用權重
struct ObjectDetectionWeightModelUse: Encodable {
    let merchantUid: String
    let fileName: String
    let recommend: String
    let reset: Int
}
