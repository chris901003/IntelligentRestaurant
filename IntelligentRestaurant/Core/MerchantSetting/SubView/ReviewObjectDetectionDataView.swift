//
//  ReviewObjectDetectionDataView.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/4/25.
//

import SwiftUI

struct ReviewObjectDetectionDataView: View {
    
    @StateObject var vm: ReviewObjectDetectionDataViewModel = ReviewObjectDetectionDataViewModel()
    
    var body: some View {
        ZStack {
            Color.theme.loginBackground
            
            VStack {
                MerchantTopNavigationBarView(title: "查看已上傳資料", titleImage: "photo.stack")
                topBarButton
                Spacer()
            }
            .padding(.top, 72)
            
            if vm.isProcessing {
                LoadingView(waitingInfo: vm.loadingMessage, isProgressView: true)
            }
            if vm.isProcessError {
                ErrorMessageShowView(message: vm.errorMessage)
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
