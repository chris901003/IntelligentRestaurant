//
//  ModelSegmentationTrainView.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/4/24.
//

import SwiftUI
import PhotosUI

struct ModelSegmentationTrainView: View {
    
    // 上傳以資料相關
    
    @StateObject var vm: ModelSegmentationTrainViewModel = ModelSegmentationTrainViewModel()
    @State var selectPhotoItem: PhotosPickerItem? = nil
    @State var isStartDraw: Bool = false
    @State var topLeft: CGPoint = .zero
    
    var body: some View {
        ZStack {
            Color.theme.loginBackground
            
            VStack {
                MerchantTopNavigationBarView(title: "第二階段資料", titleImage: "desktopcomputer")
                topBarButton
                Spacer()
                
                bodySection
                
                Spacer()
            }
            .padding(.top, 72)
            
            if (vm.trainImage != nil) && (!vm.drawPath.isEmpty) {
                DrawPathView(drawPath: vm.drawPath, topLeft: topLeft)
                    .stroke(Color.pink, lineWidth: 2)
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
            PhotosPicker(selection: $selectPhotoItem, matching: .images) {
                Text("選擇圖像")
                    .withTopBarButtonModifier(color: Color.blue)
            }
            if isStartDraw {
                Text("結束")
                    .withTopBarButtonModifier(color: Color.pink)
                    .onTapGesture { isStartDraw.toggle() }
            } else {
                Text("開始")
                    .withTopBarButtonModifier(color: Color.green)
                    .onTapGesture {
                        if vm.trainImage != nil {
                            isStartDraw.toggle()
                        }
                    }
            }
            Button {
                vm.backStep()
            } label: {
                Text("上一步")
                    .withTopBarButtonModifier(color: Color.orange)
            }
        }
        .font(.headline)
        .padding(8)
        .padding(.horizontal, 8)
        .onChange(of: selectPhotoItem) { newValue in
            vm.drawPath = []
            isStartDraw = false
            guard let newValue = newValue else { return }
            Task { await vm.transferTrainImage(selectItem: newValue) }
        }
    }
    
    private var bodySection: some View {
        VStack {
            if let image = vm.trainImage {
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .onTapGesture { location in
                            if isStartDraw {
                                vm.drawPath.append(.init(x: location.x, y: location.y))
                            }
                        }
                        .overlay {
                            GeometryReader { geometry in
                                Text("")
                                    .onAppear {
                                        topLeft.x = geometry.frame(in: .global).minX
                                        topLeft.y = geometry.frame(in: .global).minY
                                    }
                                    .onChange(of: geometry.frame(in: .global)) { geometry in
                                        topLeft.x = geometry.minX
                                        topLeft.y = geometry.minY
                                    }
                            }
                        }
                }
            } else {
                PhotosPicker(selection: $selectPhotoItem, matching: .images) {
                    Text("請選擇一張圖像上傳")
                }
            }
        }
    }
}

struct DrawPathView: Shape {
    
    let drawPath: [CGPoint]
    let topLeft: CGPoint
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let offsetPath = drawPath.map {
            CGPoint(x: $0.x + topLeft.x, y: $0.y + topLeft.y)
        }
        guard !offsetPath.isEmpty else { return path }
        path.move(to: offsetPath[0])
        path.addLines(offsetPath)
        return path
    }
}
