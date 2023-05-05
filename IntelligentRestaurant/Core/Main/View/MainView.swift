//
//  MainView.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/3/8.
//

import Foundation
import SwiftUI

struct MainView: View {
    
    @StateObject var vm: MainViewModel = MainViewModel()
    
    var body: some View {
        ZStack {
            if vm.isLogin {
                // 已登陸畫面
                if vm.userMode == .customer {
                    CustomerMainView()
                } else if vm.userMode == .merchant {
                    MerchantMainView()
                }
            } else {
                // 未登錄畫面
                Color.theme.loginBackground
                LoginView()
            }
            
        }
        .ignoresSafeArea(.all)
    }
}
