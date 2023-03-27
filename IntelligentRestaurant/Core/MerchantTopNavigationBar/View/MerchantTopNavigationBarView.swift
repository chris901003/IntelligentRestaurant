//
//  MerchantTopNavigationBarView.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/3/11.
//

import Foundation
import SwiftUI

struct MerchantTopNavigationBarView: View {
    
    @StateObject var vm: MerchantTopNavigationBarViewModel = MerchantTopNavigationBarViewModel()
    
    var title: String
    var titleImage: String
    
    var body: some View {
        HStack {
            Image(systemName: titleImage)
            Text(title)
            Spacer()
            Image(systemName: "line.3.horizontal")
                .font(.title3)
                .bold()
                .foregroundColor(Color(hex: "#363636"))
                .padding()
                .background(Color(hex: "#FFFFFF").opacity(0.7))
                .padding(-16)
                .onTapGesture { withAnimation { vm.isShowSelectList.toggle() } }
        }
        .font(.headline)
        .padding()
        .background(
            Rectangle()
                .foregroundColor(Color(hex: "#C4B7A9").opacity(0.7))
        )
        .fullScreenCover(isPresented: $vm.isShowSelectList) {
            ZStack {
                Color.white.opacity(0.01).onTapGesture { withAnimation { vm.isShowSelectList.toggle() } }
                selectListSection
            }
            .overlay {
                if vm.isShowLogout {
                    logoutAlertSection
                }
            }
        }
    }
    
    private var selectListSection: some View {
        HStack {
            Spacer()
            List {
                HStack {
                    Text("我的帳號")
                    Spacer()
                    Image(systemName: "person")
                        .padding(.trailing, 4)
                }
                .onTapGesture {
                    withAnimation { vm.isShowSelectList.toggle() }
                    MerchantShareInfoManager.instance.tabViewSelect = 3
                }
                Text("權重設定")
                    .onTapGesture {
                        withAnimation { vm.isShowSelectList.toggle() }
                        MerchantShareInfoManager.instance.settingModeSelect = [1]
                        MerchantShareInfoManager.instance.tabViewSelect = 2
                    }
                Text("空間設定")
                    .onTapGesture {
                        withAnimation { vm.isShowSelectList.toggle() }
                        MerchantShareInfoManager.instance.settingModeSelect = [2]
                        MerchantShareInfoManager.instance.tabViewSelect = 2
                    }
                Text("使用端設定")
                    .onTapGesture {
                        withAnimation { vm.isShowSelectList.toggle() }
                        MerchantShareInfoManager.instance.settingModeSelect = [3]
                        MerchantShareInfoManager.instance.tabViewSelect = 2
                    }
                Text("攝影機UID設定")
                    .onTapGesture {
                        withAnimation { vm.isShowSelectList.toggle() }
                        MerchantShareInfoManager.instance.settingModeSelect = [4]
                        MerchantShareInfoManager.instance.tabViewSelect = 2
                    }
                Text("登出")
                    .onTapGesture { vm.isShowLogout.toggle() }
            }
            .bold()
            .listStyle(PlainListStyle())
            .frame(width: 150)
            .cornerRadius(10)
            .shadow(radius: 5)
            .background(TransparentBackground())
        }
        .padding(.top, 72)
    }
    
    private var logoutAlertSection: some View {
        VStack {
            HStack {
                Spacer()
                Image(systemName: "xmark")
                    .onTapGesture { vm.isShowLogout.toggle() }
            }
            Text("登出確認")
                .padding(.bottom)
            HStack(spacing: 16) {
                Text("確認")
                    .padding(8)
                    .padding(.horizontal)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(lineWidth: 2)
                    )
                    .onTapGesture { vm.logout() }
                Text("取消")
                    .padding(8)
                    .padding(.horizontal)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(lineWidth: 2)
                    )
                    .onTapGesture { vm.isShowLogout.toggle() }
            }
            .foregroundColor(Color(hex: "#715428"))
        }
        .font(.headline)
        .padding()
        .frame(width: 300)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color.white.shadow(.drop(radius: 5)))
        )
    }
}
