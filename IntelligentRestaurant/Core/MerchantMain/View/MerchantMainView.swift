//
//  MerchantMainView.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/3/10.
//

import Foundation
import SwiftUI

struct MerchantMainView: View {
    
    @StateObject var vm: MerchantMainViewModel = MerchantMainViewModel()
    
    var body: some View {
        TabView(selection: $vm.tabViewSelection) {
            MerchantHomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("主頁")
                }
                .tag(1)
                .edgesIgnoringSafeArea(.top)
            MerchantSettingView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("設定")
                }
                .tag(2)
            MerchantAccountView()
                .tabItem {
                    Image(systemName: "person")
                    Text("帳號")
                }
                .tag(3)
        }
    }
}
