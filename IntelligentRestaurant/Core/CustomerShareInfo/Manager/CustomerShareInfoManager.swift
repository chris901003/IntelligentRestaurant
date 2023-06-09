//
//  CustomerShareInfoManager.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/5/5.
//

import Foundation

class CustomerShareInfoManager: ObservableObject {
    
    // Singleton
    static let instance: CustomerShareInfoManager = CustomerShareInfoManager()
    private init() { }
    
    @Published var customerAccount = CustomerAccountModel(name: "", email: "", password: "")
    @Published var isLogin: Bool = false
    
    @Published var selectedMerchant: CustomerMerchantInfoModel = .init(customerUid: "", merchantUid: "", name: "")
    @Published var selectedMerchantUid: String = ""
    
    func clearAll() {
        customerAccount = CustomerAccountModel(name: "", email: "", password: "")
    }
}
