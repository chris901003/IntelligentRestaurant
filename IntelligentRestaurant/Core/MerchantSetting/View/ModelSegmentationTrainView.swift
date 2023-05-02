//
//  ModelSegmentationTrainView.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/4/24.
//

import SwiftUI
import PhotosUI

struct ModelSegmentationTrainView: View {
    
    // TODO: 上傳以資料相關
    
    @StateObject var vm: ModelSegmentationTrainViewModel = ModelSegmentationTrainViewModel()
    @State var selectPhotoItem: PhotosPickerItem? = nil
    @State var isDrawFood: Bool = false
    @State var isDrawNotFood: Bool = false
    @State var topLeft: CGPoint = .zero
    @State var isShowTutorial: Bool = false
    @State var isShowCategorySelect: Bool = false
    
    private let tutorialWidth: CGFloat = UIScreen.main.bounds.size.width / 3 * 2
    
    var body: some View {
        ZStack {
            Color.theme.loginBackground
            
            VStack {
                MerchantTopNavigationBarView(title: "第二階段資料", titleImage: "desktopcomputer")
                topBarButton
                drawAnnotationButton
                Spacer()
                
                bodySection
                
                Spacer()
            }
            .padding(.top, 72)
            
            if (vm.trainImage != nil) && (!vm.drawFoodPath.isEmpty) {
                DrawPathView(drawPath: vm.drawFoodPath, topLeft: topLeft)
                    .stroke(Color.pink, lineWidth: 2)
            }
            
            if (vm.trainImage != nil) && (!vm.drawNotFoodPath.isEmpty) {
                DrawPathView(drawPath: vm.drawNotFoodPath, topLeft: topLeft)
                    .stroke(Color.blue, lineWidth: 2)
            }
            
            if (vm.trainImage == nil) && isShowTutorial {
                tutorialSection
            }
            
            if isShowCategorySelect {
                selectCategorySection
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
            Button {
                if isDrawFood {
                    let _ = vm.drawFoodPath.popLast()
                } else if isDrawNotFood {
                    let _ = vm.drawNotFoodPath.popLast()
                }
            } label: {
                Text("上一步")
                    .withTopBarButtonModifier(color: Color.orange)
            }
        }
        .font(.headline)
        .padding(8)
        .padding(.horizontal, 8)
        .onChange(of: selectPhotoItem) { newValue in
            vm.drawFoodPath = []
            vm.drawNotFoodPath = []
            isDrawFood = false
            isDrawNotFood = false
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
                            if isDrawFood {
                                vm.drawFoodPath.append(.init(x: location.x, y: location.y))
                            } else if isDrawNotFood {
                                vm.drawNotFoodPath.append(.init(x: location.x, y: location.y))
                            }
                        }
                        .overlay {
                            GeometryReader { geometry in
                                Text("")
                                    .onAppear {
                                        topLeft.x = geometry.frame(in: .global).minX
                                        topLeft.y = geometry.frame(in: .global).minY
                                        vm.showImageWidth = geometry.frame(in: .global).width
                                        vm.showImageHeight = geometry.frame(in: .global).height
                                    }
                                    .onChange(of: geometry.frame(in: .global)) { geometry in
                                        topLeft.x = geometry.minX
                                        topLeft.y = geometry.minY
                                        vm.showImageWidth = geometry.width
                                        vm.showImageHeight = geometry.height
                                    }
                            }
                        }
                }
            } else {
                PhotosPicker(selection: $selectPhotoItem, matching: .images) {
                    Text("請選擇一張圖像上傳")
                }
                .overlay {
                    HStack {
                        Spacer()
                        Image(systemName: "info.circle")
                            .font(.headline)
                            .offset(x: 15, y: -15)
                            .onTapGesture { withAnimation { isShowTutorial.toggle() } }
                    }
                }
            }
        }
    }
    
    private var tutorialSection: some View {
        ZStack {
            Color.white.opacity(0.01).onTapGesture { withAnimation { isShowTutorial.toggle() } }
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("使用方式")
                            .font(.title3)
                            .bold()
                        Text("步驟ㄧ: \n點選「匡出食物」將食物的部分匡選出來，點選「結束」會將自動將終點與其點連接")
                        Text("步驟二: \n點選「匡出非食物」將碗中非食物的部分匡選出來，點選「結束」會將自動將終點與其點連接")
                        Text("步驟三: \n點選「上傳」將標注好的資料上傳")
                        Text("Tip: 若匡選錯誤可以使用「上一步」來返回上一步")
                            .foregroundColor(Color.secondary)
                            .font(.subheadline)
                        Spacer()
                    }
                }
                Text("返回")
                    .withTopBarButtonModifier(color: .blue)
                    .onTapGesture { withAnimation { isShowTutorial.toggle() } }
            }
            .font(.subheadline)
            .frame(width: tutorialWidth, height: 250)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color.white.shadow(.drop(radius: 5)))
            )
        }
    }
    
    private var drawAnnotationButton: some View {
        HStack {
            if isDrawFood {
                Text("結束")
                    .withTopBarButtonModifier(color: Color.pink)
                    .onTapGesture {
                        isDrawFood.toggle()
                        if !vm.drawFoodPath.isEmpty { vm.drawFoodPath.append(vm.drawFoodPath[0]) }
                    }
            } else {
                Text("匡出食物")
                    .withTopBarButtonModifier(color: Color(hex: "#9B7E6E"))
                    .opacity(isDrawNotFood ? 0.5 : 1)
                    .onTapGesture {
                        if isDrawNotFood { return }
                        if vm.trainImage != nil {
                            if !vm.drawFoodPath.isEmpty { let _ = vm.drawFoodPath.popLast() }
                            isDrawFood.toggle()
                        }
                    }
            }
            
            if isDrawNotFood {
                Text("結束")
                    .withTopBarButtonModifier(color: Color.pink)
                    .onTapGesture {
                        isDrawNotFood.toggle()
                        if !vm.drawNotFoodPath.isEmpty { vm.drawNotFoodPath.append(vm.drawNotFoodPath[0]) }
                    }
            } else {
                Text("匡出非食物")
                    .withTopBarButtonModifier(color: Color(hex: "#9B7E6E"))
                    .opacity(isDrawFood ? 0.5 : 1)
                    .onTapGesture {
                        if isDrawFood { return }
                        if vm.trainImage != nil {
                            if !vm.drawNotFoodPath.isEmpty { let _ = vm.drawNotFoodPath.popLast() }
                            isDrawNotFood.toggle()
                        }
                    }
            }
            Text("送出")
                .withTopBarButtonModifier(color: Color.blue)
                .opacity(vm.trainImage != nil ? 1 : 0.5)
                .onTapGesture {
                    if vm.trainImage != nil {
                        withAnimation { isShowCategorySelect.toggle() }
                    }
                }
        }
        .bold()
    }
    
    private var selectCategorySection: some View {
        ZStack {
            Color.white.opacity(0.01)
                .onTapGesture { withAnimation { isShowCategorySelect.toggle() } }
            VStack {
                Text("選擇類別")
                    .font(.headline)
                ScrollView(showsIndicators: false) {
                    ForEach(vm.categoryList, id: \.self.1) { categoryInfo in
                        Text("\(categoryInfo.0)")
                            .padding(8)
                            .padding(.horizontal, 8)
                            .font(.headline)
                            .frame(width: 125)
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color(hex: "#9B7E6E"), lineWidth: 3)
                            )
                            .padding(8)
                            .onTapGesture {
                                Task {
                                    vm.selectedCategory = categoryInfo.0
                                    await vm.uploadTrainData()
                                }
                            }
                    }
                }
                Text("取消")
                    .font(.headline)
                    .withTopBarButtonModifier(color: Color.blue)
                    .onTapGesture { withAnimation { isShowCategorySelect.toggle() } }
            }
            .frame(width: tutorialWidth - 50, height: 250)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color.white.shadow(.drop(radius: 0.5)))
            )
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
