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
