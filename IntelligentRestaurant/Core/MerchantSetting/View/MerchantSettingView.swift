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
    @State var isShowSelectTrainStep: Bool = false
    
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
                
                if isShowSelectTrainStep {
                    ZStack {
                        Color.black.opacity(0.5).onTapGesture { withAnimation { isShowSelectTrainStep.toggle() } }
                        
                        VStack {
                            HStack {
                                Image(systemName: "xmark")
                                    .foregroundColor(Color.pink)
                                    .onTapGesture { withAnimation { isShowSelectTrainStep.toggle() } }
                                Spacer()
                            }
                            Text("選擇資料類型")
                                .font(.title3)
                                .bold()
                            NavigationLink(value: 6) {
                                Text("第一階段資料")
                                    .withMerchantSettingCardModifier()
                                    .foregroundColor(Color.black)
                            }
                            NavigationLink(value: 7) {
                                Text("第二階段資料")
                                    .withMerchantSettingCardModifier()
                                    .foregroundColor(Color.black)
                            }
                        }
                        .font(.headline)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                }
                
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
                    .onTapGesture { withAnimation { isShowSelectTrainStep.toggle() } }
            }
            .navigationDestination(for: Int.self) { info in
                if info == 1 { SettingModelWeightView().edgesIgnoringSafeArea(.top) }
                else if info == 2 { MerchantRoomSpaceView().edgesIgnoringSafeArea(.top) }
                else if info == 3 { CustomerViewInfoView().edgesIgnoringSafeArea(.top) }
                else if info == 4 { CameraUidSettingView().edgesIgnoringSafeArea(.top) }
                else if info == 6 { ModelObjectDetectionTrainDataView().edgesIgnoringSafeArea(.top) }
                else if info == 7 { ModelSegmentationTrainView().edgesIgnoringSafeArea(.top) }
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

