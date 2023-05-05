//
//  CustomerInfoModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/5/5.
//

import Foundation

struct CustomerAccountModel: Identifiable, Codable {
    let uid: String
    var name: String
    var email: String
    var password: String
    var phoneNumber: String
    var photo: String
    var id: String { uid }
}

extension CustomerAccountModel {
    init(name: String, email: String, password: String) {
        self.name = name
        self.email = email
        self.password = password
        self.uid = UUID().uuidString
        self.phoneNumber = ""
        self.photo = ""
    }
}
