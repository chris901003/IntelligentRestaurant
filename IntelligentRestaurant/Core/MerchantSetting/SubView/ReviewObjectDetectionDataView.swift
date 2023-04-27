//
//  ReviewObjectDetectionDataView.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/4/25.
//

import SwiftUI

struct ReviewObjectDetectionDataView: View {
    
    @Environment(\.dismiss) var dismissView
    @StateObject var vm: ReviewObjectDetectionDataViewModel = ReviewObjectDetectionDataViewModel()
    
    var body: some View {
        ZStack {
            Color.theme.loginBackground
            
            VStack {
                MerchantTopNavigationBarView(title: "查看已上傳資料", titleImage: "photo.stack")
                topBarButton
                trainInfoSection
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
        ZStack {
            HStack {
                Text("返回")
                    .withTopBarButtonModifier(color: Color(hex: "#9B7E6E"))
                    .onTapGesture {
                        dismissView()
                    }
                Spacer()
            }
            HStack {
                Text("長按刪除資料")
                    .underline()
                    .font(.title3)
                    .bold()
                    .foregroundColor(Color(hex: "#9B7E6E"))
            }
        }
        .font(.headline)
        .padding(8)
        .padding(.horizontal, 8)
    }
    
    private var trainInfoSection: some View {
        ScrollView {
            LazyVGrid(columns: [.init(.flexible())]) {
                ForEach(vm.uploadTrainData) { trainInfo in
                    if let image = trainInfo.image,
                       trainInfo.isShow {
                        VStack {
                            Text("食物類別: \(trainInfo.anno.0)")
                                .font(.headline)
                                .foregroundColor(Color.black)
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .contextMenu {
                                    Button(role: .destructive) {
                                        Task { await vm.deleteTrainData(trainDataInfo: trainInfo) }
                                    } label: {
                                        HStack {
                                            Text("刪除")
                                            Image(systemName: "trash")
                                        }
                                    }
                                }
                                .overlay {
                                    GeometryReader { geometry in
                                        ZStack {
                                            Rectangle()
                                                .stroke(Color.pink, lineWidth: 2)
                                                .frame(width: trainInfo.anno.1[2] * geometry.size.width,
                                                       height: trainInfo.anno.1[3] * geometry.size.height)
                                                .offset(x: trainInfo.anno.1[0] * geometry.size.width,
                                                        y: trainInfo.anno.1[1] * geometry.size.height)
                                        }
                                    }
                                }
                        }
                        .frame(width: 300, height: 300)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}
