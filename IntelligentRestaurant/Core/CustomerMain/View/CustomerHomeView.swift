//
//  CustomerHomeView.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/5/7.
//

import SwiftUI

struct Object {
    let id = UUID()
    var name : String
    var selected : Bool
}

struct CustomerHomeView: View {
    
    @StateObject var vm: CustomerHomeViewModel = CustomerHomeViewModel()
    
    @State var tableInformButton: Bool = false
    @State var emptyTableInformButton: Bool = false
    @State var emptyString : String = ""
    
//    @State var currentWaitingArray = [
//        Object(name: "不顯示", selected: true),
//        Object(name: "最短剩餘時間", selected: false),
//        Object(name: "所有桌子資訊", selected: false)
//    ]
    
//    @State var nowSelectedCheck: Int = 0
    @State var emptyTableCount: Int = 0
    
    var body: some View {
        ZStack {
            // 背景
            backgroundSection
            
            if vm.selectedMerchantUid == "" {
                notSelectMerchantSection
            } else {
                VStack {
                    // 餐廳名稱
                    companyNameSection
                    ScrollView {
                        // 主要畫面
                        bodySection
                    }
                }
                .padding(32)
                .onAppear {
                    // 初始化
//                    currentWaitingArray = [
//                        Object(name: "不顯示", selected: true),
//                        Object(name: "最短剩餘時間", selected: false),
//                        Object(name: "所有桌子資訊", selected: false)
//                    ]
//                    nowSelectedCheck = 0
                    emptyTableCount = 0
                    // 將"最短剩餘時間"的下拉bar，加入桌子的數量
                    arrayAppend(startID: 0)
                }
            }
            
            if vm.isProcess {
                LoadingView(waitingInfo: vm.loadingMessage, isProgressView: true)
            }
            if vm.isProcessError {
                ErrorMessageShowView(message: vm.errorMessage)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private var backgroundSection: some View {
        ZStack {
            Color.theme.loginBackground
                .edgesIgnoringSafeArea(.all)
            RoundedRectangle(cornerRadius: 8)
                .foregroundColor(.white)
                .padding(15)
            RoundedRectangle(cornerRadius: 8)
                .foregroundColor(Color(hex: "C3B7A9"))
                .padding(25)
            RoundedRectangle(cornerRadius: 8)
                .foregroundColor(Color(hex: "F2F1E1"))
                .padding(28)
        }
    }
    
    private var notSelectMerchantSection: some View {
        VStack {
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
            Text("請在\"店家查詢\"頁面選擇一個店家")
                .font(.title3)
            Spacer()
        }
        .padding(.top)
    }
    
    private var companyNameSection: some View {
        Text(vm.tableInfo.merchantName)
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(.black)
            .padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .frame(height: 25)
                    .foregroundColor(Color(hex: "#B08B2C").opacity(0.4))
                    .offset(y: 10)
            )
    }
    
    private var bodySection: some View {
        VStack{
            // 剩餘等待時間的 Hstack
            tableInformationButton
            ZStack {
                // waiting time screen
                VStack {
                    // 等待剩餘時間的HStack
                    waitingTimeScreen
                        .padding(.bottom)
                    
                    // 空桌狀態的HStack
                    emptyTableInformScreen
                    
                    // 空桌狀態的Drop down screen
                    emptyTableDropDownScreen
                    
                    Spacer()
                }
                
                // table inform screen
                tableInformDropDownScreen
            }
            .padding(.top, -5)
        }
        .padding()

    }
    
    // 剩餘等待時間的Hstack
    private var tableInformationButton: some View {
        HStack {
            Text("剩餘等待時間")
                .fontWeight(.bold)
                .padding(8)
                .background(
                    Rectangle()
                        .foregroundColor(Color.black.opacity(0.1))
                )
                .frame(width: 120, height: 40)
            
            HStack {
                Text(vm.remainTimeCategorySelect[vm.selectedRemainTimeCategoryIdx].name)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                
                Button {
                    withAnimation { tableInformButton.toggle() }
                } label: {
                    Image(systemName: "chevron.down")
                        .foregroundColor(.black)
                        .rotationEffect(Angle(degrees: tableInformButton ? 180 : 0))
                        .frame(width: 20, height: 20)
                }
            }
            .frame(width: 140, height: 40)
            .padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .foregroundColor(Color(hex: "#D9D9D9"))
            )
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.black, lineWidth: 2)
            )
        }
    }
    
    // 空桌狀態的Hstack
    private var emptyTableInformScreen: some View {
        HStack {
            Text("空桌狀態：\(vm.countEmptyTable())")
                .fontWeight(.bold)
                .frame(width: 120)
                
            HStack {
                // 顯示空桌的桌子名稱
                Text("桌號 " + vm.fetchEmptyTableString())
                    .fontWeight(.bold)
                    .frame(width: 120)
                
                // 點擊往下的小icon，點開empty table inform button
                Button {
                    withAnimation { emptyTableInformButton.toggle() }
                } label: {
                    Image(systemName: "chevron.down")
                        .foregroundColor(.black)
                        .rotationEffect(Angle(degrees: emptyTableInformButton ? 180 : 0))
                        .frame(width: 20, height: 20)
                }
            }
            .frame(width: 140, height: 40)
            .padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .foregroundColor(Color(hex: "#D9D9D9"))
            )
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.black, lineWidth: 2)
            )
        }
    }
    
    // 等待時間的頁面
    private var waitingTimeScreen: some View {
        ZStack {
            // drop down bar 第一個按鈕選擇（不顯示）
            if vm.selectedRemainTimeCategoryIdx == 0 {
                // 不顯示
            }
            // drop down bar 第二個按鈕選擇（最短剩餘時間）
            else if vm.selectedRemainTimeCategoryIdx == 1 {
                // 使用TimeSort，判斷時間最短的
                TimeSort(tableInfo: vm.tableInfo)
            }
            // drop down bar 第三個按鈕選擇（所有桌子資訊）
            else if vm.selectedRemainTimeCategoryIdx == 2 {
                Rectangle()
                    .frame(height: CGFloat(CustomerShareInfoManager.instance.homeTable.remainTime.count) * 35)
                    .foregroundColor(.black.opacity(0.1))
                
                // 顯示剩餘等待時間的screen
                VStack {
                    ForEach(CustomerShareInfoManager.instance.homeTable.remainTime.indices, id: \.self) { tableID in
                        HStack {
                            Text("\(CustomerShareInfoManager.instance.homeTable.remainTime[tableID].tableName)")
                                .frame(width: 80)
                                .withCustomModifierForWaitingTime()
                            
                            Image(systemName: "arrow.right")
                            
                            if CustomerShareInfoManager.instance.homeTable.remainTime[tableID].remainTime == "0" {
                                Text("已為空桌")
                                    .frame(width: 120)
                                    .withCustomModifierForWaitingTime()
                            }
                            else {
                                Text("剩餘：\(CustomerShareInfoManager.instance.homeTable.remainTime[tableID].remainTime)分鐘")
                                    .frame(width: 120)
                                    .withCustomModifierForWaitingTime()
                            }
                        }
                    }
                }
            }
            // drop down bar 其他的按鈕選擇（按下什麼桌子，就會顯示那些桌子）
            else {
                Rectangle()
                    .frame(height: 35)
                    .foregroundColor(.black.opacity(0.1))
                
                // 哪張桌子被選到，會打勾並更新array內的Bool
                if vm.remainTimeCategorySelect[vm.selectedRemainTimeCategoryIdx].isSelected {
                    // 顯示剩餘等待時間的screen
                    VStack {
                        HStack {
                            Text("\(CustomerShareInfoManager.instance.homeTable.remainTime[vm.selectedRemainTimeCategoryIdx-3].tableName)")
                                .frame(width: 80)
                                .withCustomModifierForWaitingTime()
                            
                            Image(systemName: "arrow.right")
                            
                            if CustomerShareInfoManager.instance.homeTable.remainTime[vm.selectedRemainTimeCategoryIdx-3].remainTime == "0" {
                                Text("已為空桌")
                                    .frame(width: 120)
                                    .withCustomModifierForWaitingTime()
                            }
                            else {
                                Text("剩餘：\(CustomerShareInfoManager.instance.homeTable.remainTime[vm.selectedRemainTimeCategoryIdx-3].remainTime)分鐘")
                                    .frame(width: 120)
                                    .withCustomModifierForWaitingTime()
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    // 最短剩餘時間的下拉view
    private var tableInformDropDownScreen: some View {
        VStack {
            HStack {
                Spacer()
                // 如果點擊下拉按鈕
                if tableInformButton {
                    List {
                        ForEach(vm.remainTimeCategorySelect) { info in
                            HStack {
                                Text(info.name)
                                    .onTapGesture {
                                        vm.selectRemainTimeCategory(selected: info)
                                        withAnimation { tableInformButton.toggle() }
                                    }
                                Spacer()
                                if info.isSelected {
                                    Image(systemName: "checkmark")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                        .padding(.trailing, 8)
                                }
                            }
                            .frame(width: 160)
                        }
                    }
                    .listStyle(PlainListStyle())
                    .frame(width: 180, height: 140)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color.white)
                            .shadow(radius: 5)
                    )
                }
            }
            Spacer()
        }
    }
    
    // 空桌的下拉view
    private var emptyTableDropDownScreen: some View {
        HStack {
            Spacer()
            if emptyTableInformButton {
                List {
                    ForEach(vm.tableInfo.remainTime, id: \.self) { info in
                        Text(info.tableName)
                            .font(.headline)
                            .frame(maxWidth: .infinity, maxHeight: 30)
                            .background(
                                Rectangle()
                                    .foregroundColor(Color(hex: "#ACDCA0").opacity(info.remainTime == "0" ? 1 : 0))
                            )
                    }
                }
                .frame(width: 180, height: 140)
                .listStyle(PlainListStyle())
                .padding(.top, -3)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color.white)
                        .shadow(radius: 5)
                )
            }
        }
    }
    
    // 把最短剩餘時間的下拉欄append當前桌子數量。
    func arrayAppend(startID: Int) {
        var temp = startID
        for _ in CustomerShareInfoManager.instance.homeTable.remainTime {
            vm.remainTimeCategorySelect.append(.init(name: CustomerShareInfoManager.instance.homeTable.remainTime[temp].tableName, isSelected: false))
//            currentWaitingArray.append(Object(name: CustomerShareInfoManager.instance.homeTable.remainTime[temp].tableName, selected: false))
            temp += 1
        }
    }
}

// 判斷"最短剩餘時間"的桌子
fileprivate struct TimeSort: View {
    let sortedRemainTimeInfo: [RemainTime]
    
    init(tableInfo: CustomerTableInfoModel) {
        sortedRemainTimeInfo = tableInfo.remainTime.sorted {
            Double($0.remainTime)! < Double($1.remainTime)!
        }
    }
    
    var body: some View {
        VStack {
            ForEach(sortedRemainTimeInfo, id: \.self) { info in
                if info.remainTime == sortedRemainTimeInfo[0].remainTime {
                    HStack {
                        // 顯示桌子名稱
                        Text("\(info.tableName)")
                            .foregroundColor(.black)
                            .frame(width: 80, height: 25)
                            .background(Color.white)
                            .background(
                                Rectangle()
                                    .stroke(Color.black, lineWidth: 2)
                            )
                            .padding(4)

                        Image(systemName: "arrow.right")
                        
                        // 顯示桌子當前資訊
                        Text(info.remainTime == "0" ? "已為空桌" : "剩餘：\(info.remainTime)分鐘")
                            .foregroundColor(.black)
                            .frame(width: 120, height: 25)
                            .background(Color.white)
                            .background(
                                Rectangle()
                                    .stroke(Color.black, lineWidth: 2)
                            )
                            .padding(4)
                    }
                }
            }
        }
        .padding(8)
        .padding(.horizontal, 8)
        .background(
            Rectangle()
                .foregroundColor(Color.black.opacity(0.1))
        )
    }
}

struct CustomModifierForWaitingTime: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(.black)
            .frame(height: 25)
            .background(Color.white)
            .background(
                Rectangle()
                    .stroke(Color.black, lineWidth: 2)
            )
            .padding(4)
    }
}

extension View {
    func withCustomModifierForWaitingTime() -> some View {
        modifier(CustomModifierForWaitingTime())
    }
}
