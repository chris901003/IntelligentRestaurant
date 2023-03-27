//
//  CameraUidSettingView.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/3/17.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct CameraUidSettingView: View {
    
    @StateObject var vm: CameraUidSettingViewModel = CameraUidSettingViewModel()
    
    var body: some View {
        ZStack {
            Color.theme.loginBackground
            VStack {
                MerchantTopNavigationBarView(title: "攝影機UID設定", titleImage: "camera.fill")
                topBackButton
                tableUidsSection
                Spacer()
            }
            .padding(.top, 72)
        }
        .navigationBarBackButtonHidden(true)
        .overlay {
            if vm.isProcessing {
                LoadingView(waitingInfo: "資料讀取中", isProgressView: true)
            }
            if vm.isProcessError {
                ErrorMessageShowView(message: vm.processErrorMessage)
            }
        }
    }
    
    private var topBackButton: some View {
        HStack {
            Text("返回")
                .foregroundColor(Color(hex: "#9B7E6E"))
                .padding(8)
                .padding(.horizontal, 8)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color(hex: "#9B7E6E"), lineWidth: 3)
                )
                .onTapGesture {
                    MerchantShareInfoManager.instance.settingModeSelect = []
                }
            Spacer()
        }
        .font(.headline)
        .padding(8)
        .padding(.horizontal, 8)
    }
    
    private var tableUidsSection: some View {
        ScrollView {
            ForEach(vm.tablesInfo, id: \.1) { tableInfo in
                VStack {
                    HStack {
                        Text("\(tableInfo.0)桌")
                            .font(.title3)
                        Spacer()
                        Button {
                            UIPasteboard.general.string = tableInfo.1
                        } label: {
                            Image(systemName: "doc.on.doc.fill")
                                .foregroundColor(Color(hex: "#5B3E3E"))
                                .padding(4)
                                .background(.ultraThinMaterial)
                                .cornerRadius(5)
                        }
                    }
                    .padding(.horizontal)
                    Text(tableInfo.1)
                        .font(.headline)
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: "#C3B7A9"), lineWidth: 3)
                )
                .padding()
            }
        }
    }
}
