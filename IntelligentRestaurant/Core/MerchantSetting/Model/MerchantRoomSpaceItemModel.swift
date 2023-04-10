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
    
    enum Item: Codable {
        case door
        case table
        case verticalWall
        case horizontalWall
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
        name = try container.decode(String.self, forKey: .name)
        capacity = try container.decode(Int.self, forKey: .capacity)
        let tmpOffset = try container.decode([Double].self, forKey: .offset)
        offset = .init(width: tmpOffset[0], height: tmpOffset[1])
        merchantUid = try container.decode(String.self, forKey: .merchantUid)
        item = try container.decode(Item.self, forKey: .item)
    }
}
