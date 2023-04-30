//
//  SettingObjectDetectionModelView.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/4/29.
//

import SwiftUI

struct SettingObjectDetectionModelView: View {
    
    @StateObject var vm: SettingObjectDetectionModelViewModel = SettingObjectDetectionModelViewModel()
    
    private let frameWidth: CGFloat = 3 * UIScreen.main.bounds.width / 4
    private let nameWidth: CGFloat = 3 * UIScreen.main.bounds.width / 4 / 2 - 10
    private let mapWidth: CGFloat = 3 * UIScreen.main.bounds.width / 4 / 4 - 10
    private let useWidth: CGFloat = 3 * UIScreen.main.bounds.width / 4 / 4 - 10
    
    var body: some View {
        ZStack {
            Color.theme.loginBackground
            
            VStack {
                MerchantTopNavigationBarView(title: "設定第一階段權重", titleImage: "desktopcomputer")
                topBarButton
                
                Text("設定第一段權重")
                    .font(.title3)
                    .bold()
                    .padding(.bottom, 32)
                
                VStack {
                    HStack {
                        Text("名稱")
                            .frame(width: nameWidth, alignment: .leading)
                        Text("推薦度")
                            .frame(width: mapWidth, alignment: .leading)
                        Text("使用")
                            .frame(width: useWidth, alignment: .leading)
                    }
                    .font(.headline)
                    Rectangle()
                        .frame(width: frameWidth, height: 2)
                    List {
                        ForEach(vm.modelWeightInfo) { modelWeightInfo in
                            HStack {
                                Text(modelWeightInfo.name)
                                    .frame(width: nameWidth, alignment: .leading)
                                    .minimumScaleFactor(0.5)
                                    .lineLimit(1)
                                Text(modelWeightInfo.recommend)
                                    .frame(width: mapWidth)
                                    .minimumScaleFactor(0.5)
                                    .lineLimit(1)
                                Text(modelWeightInfo.isChoose.description)
                                    .frame(width: useWidth, alignment: .leading)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
                .frame(width: frameWidth, height: 250)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(Color.white.shadow(.drop(radius: 5)))
                )
                
                Spacer()
            }
            .padding(.top, 72)
            
            if vm.isProcess {
                LoadingView(waitingInfo: vm.loadingMessage, isProgressView: true)
            }
            if vm.isProcessError {
                ErrorMessageShowView(message: vm.processErrorMessage)
            }
            
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
