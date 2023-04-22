//
//  ModelTrainDataView.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/4/22.
//

import SwiftUI
import PhotosUI

struct ModelTrainDataView: View {
    
    @StateObject var vm: ModelTrainDataViewModel = ModelTrainDataViewModel()
    @State var selectedPhotoItem: PhotosPickerItem? = nil
    @State var boxOffset: CGSize = .zero
    @State var tmpOffset: CGSize = .zero
    @State var boxFrame: CGSize = .init(width: 150, height: 150)
    
    // Private Variable
    private let minBoxWidth: CGFloat = 50
    private let minBoxHeight: CGFloat = 50
    private let maxBoxWidth: CGFloat = 300
    private let maxBoxHeight: CGFloat = 450
    
    var body: some View {
        ZStack {
            Color.theme.loginBackground
            VStack {
                MerchantTopNavigationBarView(title: "模型再訓練", titleImage: "desktopcomputer")
                topBarButton
                Spacer()
                bodySection
                
                Spacer()
            }
            .padding(.top, 72)
            
            if vm.isProcessing {
                LoadingView(waitingInfo: vm.loadingMessage, isProgressView: true)
            }
            if vm.isProcessError {
                ErrorMessageShowView(message: vm.processErrorMessage)
            }
            if vm.isShowSuccessSaveTrainData {
                checkAnimationMark
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
            PhotosPicker(selection: $selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                Text("選擇圖像")
                    .withTopBarButtonModifier(color: Color.blue)
            }
            Text("資料上傳")
                .withTopBarButtonModifier(color: Color(hex: "#9B7E6E"))
                .onTapGesture {
                    Task { await vm.uploadTrainData(boxFrame: boxFrame, boxOffset: boxOffset) }
                }
        }
        .font(.headline)
        .padding(8)
        .padding(.horizontal, 8)
        .onChange(of: selectedPhotoItem) { newValue in
            guard let newValue = newValue else { return }
            Task { await vm.transferTrainImage(selecteItem:newValue) }
        }
    }
    
    private var bodySection: some View {
        VStack {
            if let _ = vm.trainImage {
                imageWithBoxSection
            } else{
                Text("請上傳一張圖像")
            }
        }
    }
    
    private var imageWithBoxSection: some View {
        ZStack {
            Image(uiImage: vm.trainImage!)
                .resizable()
                .scaledToFit()
                .overlay {
                    GeometryReader { geometry in
                        VStack { }
                            .onChange(of: vm.trainImage!) { _ in
                                vm.imageWidth = geometry.size.width
                                vm.imageHeight = geometry.size.height
                            }
                            .onAppear {
                                vm.imageWidth = geometry.size.width
                                vm.imageHeight = geometry.size.height
                            }
                    }
                }
            
            ZStack {
                Rectangle()
                    .stroke(Color.pink, lineWidth: 2)
                    .offset(x: boxOffset.width + tmpOffset.width, y: boxOffset.height + tmpOffset.height)
                Rectangle()
                    .foregroundColor(Color.white.opacity(0.01))
                    .offset(x: boxOffset.width + tmpOffset.width, y: boxOffset.height + tmpOffset.height)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                tmpOffset.width = value.translation.width
                                tmpOffset.height = value.translation.height
                            }
                            .onEnded { value in
                                boxOffset.width += tmpOffset.width
                                boxOffset.height += tmpOffset.height
                                tmpOffset = .zero
                            }
                    )
                ZStack(alignment: .topLeading) {
                    Text("").frame(width: boxFrame.width, height: boxFrame.height)
                    Text("")
                        .frame(width: 15, height: 15)
                        .background(Color.blue)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let widthDiff = value.translation.width * -1
                                    let heightDiff = value.translation.height * -1
                                    boxOffset.width -= widthDiff / 2
                                    boxOffset.height -= heightDiff / 2
                                    boxFrame.width = min(maxBoxWidth, max(minBoxWidth, boxFrame.width + widthDiff))
                                    boxFrame.height = min(maxBoxHeight, max(minBoxHeight, boxFrame.height + heightDiff))
                                }
                        )
                }
                .offset(x: boxOffset.width + tmpOffset.width, y: boxOffset.height + tmpOffset.height)
                ZStack(alignment: .topTrailing) {
                    Text("").frame(width: boxFrame.width, height: boxFrame.height)
                    Text("")
                        .frame(width: 15, height: 15)
                        .background(Color.blue)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let widthDiff = value.translation.width
                                    let heightDiff = value.translation.height * -1
                                    boxOffset.width += widthDiff / 2
                                    boxOffset.height -= heightDiff / 2
                                    boxFrame.width = min(maxBoxWidth, max(minBoxWidth, boxFrame.width + widthDiff))
                                    boxFrame.height = min(maxBoxHeight, max(minBoxHeight, boxFrame.height + heightDiff))
                                }
                        )
                }
                .offset(x: boxOffset.width + tmpOffset.width, y: boxOffset.height + tmpOffset.height)
                ZStack(alignment: .bottomLeading) {
                    Text("").frame(width: boxFrame.width, height: boxFrame.height)
                    Text("")
                        .frame(width: 15, height: 15)
                        .background(Color.blue)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let widthDiff = value.translation.width * -1
                                    let heightDiff = value.translation.height
                                    boxOffset.width -= widthDiff / 2
                                    boxOffset.height += heightDiff / 2
                                    boxFrame.width = min(maxBoxWidth, max(minBoxWidth, boxFrame.width + widthDiff))
                                    boxFrame.height = min(maxBoxHeight, max(minBoxHeight, boxFrame.height + heightDiff))
                                }
                        )
                }
                .offset(x: boxOffset.width + tmpOffset.width, y: boxOffset.height + tmpOffset.height)
                ZStack(alignment: .bottomTrailing) {
                    Text("").frame(width: boxFrame.width, height: boxFrame.height)
                    Text("")
                        .frame(width: 15, height: 15)
                        .background(Color.blue)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let widthDiff = value.translation.width
                                    let heightDiff = value.translation.height
                                    boxOffset.width += widthDiff / 2
                                    boxOffset.height += heightDiff / 2
                                    boxFrame.width = min(maxBoxWidth, max(minBoxWidth, boxFrame.width + widthDiff))
                                    boxFrame.height = min(maxBoxHeight, max(minBoxHeight, boxFrame.height + heightDiff))
                                }
                        )
                }
                .offset(x: boxOffset.width + tmpOffset.width, y: boxOffset.height + tmpOffset.height)
            }
            .frame(width: boxFrame.width, height: boxFrame.height)
        }
    }
    
    private var checkAnimationMark: some View {
        VStack {
            AnimatedCheckMarkView(animationDuration: 0.75, size: CGSize(width: 100, height: 100), strokeStyle: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
        }
        .padding(32)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 5)
    }
}

extension ModelTrainDataView {
    
    /// 查看此拖移屬於移動或是放大
    func checkDrageMode(tapPosition: CGPoint) -> DragMode {
        let range: CGFloat = 20
        let tapX = tapPosition.x - boxOffset.width
        let tapY = tapPosition.y - boxOffset.height
        let boxWidth = boxFrame.width
        let boxHeight = boxFrame.height
        if 0 <= tapX && tapX <= range && 0 <= tapY && tapY <= range { return .scaleTopLeft }
        else if boxWidth - range <= tapX && tapX <= boxWidth + range && 0 <= tapY && tapY <= range { return .scaleTopRight}
        else if 0 <= tapX && tapX <= range && boxHeight - range <= tapY && tapY <= boxHeight + range { return .scaleBotLeft }
        else if boxWidth - range <= tapX && tapX <= boxWidth + range && boxHeight - range <= tapY && tapY <= boxHeight + range { return .scaleBotRight }
        return .positionChange
    }
    
    enum DragMode {
        case positionChange
        case scaleTopLeft
        case scaleTopRight
        case scaleBotLeft
        case scaleBotRight
    }
}

struct topBarButtonModifier: ViewModifier {
    
    let color: Color
    func body(content: Content) -> some View {
        content
            .foregroundColor(color)
            .padding(8)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(color, lineWidth: 3)
            )
    }
}

extension View {
    func withTopBarButtonModifier(color: Color) -> some View {
        modifier(topBarButtonModifier(color: color))
    }
}
