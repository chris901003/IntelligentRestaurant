//
//  CustomerSearchView.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/5/6.
//

import SwiftUI

struct CustomerSearchView: View {
    
    @StateObject var vm : SearchViewModel = SearchViewModel()
    @StateObject var homevm : HomeViewModel = HomeViewModel()
    
    @State var searchButton: Bool = false
    @State var selectedMerchant: Bool = false
    @State var selectMerchantNot200: Bool = false
    
    var body: some View {
        ZStack {
            // background
            Color.theme.loginBackground.edgesIgnoringSafeArea(.all)
            
            VStack {
                // 查詢店家的bar
                searchBarSection
                ZStack {
                    storeInformSection
                    if searchButton {
                        VStack {
                            searchSection
                            Spacer()
                        }
                    }
                    // 如果選擇的店家無食物資訊
                    if homevm.status {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundColor(Color(hex: "ECD2D2"))
                            VStack{
                                HStack {
                                    Spacer()
                                    Button {
                                        homevm.status.toggle()
                                        selectedMerchant = false
                                    } label: {
                                        Image(systemName: "xmark")
                                            .foregroundColor(.black)
                                            .frame(width: 50, height: 50)
                                    }
                                }
                                Text("此商家尚未準備好")
                            }
                        }
                        .frame(width: 200, height: 100)
                    }
                }
                .padding([.leading, .trailing],35)
            }
            
            if vm.isProcess {
                LoadingView(waitingInfo: vm.loadingMessage, isProgressView: true)
            }
            if vm.isProcessError {
                ErrorMessageShowView(message: vm.errorMessage)
            }
            
        }
    }
    
    // 查詢店家的Bar
    private var searchBarSection: some View {
        HStack{
            Image(systemName: "magnifyingglass")
                .frame(width: 40)
            TextField("請輸入店家名稱...", text: $vm.merchantName)
            
            Button {
                Task { await vm.searchMerchantName() }
                searchButton = true
                selectedMerchant = false
            } label: {
                Image(systemName: "arrow.turn.down.left")
            }
            .padding(5)
        }
        .foregroundColor(Color(hex: "715428"))
        .frame(height: 50)
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(hex: "#715428"), lineWidth: 2)
        )
        .padding([.top, .leading, .trailing])
    }
    
    // 店家資訊
    private var storeInformSection: some View {
        VStack {
            HStack{
                if let imageData = vm.showedMerchant.photo,
                   let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                } else {
                    Image("person")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                }
                
                Text("店家資訊")
                    .font(.title)
                    .bold()
                    .foregroundColor(Color.black)
                    .frame(width: 180)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .frame(height: 30)
                            .foregroundColor(Color(hex: "#B08B2C").opacity(0.4))
                            .padding(.top, 20)
                    )
                
                Image("LittleGirl")
                    .resizable()
                    .frame(width: 60, height: 50)
                    .padding(.bottom, -20)
            }
            
            VStack {
                HStack {
                    Text(vm.showedMerchant.name == "" ? "店名" : vm.showedMerchant.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                    
                    Button {
                        // 保存資料到"我的最愛"
                        let merchantUid = vm.showedMerchant.uid
                        guard vm.showedMerchant.name != "" else { return }
                        if !vm.showedMerchant.favorite {
                            Task { await vm.putIntoMyFavList(merchantUid: merchantUid) }
                        }
                        else {
                            Task { await vm.deleteMyFavItem(merchantUid: merchantUid) }
                        }
                    } label: {
                        Image(systemName: vm.showedMerchant.favorite ? "star.fill" : "star")
                    }
                    .foregroundColor(Color(hex: "#CD32DB"))
                }
                .padding(.bottom, 8)
                
                HStack {
                    Text("地址：" + vm.showedMerchant.location)
                        .font(.title3)
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding(.bottom, 4)
                
                HStack {
                    Text("電話：" + vm.showedMerchant.phoneNumber)
                        .font(.title3)
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding(.bottom, 4)
                
                Divider()
                
                Text("店家介紹")
                    .font(.title3)
                    .fontWeight(.semibold)
                Text(vm.showedMerchant.intro == "" ? "..." : vm.showedMerchant.intro)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundColor(Color(hex: "#FFFBFB"))
                    )
            }
            .padding()
            .background(
                Rectangle()
                    .foregroundColor(.white.opacity(0.4))
            )
            
            ZStack {
                Button {
                    // 紀錄被選擇的店家 食物資訊
                    dataShowInHomeView()
                    CustomerShareInfoManager.instance.nowHomeMerchantUid = vm.showedMerchant.uid
                    selectedMerchant.toggle()
                    if selectedMerchant {
                        homevm.getTableInfo(merchantUid: vm.showedMerchant.uid)
                    }
                    else {
                        // 表示主頁不會顯示畫面
                        CustomerShareInfoManager.instance.nowHomeMerchantUid = "-1"
                    }
                } label: {
                    Text(selectedMerchant ? "已選擇店家" : "選擇顯示此店家")
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "715428"))
                        .padding()
                        .frame(height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color(hex: "715428"), lineWidth: 2)
                        )
                }
                .padding(5)
                
                HStack {
                    Spacer()
                    
                    Image(systemName: selectedMerchant ? "checkmark.square" : "square")
                        .foregroundColor(Color(hex: "715428"))
                }
                
            }
        }
    }
    
    // 搜尋下拉bar
    // 顯示店家資訊頁面
    private var searchSection: some View {
        VStack {
            if vm.searchedMerchant.count > 0 {
                ScrollView {
                    ForEach(vm.searchedMerchant) { info in
                        HStack {
                            Button {
                                // 按下按鈕後跟後端要店家資訊
                                let merchantUid = info.uid
                                Task { await vm.getMerchantInfo(merchantUid: merchantUid) }
                                searchButton = false
                                vm.merchantName = ""
                            } label: {
                                if let imageData = info.photo,
                                   let image = UIImage(data: imageData) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                } else {
                                    Image("person")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                }
                                Text(info.name)
                                    .font(.title2)
                                Spacer()
                                Text(info.location) // 放地址
                                    .font(.callout)
                                    .foregroundColor(.gray)
                                    .frame(width: 80)
                            }
                            .foregroundColor(.black)
                            
                            Button {
                                // 保存資料到"我的最愛"
                                if !info.favorite {
                                    Task { await vm.putIntoMyFavList(merchantUid: info.uid) }
                                }
                                else {
                                    Task { await vm.deleteMyFavItem(merchantUid: info.uid) }
                                }
                            } label: {
                                Image(systemName: info.favorite ? "star.fill" : "star")
                            }
                            .frame(width: 30)
                            .foregroundColor(Color(hex: "D6B6D9"))
                        }
                        .frame(height: 60)
                        .padding(5)
                        Divider()
                    }
                }.frame(height: 200)
            }
            else {
                VStack{
                    Text("查無資料").font(.title)
                }
                .frame(height: 200)
            }
            
            // 取消查詢按鈕
            Button {
                searchButton = false
                vm.merchantName = ""
            } label: {
                Text("取消查詢")
                    .foregroundColor(Color.black)
                    .padding(3)
                    .background {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.black, lineWidth: 2)
                    }
            }
            .shadow(radius: 2)
            .frame(height: 25)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: 240)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color.white)
        )
    }
    
    func clearSearchButton() {
        searchButton = false
    }
    
    func clearMerchantData() {
        vm.merchantName = ""
    }
    
    func dataShowInHomeView() {
//        CustomerShareInfoManager.instance.merchant = vm.showedMerchant
    }
}
