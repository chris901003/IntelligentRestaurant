//
//  ModelTrainDataView.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/4/22.
//

import SwiftUI
import PhotosUI

struct ModelObjectDetectionTrainDataView: View {
    
    // TODO: 在進入兩個畫面前都需要檢查該使用者是否正在訓練，如果正在訓練就需要禁止進入
    @StateObject var vm: ModelObjectDetectionTrainDataViewModel = ModelObjectDetectionTrainDataViewModel()
    @Environment(\.dismiss) var dismissView
    @State var selectedPhotoItem: PhotosPickerItem? = nil
    @State var boxOffset: CGSize = .zero
    @State var tmpOffset: CGSize = .zero
    @State var boxFrame: CGSize = .init(width: 150, height: 150)
    @State var isShowSelectCategory: Bool = false
    @State var isShowTrainAlert: Bool = false
    
    // Private Variable
    private let minBoxWidth: CGFloat = 50
    private let minBoxHeight: CGFloat = 50
    private let maxBoxWidth: CGFloat = 300
    private let maxBoxHeight: CGFloat = 450
    
    var body: some View {
        ZStack {
            Color.theme.loginBackground
            VStack {
                MerchantTopNavigationBarView(title: "第一階段資料", titleImage: "desktopcomputer")
                topBarButton
                topBarSecondLine
                Spacer()
                bodySection
                Spacer()
            }
            .padding(.top, 72)
            
            if isShowSelectCategory {
                categorySelectSection
            }
            
            if isShowTrainAlert {
                confirmTrainModel
            }
            
            if vm.isShowTrainAlert {
                AlertTrainView(isShowTrainAlert: $vm.isShowTrainAlert, alertInfo: vm.trainingInfo)
            }
            
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
            Text("上傳")
                .withTopBarButtonModifier(color: Color(hex: "#9B7E6E"))
                .onTapGesture {
                    isShowSelectCategory.toggle()
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
    
    private var topBarSecondLine: some View {
        HStack {
            Spacer()
            NavigationLink {
                ReviewObjectDetectionDataView()
                    .edgesIgnoringSafeArea(.top)
            } label: {
                Text("已上傳")
                    .withTopBarButtonModifier(color: Color(hex: "#9B7E6E"))
            }
            Text("暫停訓練")
                .withTopBarButtonModifier(color: vm.trainingInfo.trainType == .unknow ? Color.orange.opacity(0.5) : Color.orange)
                .onTapGesture {
                    if vm.trainingInfo.trainType != .unknow {
                        vm.isShowTrainAlert.toggle()
                    }
                }
            Text("開始訓練")
                .withTopBarButtonModifier(color: Color.pink)
                .onTapGesture {
                    Task { await vm.fetchTraiDataCount() }
                    isShowTrainAlert.toggle()
                }
        }
        .bold()
        .padding(.horizontal, 8)
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
    
    private var categorySelectSection: some View {
        ZStack {
            Color.black.opacity(0.01)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onTapGesture { isShowSelectCategory.toggle() }
            
            VStack {
                HStack {
                    Image(systemName: "xmark")
                        .foregroundColor(Color.pink)
                        .frame(width: 30, height: 30)
                        .onTapGesture { isShowSelectCategory.toggle() }
                    Spacer()
                }
                .padding(.top, 8)
                .padding(.leading, 8)
                Text("選擇食物類型")
                    .font(.headline)
                ScrollView(showsIndicators: false) {
                    ForEach(vm.categoryList, id: \.self.1) { category in
                        Text(category.0)
                            .font(.headline)
                            .frame(width: 100, height: 45)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color(hex: "#9B7E6E"), lineWidth: 2)
                            )
                            .padding(8)
                            .onTapGesture {
                                vm.selectedCategory = category.1
                                isShowSelectCategory.toggle()
                                Task { await vm.uploadTrainData(boxFrame: boxFrame, boxOffset: boxOffset) }
                            }
                    }
                }
                Spacer()
            }
            .frame(width: 250, height: 300)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .foregroundStyle(Color.white.shadow(.drop(radius: 5)))
            )
        }
    }
    
    private var confirmTrainModel: some View {
        ZStack {
            Color.white.opacity(0.01)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onTapGesture { isShowTrainAlert.toggle() }
            VStack {
                HStack {
                    Image(systemName: "xmark")
                        .foregroundColor(Color.pink)
                        .frame(width: 30, height: 30)
                        .onTapGesture { isShowTrainAlert.toggle() }
                    Spacer()
                }
                .padding(.top, 8)
                .padding(.leading, 8)
                Text("訓練第一階段模型")
                    .padding(.bottom, 8)
                Text("目前擁有\(vm.trainImageCount)張圖像資料")
                    .font(.title2)
                    .padding(.bottom, 8)
                Group {
                    Text("在訓練過程中依舊可以正常使用本系統")
                    Text("但是會關閉上傳資料的服務")
                    Text("等到訓練完畢就會重新開啟資料上傳服務")
                    Text("訓練後不刪除原先上傳的資料")
                    Text("若要刪除資料請到刪除頁面中刪除")
                }
                .font(.footnote)
                .foregroundColor(Color.secondary)
                Spacer()
                Text("開始訓練")
                    .font(.headline)
                    .padding(8)
                    .foregroundColor(Color.blue)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.blue, lineWidth: 2)
                    )
                    .onTapGesture {
                        Task {
                            let queryResult = await vm.startTrainModel()
                            if queryResult {
                                dismissView()
                            }
                        }
                    }
                    .padding()
            }
            .frame(width: 300, height: 280)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color.white.shadow(.drop(radius: 5)))
            )
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

extension ModelObjectDetectionTrainDataView {
    
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
