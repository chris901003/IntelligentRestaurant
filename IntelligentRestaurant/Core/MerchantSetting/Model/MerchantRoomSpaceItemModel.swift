//
//  MerchantRoomSpaceItemModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/3/15.
//

import Foundation
import SwiftUI

struct MerchantRoomSpaceItemModel: Identifiable, Codable, Equatable {
    
    var uid: String
    var item: Item
    var name: String
    var capacity: Int
    var offset: CGSize
    var merchantUid: String
    var id: String { uid }
}

extension MerchantRoomSpaceItemModel {
    
    enum Item: String, Codable {
        case door = "door"
        case table = "table"
        case verticalWall = "verticalWall"
        case horizontalWall = "horizontalWall"
    }
}

extension MerchantRoomSpaceItemModel {
    
    enum CodingKeys: CodingKey {
        case uid, name, capacity, offset, merchantUid, item
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uid, forKey: .uid)
        try container.encode(name, forKey: .name)
        try container.encode(capacity, forKey: .capacity)
        try container.encode(offset, forKey: .offset)
        try container.encode(merchantUid, forKey: .merchantUid)
        try container.encode(item, forKey: .item)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uid = try container.decode(String.self, forKey: .uid)
        if let name = try? container.decode(String.self, forKey: .name) {
            self.name = name
        } else {
            self.name = ""
        }
        if let capacityStr = try? container.decode(String.self, forKey: .capacity) {
            self.capacity = Int(capacityStr)!
        } else {
            self.capacity = 0
        }
        let tmpOffset = try container.decode([String].self, forKey: .offset)
        let offsetWidth = Double(tmpOffset[0]) ?? 0
        let offsetHeight = Double(tmpOffset[1]) ?? 0
        self.offset = .init(width: offsetWidth, height: offsetHeight)
        merchantUid = try container.decode(String.self, forKey: .merchantUid)
        item = try container.decode(Item.self, forKey: .item)
    }
}
