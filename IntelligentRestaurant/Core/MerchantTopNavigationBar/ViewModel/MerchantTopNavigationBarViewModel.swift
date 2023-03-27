//
//  MerchantTopNavigationBarViewModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/3/11.
//

import Foundation

class MerchantTopNavigationBarViewModel: ObservableObject {
    
    // Published Variable
    @Published var isShowSelectList: Bool = false
    @Published var isShowLogout: Bool = false
    
    // Public Function
    func logout() {
        MerchantShareInfoManager.instance.isLogin = false
    }
}
