//
//  MerchantRoomSpaceView.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/3/14.
//

import Foundation
import SwiftUI

struct MerchantRoomSpaceView: View {
    
    @StateObject var vm: MerchantRoomSpaceViewModel = MerchantRoomSpaceViewModel()
    @State var isShowTableInfo: Bool = false
    @State var isShowSaveAlert: Bool = false
    
    var body: some View {
        ZStack {
            Color(hex: "#DCD1C3")
            
            VStack(spacing: 0) {
                
                MerchantTopNavigationBarView(title: "空間設定", titleImage: "gear")
                
                ZStack {
                    Color(hex: "#F2F1E1")
                    
                    VStack {
                        topBarButton
                        roomSpaceItemSection
                        Spacer()
                        bottomItemSelectBar
                    }
                    .padding()
                    
                    if isShowTableInfo {
                        tableInfoSection
                    }
                }
            }
            .padding(.top, 72)
        }
        .navigationBarBackButtonHidden(true)
        .overlay {
            if isShowSaveAlert {
                saveAlertSection
            }
        }
        .overlay {
            if vm.isProcessing {
                LoadingView(waitingInfo: "讀取中", isProgressView: true)
            }
            if vm.isProcessError {
                ErrorMessageShowView(message: vm.processErrorMessage)
            }
            if vm.isShowSuccessSaveSpaceItem {
                checkAnimationMark
            }
        }
    }
    
    private var topBarButton: some View {
        HStack {
            Text("返回")
                .padding(8)
                .padding(.horizontal, 8)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(lineWidth: 3)
                )
                .onTapGesture {
                    MerchantShareInfoManager.instance.settingModeSelect = []
                }
            Spacer()
            Text("還原")
                .foregroundColor(Color.red.opacity(0.8))
                .padding(8)
                .padding(.horizontal, 8)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.red.opacity(0.8), lineWidth: 3)
                )
                .onTapGesture { vm.resetRoomSpaceItem() }
            Text("保存")
                .padding(8)
                .padding(.horizontal, 8)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(lineWidth: 3)
                )
                .onTapGesture { isShowSaveAlert.toggle() }
        }
        .foregroundColor(Color(hex: "#9B7E6E"))
        .font(.headline)
    }
    
    private var roomSpaceItemSection: some View {
        ZStack {
            MerchantRoomSpaceItemSection(isShowTableInfo: $isShowTableInfo, selectItemType: .newAppend)
                .environmentObject(vm)
            MerchantRoomSpaceItemSection(isShowTableInfo: $isShowTableInfo, selectItemType: .old)
                .environmentObject(vm)
        }
        .frame(maxWidth: .infinity , maxHeight: .infinity)
        .background(Color.white)
        .background(
            Rectangle()
                .stroke(Color.black, lineWidth: 2)
        )
        .padding()
    }
    
    private var bottomItemSelectBar: some View {
        HStack {
            VStack {
                Image(systemName: "door.right.hand.closed")
                Text("門")
            }
            .onTapGesture {
                vm.newRoomItemsInfo.append(.init(uid: UUID().uuidString, item: .door, name: "", capacity: 0, offset: .zero, merchantUid: vm.merchantUid))
            }
            Spacer()
            VStack {
                Image(systemName: "table.furniture")
                Text("桌")
            }
            .onTapGesture {
                vm.newRoomItemsInfo.append(.init(uid: UUID().uuidString, item: .table, name: "", capacity: 0, offset: .zero, merchantUid: vm.merchantUid))
            }
            Spacer()
            VStack {
                Image(systemName: "line.diagonal")
                    .rotationEffect(Angle(degrees: 45))
                    .fontWeight(.heavy)
                Text("水平牆面")
            }
            .onTapGesture {
                vm.newRoomItemsInfo.append(.init(uid: UUID().uuidString, item: .horizontalWall, name: "", capacity: 0, offset: .zero, merchantUid: vm.merchantUid))
            }
            Spacer()
            VStack {
                Image(systemName: "line.diagonal")
                    .rotationEffect(Angle(degrees: -45))
                    .fontWeight(.heavy)
                Text("垂直牆面")
            }
            .onTapGesture {
                vm.newRoomItemsInfo.append(.init(uid: UUID().uuidString, item: .verticalWall, name: "", capacity: 0, offset: .zero, merchantUid: vm.merchantUid))
            }
        }
        .font(.title3)
        .padding(.horizontal)
    }
    
    private var tableInfoSection: some View {
        ZStack {
            Color.white.opacity(0.01)
                .onTapGesture { isShowTableInfo.toggle() }
            VStack {
                Text("桌子資訊")
                    .underline()
                HStack {
                    Text("桌名:")
                    TextField("桌名", text: $vm.selectedRoomItem.name)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .foregroundColor(Color(hex: "#F3EEEE"))
                        )
                }
                HStack {
                    Stepper(value: $vm.selectedRoomItem.capacity) {
                        Text("人數: \(vm.selectedRoomItem.capacity)")
                    }
                }
                .padding(.bottom, 8)
                HStack(spacing: 32) {
                    Text("取消")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "#715428"))
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color(hex: "#715428"), lineWidth: 2)
                        )
                        .onTapGesture { isShowTableInfo.toggle() }
                    Text("確定")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "#715428"))
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color(hex: "#715428"), lineWidth: 2)
                        )
                        .onTapGesture {
                            let res = vm.updateTableInfo()
                            if res { isShowTableInfo.toggle() }
                        }
                }
                .bold()
                
                Text(vm.updateTableErrorMessage)
                    .foregroundColor(Color.red)
                    .font(.headline)
            }
            .frame(width: 200, height: 180)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color(hex: "#FFFFFF"))
            )
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black, lineWidth: 2)
                    .shadow(radius: 3, x: 5, y: 5)
            )
        }
    }
    
    private var saveAlertSection: some View {
        VStack(spacing: 16) {
            Text("保存")
                .font(.title)
                .foregroundColor(Color(hex: "#567BB4"))
                .padding(8)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color(hex: "567BB4"), lineWidth: 3)
                )
                .onTapGesture {
                    Task {
                        isShowSaveAlert.toggle()
                        await vm.saveRoomSpaceItem()
                    }
                }
            HStack {
                Text("不儲存")
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color(hex: "#ACC1E1"), lineWidth: 3)
                    )
                    .onTapGesture { MerchantShareInfoManager.instance.settingModeSelect = [] }
                Spacer()
                Text("取消")
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color(hex: "#ACC1E1"), lineWidth: 3)
                    )
                    .onTapGesture { isShowSaveAlert.toggle() }
            }
            .font(.title3)
            .foregroundColor(Color(hex: "#ACC1E1"))
        }
        .bold()
        .frame(width: 220)
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.shadow(.drop(radius: 10)))
        )
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

struct MerchantRoomSpaceItemSection: View {
    
    @EnvironmentObject var vm: MerchantRoomSpaceViewModel
    @State var currentOffset: CGSize = .zero
    @Binding var isShowTableInfo: Bool
    
    var selectItemType: MerchantRoomSpaceViewModel.ItemFrom
    
    var body: some View {
        ForEach(selectItemType == .newAppend ? vm.newRoomItemsInfo : vm.oldRoomItemsInfo) { itemInfo in
            VStack {
                if itemInfo.item == .door {
                    Image(systemName: "door.right.hand.closed")
                } else if itemInfo.item == .table {
                    Image(systemName: "table.furniture")
                        .scaleEffect(vm.selectedRoomItem.uid == itemInfo.uid ? 1.2 : 1)
                        .onTapGesture {
                            vm.updateTableErrorMessage = ""
                            if isShowTableInfo { isShowTableInfo = vm.selectedRoomItem != itemInfo }
                            else { isShowTableInfo.toggle() }
                            vm.selectedItemFrom = selectItemType
                            vm.selectedRoomItem = itemInfo
                        }
                } else if itemInfo.item == .verticalWall {
                    Image(systemName: "line.diagonal")
                        .rotationEffect(Angle(degrees: 45))
                        .fontWeight(.heavy)
                } else if itemInfo.item == .horizontalWall {
                    Image(systemName: "line.diagonal")
                        .rotationEffect(Angle(degrees: -45))
                        .fontWeight(.heavy)
                }
            }
            .offset(x: itemInfo.offset.width + (vm.selectedRoomItem == itemInfo ? currentOffset.width : 0),
                    y: itemInfo.offset.height + (vm.selectedRoomItem ==  itemInfo ? currentOffset.height : 0))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isShowTableInfo = false
                        vm.selectedRoomItem = itemInfo
                        vm.selectedItemFrom = selectItemType
                        currentOffset = value.translation
                    }
                    .onEnded { value in
                        vm.updateItemOffset(offset: currentOffset)
                        currentOffset = .zero
                    }
            )
        }
        .font(.title)
    }
}
