//
//  ReviewObjectDetectionDataModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/4/25.
//

import Foundation
import SwiftUI

/// 接收已上傳目標檢測訓練資料格式
struct ReviewObjectDetectionDataModel: Identifiable, Decodable {
    let id: String = UUID().uuidString
    let image: UIImage?
    let anno: (String, [Double])
    let target: String
    var isShow: Bool = true
}

extension ReviewObjectDetectionDataModel {
    /// 獲取標注匡在圖像上的座標位置
    static func getAnnoPosition(image: UIImage, anno: String) -> (String, [Double])? {
        let foodDict: [String: String] = ["0": "Donburi", "1": "SoupRice", "2": "Rice", "3": "Countable", "4": "SoupNoodle", "5": "Noodle", "6": "SideDish", "7": "SolidSoup", "8": "Soup"]
        let annoInfo = anno.components(separatedBy: " ")
        let category = foodDict[annoInfo[0]] ?? "Not Found"
        let centerX = Double(annoInfo[1])!
        let centerY = Double(annoInfo[2])!
        let boxWidth = Double(annoInfo[3])!
        let boxHeight = Double(annoInfo[4])!
        let box: [Double] = [centerX - boxWidth / 2, centerY - boxHeight / 2, boxWidth, boxHeight]
        return (category, box)
    }
}

extension ReviewObjectDetectionDataModel {
    enum CodingKeys: CodingKey {
        case image
        case anno
        case target
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let image = try? container.decode(String.self, forKey: .image),
           let imageData = Data(base64Encoded: image),
           let photo = UIImage(data: imageData) {
            self.image = photo
        } else {
            self.image = nil
        }
        if let anno = try? container.decode(String.self, forKey: .anno),
           let image = self.image,
           let annoInfo = ReviewObjectDetectionDataModel.getAnnoPosition(image: image, anno: anno) {
            self.anno = annoInfo
        } else {
            self.anno = ("None", [])
        }
        if let target = try? container.decode(String.self, forKey: .target) {
            self.target = target
        } else {
            self.target = ""
        }
    }
}

/// 刪除目標檢測訓練需要的格式
struct DeleteObjectDetectionTrainInfoModel: Encodable {
    let merchantUid: String
    let target: String
}

/// 發送請求已上傳目標檢測訓練資料格式
struct FetchObjectDetectionTrainInfoModel: Codable {
    let merchantUid: String
    let page: Int
    let gap: Int
}
