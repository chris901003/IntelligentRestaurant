//
//  MerchantHomeView.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/3/10.
//

import Foundation
import SwiftUI

struct MerchantHomeView: View {
    
    @StateObject var vm: MerchantHomeViewModel = MerchantHomeViewModel()
    
    var body: some View {
        ZStack {
            Color.theme.loginBackground
            
            VStack {
                MerchantTopNavigationBarView(title: "主頁", titleImage: "house")
                filterSelect
                if vm.selectedTableIdx >= "1" && vm.selectedFoodIdx >= "1" {
                    foodDetailView
                } else {
                    ZStack {
                        tableInfoList
                        showUsingInfoButton
                    }
                }
                autoRefreshToggle
                Spacer()
            }
            .padding(.top, 72)
        }
        .overlay {
            if vm.isShowUsingMesssage {
                usingInfo
            }
        }
        .overlay {
            if vm.isProgressing {
                LoadingView(waitingInfo: "資料載入中", isTextWithAnimation: true, isProgressView: true)
            }
            if vm.isProgressError {
                ErrorMessageShowView(message: vm.progressErrorMessage)
            }
        }
        .onAppear {
            vm.startRefreshTimer()
        }
        .onDisappear {
            vm.endRefreshTimer()
        }
    }
    
    private var filterSelect: some View {
        HStack {
            tableSelect
            Spacer()
            foodSelect
        }
        .font(.headline)
        .frame(width: 330, height: 45)
        .padding(.top)
    }
    
    private var tableSelect: some View {
        HStack {
            Text("桌號")
            Rectangle()
                .frame(width: 1)
                .foregroundColor(Color(hex: "#715428"))
            Picker(selection: $vm.selectedTableIdx) {
                Text("-").font(.headline).tag("-1")
                Text("全部").font(.headline).tag("0")
                ForEach(vm.tableChoiceList, id: \.self) { tableIdx in
                    Text(tableIdx).font(.headline).tag(tableIdx)
                }
            } label: { }
            .pickerStyle(InlinePickerStyle())
            .frame(width: 75)
        }
        .frame(width: 150)
        .background(
            Rectangle()
                .foregroundColor(Color.white)
        )
    }
    
    private var foodSelect: some View {
        HStack {
            Text("編號")
            Rectangle()
                .frame(width: 1)
                .foregroundColor(Color(hex: "#715428"))
            Picker("編號", selection: $vm.selectedFoodIdx) {
                if vm.selectedTableIdx == "-1" {
                    Text("-").font(.headline).tag("-1")
                } else {
                    Text("全部").font(.headline).tag("0")
                }
                ForEach(vm.tableFoodChoiceList, id: \.self) { foodIdx in
                    Text(foodIdx).font(.headline).tag(foodIdx)
                }
            }
            .pickerStyle(InlinePickerStyle())
            .frame(width: 75)
        }
        .frame(width: 150)
        .background(
            Rectangle()
                .foregroundColor(Color.white)
        )
    }
    
    private var tableInfoList: some View {
        VStack {
            ScrollView {
                ForEach(vm.tableInfoShowIdx, id: \.self) { tableIdx in
                    if let tableFoodsInfo = vm.tablesFoodsInfo[tableIdx] {
                        HStack {
                            HStack {
                                Text(tableIdx)
                                Text("桌")
                            }
                            .font(.title2)
                            .bold()
                            .padding(.horizontal)
                            MerchantTablePreviewView(selectedTableIdx: $vm.selectedTableIdx, selectedFoodIdx: $vm.selectedFoodIdx, tableIdx: tableIdx, tableInfos: tableFoodsInfo)
                            Spacer()
                        }
                        .padding()
                    }
                }
            }
            .refreshable { vm.forceUpdateData() }
            Spacer()
        }
        .background(Color.white)
        .cornerRadius(10)
        .padding()
    }
    
    private var showUsingInfoButton: some View {
        VStack {
            HStack {
                Spacer()
                Image(systemName: "exclamationmark")
                    .font(.headline)
                    .padding(8)
                    .background(
                        Circle()
                            .trim(from: 0, to: 300 / 360)
                            .rotation(Angle(degrees: 120))
                            .stroke(lineWidth: 3)
                    )
                    .onTapGesture { withAnimation { vm.isShowUsingMesssage.toggle() } }
                    .padding(.trailing, 8)
            }
            Spacer()
        }
    }
    
    private var usingInfo: some View {
        ZStack {
            Color.white.opacity(0.01)
                .onTapGesture { withAnimation { vm.isShowUsingMesssage.toggle() } }
            VStack {
                HStack {
                    Text("資訊")
                        .font(.headline)
                        .underline()
                    Text("(點擊圓圈即可獲取詳細資訊)")
                        .font(.subheadline)
                    Image(systemName: "xmark")
                        .font(.title3)
                        .onTapGesture { withAnimation { vm.isShowUsingMesssage.toggle() } }
                }
                .bold()
                HStack {
                    VStack(spacing: 0) {
                        Text("1")
                            .font(.caption)
                        VStack {
                            Text("20")
                                .font(.subheadline)
                            Text("50%")
                                .font(.caption)
                        }
                        .foregroundColor(Color.white)
                        .frame(width: 45, height: 45)
                        .background(Circle().foregroundColor(Color(hex: "#5B3E3E")))
                    }
                    .bold()
                    .frame(width: 45)
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "arrow.right")
                            Text("食物編號")
                        }
                        HStack {
                            Image(systemName: "arrow.right")
                            Text("預估食物完食剩餘分鐘")
                        }
                        HStack {
                            Image(systemName: "arrow.right")
                            Text("預估食物完食剩餘量")
                        }
                    }
                    .bold()
                }
                .padding(.top, 8)
            }
            .padding(8)
            .background(
                Color(hex: "#F2C8C8")
            )
            .background(
                Rectangle()
                    .stroke(Color.black, lineWidth: 3)
                    .shadow(radius: 3)
            )
        }
    }
    
    private var autoRefreshToggle: some View {
        Toggle(isOn: $vm.isAutoRefresh) {
            Text("啟用30秒自動更新")
                .font(.headline)
        }
        .frame(width: 300)
        .padding(.horizontal)
    }
    
    private var foodDetailView: some View {
        VStack {
            if let foodInfo = vm.tablesFoodsInfo[vm.selectedTableIdx]?[vm.selectedFoodIdx] {
                MerchantFoodDetailView(foodInfo: foodInfo)
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding()
            } else {
                Text("資料讀取錯誤，請重選")
                    .font(.title3)
                    .bold()
            }
        }
    }
}
