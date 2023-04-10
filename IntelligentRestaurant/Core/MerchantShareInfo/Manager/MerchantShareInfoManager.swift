//
//  ShareInfoManager.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/3/8.
//

import Foundation

/// 共享資料，所有需要跨畫面資料存放地
class MerchantShareInfoManager: ObservableObject {
    
    // Static Instance
    static var instance: MerchantShareInfoManager = MerchantShareInfoManager()
    
    // Published Variable
    @Published var isLogin: Bool = false
    @Published var userMode: UserMode = .merchant
    @Published var tabViewSelect = 2
    @Published var settingModeSelect: [Int] = []
    
    @Published var merchantAccount: MerchantAccountModel = MerchantAccountModel()
    
    // Init Function
    private init() { }
}

extension MerchantShareInfoManager {
    
    enum UserMode {
        case customer
        case merchant
    }
}
