//
//  MerchantSettingView.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/3/12.
//

import Foundation
import SwiftUI

struct MerchantSettingView: View {
    
    @StateObject var vm: MerchantSettingViewModel = MerchantSettingViewModel()
    
    var body: some View {
        NavigationStack(path: $vm.navigationPath) {
            ZStack {
                Color.theme.loginBackground
                
                VStack {
                    MerchantTopNavigationBarView(title: "設定", titleImage: "gear")
                        .padding(.bottom, 48)
                    
                    selectCard
                    
                    Spacer()
                }
                .padding(.top, 72)
            }
            .edgesIgnoringSafeArea(.top)
        }
    }
    
    private var selectCard: some View {
        VStack(spacing: 24) {
            NavigationLink(value: 1) {
                Text("權重")
                    .foregroundColor(Color.black)
                    .withMerchantSettingCardModifier()
            }
            NavigationLink(value: 2) {
                Text("空間")
                    .foregroundColor(Color.black)
                    .withMerchantSettingCardModifier()
            }
            NavigationLink(value: 3) {
                Text("使用者")
                    .foregroundColor(Color.black)
                    .withMerchantSettingCardModifier()
            }
            NavigationLink(value: 4) {
                Text("攝影機UID設定")
                    .foregroundColor(Color.black)
                    .withMerchantSettingCardModifier()
            }
            NavigationLink(value: 5) {
                Text("模型再訓練")
                    .foregroundColor(Color.black)
                    .withMerchantSettingCardModifier()
            }
            .navigationDestination(for: Int.self) { info in
                if info == 1 { SettingModelWeightView().edgesIgnoringSafeArea(.top) }
                else if info == 2 { MerchantRoomSpaceView().edgesIgnoringSafeArea(.top) }
                else if info == 3 { CustomerViewInfoView().edgesIgnoringSafeArea(.top) }
                else if info == 4 { CameraUidSettingView().edgesIgnoringSafeArea(.top) }
                else if info == 5 { ModelTrainDataView().edgesIgnoringSafeArea(.top) }
            }
        }
    }
}

struct MerchantSettingCardModifier: ViewModifier {
    let innerWidth: CGFloat
    
    func body(content: Content) -> some View {
        content
            .font(.title2)
            .bold()
            .padding(8)
            .frame(width: innerWidth)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color(hex: "#C4B7A9"), lineWidth: 4)
            )
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 10).foregroundColor(Color.white))
    }
}

extension View {
    
    func withMerchantSettingCardModifier(innerWidth: CGFloat = 250) -> some View {
        modifier(MerchantSettingCardModifier(innerWidth: innerWidth))
    }
}

