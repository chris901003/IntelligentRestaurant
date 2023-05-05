//
//  CustomerInfoModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/5/5.
//

import Foundation

struct CustomerInfoModel: Identifiable, Codable {
    let uid: String
    let name: String
    let email: String
    let password: String
    let phoneNumber: String
    let photo: String
    var id: String { uid }
}

extension CustomerInfoModel {
    init(name: String, email: String, password: String) {
        self.name = name
        self.email = email
        self.password = password
        self.uid = UUID().uuidString
        self.phoneNumber = ""
        self.photo = ""
    }
}
