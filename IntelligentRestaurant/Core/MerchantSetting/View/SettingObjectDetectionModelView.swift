//
//  SettingObjectDetectionModelView.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/4/29.
//

import SwiftUI

struct SettingObjectDetectionModelView: View {
    
    @StateObject var vm: SettingObjectDetectionModelViewModel = SettingObjectDetectionModelViewModel()
    @State var isShowEditName: Bool = false
    
    private let frameWidth: CGFloat = 3 * UIScreen.main.bounds.width / 4
    private let nameWidth: CGFloat = 3 * UIScreen.main.bounds.width / 4 / 2
    private let mapWidth: CGFloat = 3 * UIScreen.main.bounds.width / 4 / 4 - 10
    private let useWidth: CGFloat = 3 * UIScreen.main.bounds.width / 4 / 4 - 20
    
    var body: some View {
        ZStack {
            Color.theme.loginBackground
            
            VStack {
                MerchantTopNavigationBarView(title: "設定第一階段權重", titleImage: "desktopcomputer")
                topBarButton
                titleSection
                modelWeightSelectionSection
                
                Spacer()
            }
            .padding(.top, 72)
            
            if isShowEditName {
                changeModelWeightName
            }
            
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
    
    private var titleSection: some View {
        Text("設定第一段權重")
            .font(.title3)
            .bold()
            .padding(.bottom, 32)
    }
    
    private var modelWeightSelectionSection: some View {
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
                        HStack {
                            Image("pencil")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .onTapGesture {
                                    vm.selectedWeightInfo = modelWeightInfo
                                    withAnimation { isShowEditName.toggle() }
                                }
                            Text(modelWeightInfo.name)
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                        }
                        .frame(width: nameWidth, alignment: .leading)
                        Text(modelWeightInfo.recommend)
                            .frame(width: mapWidth)
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                        if modelWeightInfo.isChoose {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color.green)
                        } else {
                            Image(systemName: "square")
                                .foregroundColor(Color.black)
                                .onTapGesture {
                                    Task {
                                        vm.selectedWeightInfo = modelWeightInfo
                                        await vm.changeModelUse()
                                    }
                                }
                        }
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
    }
    
    private var changeModelWeightName: some View {
        ZStack {
            Color.white.opacity(0.01)
                .onTapGesture { withAnimation { isShowEditName.toggle() } }
            VStack {
                Text("修改權重名稱")
                    .font(.title3)
                    .bold()
                    .padding(.bottom)
                Text("新名稱")
                TextField("新名稱", text: $vm.selectedWeightInfo.name)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .cornerRadius(5)
                Spacer()
                HStack(spacing: 16) {
                    Button {
                        withAnimation { isShowEditName.toggle() }
                        vm.selectedWeightInfo = .init()
                    } label: {
                        Text("取消")
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.blue, lineWidth: 3)
                            )
                    }
                    Button {
                        Task {
                            if await vm.changeModelWeight() {
                                withAnimation { isShowEditName.toggle() }
                                vm.selectedWeightInfo = .init()
                            }
                        }
                    } label: {
                        Text("確認")
                            .foregroundColor(Color.pink)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.pink, lineWidth: 3)
                            )
                    }
                }
                .font(.headline)
            }
            .padding()
            .frame(width: frameWidth, height: 200)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color(hex: "#AC988B").gradient.shadow(.drop(radius: 5)))
            )
        }
    }
}
