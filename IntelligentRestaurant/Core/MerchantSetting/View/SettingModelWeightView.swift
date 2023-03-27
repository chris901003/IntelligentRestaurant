//
//  SettingModelWeightView.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/3/13.
//

import Foundation
import SwiftUI

struct SettingModelWeightView: View {
    
    @StateObject var vm: SettingModelWeightViewModel = SettingModelWeightViewModel()
    @State var isShowChangeModelWeightAlert: Bool = false
    
    let titleInfoWidth: CGFloat = 100
    let contentInfoWidth: CGFloat = 180
    let infoHeight: CGFloat = 50
    
    var body: some View {
        ZStack {
            Color.theme.loginBackground
            
            VStack {
                MerchantTopNavigationBarView(title: "權重設定", titleImage: "gear")
                    .padding(.bottom, 36)
                selectFoodType
                    .padding(.bottom, 32)
                modelWeightSection
                changeCheck
                
                Spacer()
            }
            .padding(.top, 72)
        }
        .navigationBarBackButtonHidden(true)
        .overlay {
            if vm.isProcessing { LoadingView(waitingInfo: "等待中", isProgressView: true) }
            if vm.isPorcessError { ErrorMessageShowView(message: vm.processErrorMessage) }
        }
        .alert("更新權重警告", isPresented: $isShowChangeModelWeightAlert) {
            Button(role: .cancel) {
                isShowChangeModelWeightAlert.toggle()
            } label: {
                Text("取消")
            }
            Button(role: .destructive) {
                isShowChangeModelWeightAlert.toggle()
                Task { await vm.changeModelWeight() }
            } label: {
                Text("確定")
            }
        } message: {
            Text("確定後將會更新權重，會花上一段時間")
        }
    }
    
    private var selectFoodType: some View {
        HStack {
            Text("食物類別")
                .frame(width: titleInfoWidth)
            Rectangle()
                .foregroundColor(Color.black.opacity(0.2))
                .frame(width: 1)
            Picker(selection: $vm.foodCategorySelect) {
                Text("-").tag("-")
                ForEach(vm.foodCategorys, id: \.self) { foodCategory in
                    Text(foodCategory)
                }
            } label: {
                Text("選擇食物類別")
            }
            .pickerStyle(InlinePickerStyle())
            .frame(width: contentInfoWidth)
        }
        .font(.headline)
        .frame(height: infoHeight)
        .background(Color(hex: "#F2F1E1").cornerRadius(5))
        .background(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.black, lineWidth: 2)
        )
        .padding()
    }
    
    private var modelWeightSection: some View {
        VStack {
            Text("權重選擇")
                .font(.headline)
            VStack {
                HStack {
                    Text("名稱")
                        .frame(width: 100)
                    Text("推薦度")
                        .frame(width: 80)
                    Text("紀錄")
                        .frame(width: 100)
                    Text("使用")
                        .frame(width: 50)
                }
                Rectangle()
                    .frame(height: 2)
                ScrollView {
                    ForEach(vm.modelWeightsInfo) { weightInfo in
                        HStack {
                            Text(weightInfo.name)
                                .frame(width: 100)
                            Text(weightInfo.reliability)
                                .frame(width: 80)
                            Text(weightInfo.someNote)
                                .frame(width: 100)
                            VStack {
                                if weightInfo == vm.selectedModelWeight {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Color.green)
                                }
                            }
                            .frame(width: 50)
                        }
                        .onTapGesture { vm.selectedModelWeight = weightInfo }
                        .padding(.bottom)
                    }
                }
                Spacer()
            }
            .font(.headline)
            .padding(8)
            .frame(height: 300)
            .background(Color.white.cornerRadius(10))
            .padding()
        }
    }
    
    private var changeCheck: some View {
        VStack {
            HStack {
                Button {
                    MerchantShareInfoManager.instance.settingModeSelect = []
                } label: {
                    Text("返回")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#715428").opacity(0.7))
                        .padding(8)
                        .padding(.horizontal)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color(hex: "#715428").opacity(0.7), lineWidth: 3)
                        )
                }
                
                if vm.foodCategorySelect != "-" {
                    Button {
                        isShowChangeModelWeightAlert.toggle()
                    } label: {
                        Text("確認更改")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#715428").opacity(0.7))
                            .padding(8)
                            .padding(.horizontal)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color(hex: "#715428").opacity(0.7), lineWidth: 3)
                            )
                            .opacity(vm.selectedModelWeight.isSelected ? 0.3 : 1)
                    }
                    .disabled(vm.selectedModelWeight.isSelected)
                    .padding(.horizontal)
                }
            }
        }
    }
}
