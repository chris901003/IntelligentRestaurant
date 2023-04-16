//
//  AllTableWithFoodInfoModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/4/16.
//

import Foundation

struct AllTableWithFoodInfoModel: Codable {
    let results: [String: [FoodStatusInfoModel]]
}
