//
//  CustomerMerchantInfoModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/5/5.
//

import Foundation

struct CustomerMerchantInfoModel: Identifiable, Codable {
    var customerUid: String
    var merchantUid: String
    var uid: String
    var name: String
    var phoneNumber: String
    var location: String
    var intro: String
    var photo: Data
    var favorite: Bool
    var id: String { uid }
}

extension CustomerMerchantInfoModel {
    init(customerUid: String, merchantUid: String, name: String) {
        self.customerUid = customerUid
        self.merchantUid = merchantUid
        self.name = name
        self.uid = ""
        self.phoneNumber = ""
        self.location = ""
        self.photo = Data()
        self.intro = ""
        self.favorite = false
    }
}

extension CustomerMerchantInfoModel {
    
    enum CodingKeys: CodingKey {
        case customerUid, merchantUid, uid, name, phoneNumber, location, intro, photo, favorite
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let merchantUid = try? container.decode(String.self, forKey: .merchantUid) {
            self.merchantUid = merchantUid
        } else {
            self.merchantUid = ""
            // TODO: 不知道為什麼會需要商家的Uid放在ShareInfo當中
//            self.merchantUid = ShareInfoManager.shared.merchant.uid
        }
        if let customerUid = try? container.decode(String.self, forKey: .customerUid) {
            self.customerUid = customerUid
        } else {
            self.customerUid = CustomerShareInfoManager.instance.customerAccount.uid
        }
        if let uid = try? container.decode(String.self, forKey: .uid) {
            self.uid = uid
        } else {
            self.uid = UUID().uuidString
        }
        if let name = try? container.decode(String.self, forKey: .name) {
            self.name = name
        } else {
            self.name = ""
        }
        if let phoneNumber = try? container.decode(String.self, forKey: .phoneNumber) {
            self.phoneNumber = phoneNumber
        } else {
            self.phoneNumber = ""
        }
        if let location = try? container.decode(String.self, forKey: .location) {
            self.location = location
        } else {
            self.location = ""
        }
        if let intro = try? container.decode(String.self, forKey: .intro) {
            self.intro = intro
        } else {
            self.intro = ""
        }
        if let photo = try? container.decode(String.self, forKey: .photo) {
            self.photo =  Data(base64Encoded: photo)!
        } else {
            self.photo = Data()
        }
        if let favorite = try? container.decode(Bool.self, forKey: .favorite) {
            self.favorite = favorite
        } else {
            self.favorite = false
        }
    }
}
