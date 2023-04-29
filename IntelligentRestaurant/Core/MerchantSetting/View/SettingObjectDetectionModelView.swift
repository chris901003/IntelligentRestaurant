//
//  SettingObjectDetectionModelView.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/4/29.
//

import SwiftUI

struct SettingObjectDetectionModelView: View {
    
    @StateObject var vm: SettingObjectDetectionModelViewModel = SettingObjectDetectionModelViewModel()
    
    var body: some View {
        ZStack {
            Color.theme.loginBackground
            
            VStack {
                MerchantTopNavigationBarView(title: "設定第一階段權重", titleImage: "desktopcomputer")
                topBarButton
                Spacer()
            }
            .padding(.top, 72)
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private var topBarButton: some View {
        HStack {
            Text("返回")
                .withTopBarButtonModifier(color: Color(hex: "#9B7E6E"))
                .onTapGesture {
                    MerchantShareInfoManager.instance.settingModeSelect = []
                }
            Spacer()
        }
        .font(.headline)
        .padding(8)
        .padding(.horizontal, 8)
    }
}
