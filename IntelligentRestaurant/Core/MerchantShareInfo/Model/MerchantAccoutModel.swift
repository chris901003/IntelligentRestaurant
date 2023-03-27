//
//  MerchantAccoutModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/3/11.
//

import Foundation
import SwiftUI
import CoreLocation

struct MerchantAccountModel: Identifiable, Codable {
    var uid: String = ""
    var name: String = ""
    var phoneNumber: String = ""
    var email: String = ""
    var photo: Data = Data()
    var password: String = ""
    var location: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var intro: String = ""
    // ["Table Uid (Uid in database)"]
    // Table Uid -> TableInfoModel
    // 在TableInfoModel中會記錄下多個FoodStatusInfoModel的Uid
    var tableInfoUid: [String] = []
    // 保存一種食物的模型權重的uid
    var modelWeightsUid: [String] = []
    // 保存店面擺設物的資訊，每個uid表示一個物品，整個整合在一起就是一個店面
    var roomSpaceItemUid: [String] = []
    // 保存商家允許客戶看到的資料
    var customerViewInfoModelUid: String = ""
    var role: String = "merchant"
    var id: String { uid }
    
    init() { }
    
    init(uid: String = "", name: String, phoneNumber: String, email: String, photo: Data, password: String, location: CLLocationCoordinate2D, intro: String) {
        self.uid = uid
        self.name = name
        self.phoneNumber = phoneNumber
        self.email = email
        self.photo = Data()
        self.password = password
        self.location = location
        self.tableInfoUid = []
        self.intro = intro
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.uid = try container.decode(String.self, forKey: .uid)
        self.name = try container.decode(String.self, forKey: .name)
        if let phoneNumber = try? container.decode(String.self, forKey: .phoneNumber) {
            self.phoneNumber = phoneNumber
        } else {
            self.phoneNumber = ""
        }
        self.email = try container.decode(String.self, forKey: .email)
        if let photo = try? container.decode(String.self, forKey: .photo) {
            self.photo = Data(base64Encoded: photo)!
        } else{
            self.photo = Data()
        }
        self.password = try container.decode(String.self, forKey: .password)
        let locationInfo = try container.decode([String].self, forKey: .location)
        self.location = CLLocationCoordinate2D(latitude: CLLocationDegrees(locationInfo[0])!,
                                               longitude: CLLocationDegrees(locationInfo[1])!)
        if let intro = try? container.decode(String.self, forKey: .intro) {
            self.intro = intro
        } else {
            self.intro = ""
        }
        if let tableInfoUid = try? container.decode([String].self, forKey: .tableInfoUid) {
            self.tableInfoUid = tableInfoUid
        } else {
            self.tableInfoUid = []
        }
        if let modelWeightsUid = try? container.decode([String].self, forKey: .modelWeightsUid) {
            self.modelWeightsUid = modelWeightsUid
        } else {
            self.modelWeightsUid = []
        }
        if let roomSpaceItemUid = try? container.decode([String].self, forKey: .roomSpaceItemUid) {
            self.roomSpaceItemUid = roomSpaceItemUid
        } else {
            self.roomSpaceItemUid = []
        }
        if let customerViewInfoModelUid = try? container.decode(String.self, forKey: .customerViewInfoModelUid) {
            self.customerViewInfoModelUid = customerViewInfoModelUid
        } else {
            self.customerViewInfoModelUid = ""
        }
        self.role = try container.decode(String.self, forKey: .role)
    }
}
