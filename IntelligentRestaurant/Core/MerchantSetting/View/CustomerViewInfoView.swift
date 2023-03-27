//
//  CustomerViewInfoView.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/3/16.
//

import Foundation
import SwiftUI

struct CustomerViewInfoView: View {
    
    @StateObject var vm: CustomerViewInfoViewModel = CustomerViewInfoViewModel()
    @State var filterSelectSize: CGSize = .zero
    @State var isShowInfoMessage: Bool = false
    @State var isShowSelectFilter: Bool = false
    @State var isShowAllClearTable: Bool = false
    
    var body: some View {
        ZStack {
            Color.theme.loginBackground
            
            VStack {
                MerchantTopNavigationBarView(title: "使用端設定", titleImage: "house")
                topBarButtonSection
                centerSection
                customerViewInfoSelectSection
                Spacer()
            }
            .padding(.top, 72)
        }
        .navigationBarBackButtonHidden(true)
        .overlay {
            if vm.isShowError {
                smallAlert
            }
            if isShowInfoMessage {
                introSection
            }
            if vm.isProcessing {
                LoadingView(waitingInfo: "請稍候", isProgressView: true)
            }
            if vm.isProcessError {
                ErrorMessageShowView(message: vm.processErrorMessage)
            }
        }
    }
    
    private var topBarButtonSection: some View {
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
            Text("復原")
                .foregroundColor(Color.red.opacity(0.75))
                .padding(8)
                .padding(.horizontal, 8)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.red.opacity(0.75), lineWidth: 3)
                )
                .onTapGesture { vm.resetCustomViewInfo() }
            Text("保存")
                .padding(8)
                .padding(.horizontal, 8)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(lineWidth: 3)
                )
                .onTapGesture { Task { await vm.saveCustomViewInfo() } }
        }
        .font(.headline)
        .foregroundColor(Color(hex: "#9B7E6E"))
        .padding(8)
        .padding(.horizontal, 8)
    }
    
    private var introShowButton: some View {
        VStack {
            HStack {
                Spacer()
                Image(systemName: "exclamationmark.circle")
                    .font(.title)
                    .bold()
                    .background(Color.white)
                    .clipShape(Circle())
                    .offset(x: 15, y: -15)
            }
            Spacer()
        }
        .onTapGesture { isShowInfoMessage.toggle() }
    }
    
    private var introSection: some View {
        ZStack {
            Color.white.opacity(0.01)
                .background(TransparentBackground())
                .onTapGesture { isShowInfoMessage.toggle() }
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "xmark")
                        .onTapGesture { isShowInfoMessage.toggle() }
                }
                Text("使用端設定")
                    .padding(.bottom)
                Text("透過勾選下方選項調整顯示資訊")
                Text("方匡內將會是在客人顯示的資訊")
            }
            .font(.headline)
            .padding(8)
            .padding(.bottom)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color.white.shadow(.drop(radius: 10)))
            )
            .padding()
        }
    }
    
    private var centerSection: some View {
        ZStack {
            introShowButton
            VStack(spacing: 0) {
                filterSelectSection
                ZStack {
                    VStack {
                        if vm.merchantCustomViewInfo.infoShowFilters.contains("剩餘等待時間") {
                            tablesInfoSection
                        }
                        if vm.merchantCustomViewInfo.infoShowFilters.contains("自動顯示空桌") {
                            clearTableSection
                        }
                    }
                    if isShowSelectFilter {
                        selectListSection
                    }
                    if isShowAllClearTable {
                        clearTableDetail
                    }
                }
                Spacer()
            }
        }
        .font(.headline)
        .frame(maxWidth: .infinity, maxHeight: 350)
        .background(Color(hex: "#F2F1E1").cornerRadius(5))
        .background(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color(hex: "#C3B7A9"), lineWidth: 5)
        )
        .padding(10)
        .background(Color.white.cornerRadius(10))
        .padding()
    }
    
    private var filterSelectSection: some View {
        VStack(spacing: 0) {
            Text(MerchantShareInfoManager.instance.merchantAccount.name)
                .font(.title3)
                .bold()
                .padding()
            HStack(alignment: .top) {
                Text("剩餘等待時間")
                    .padding(8)
                    .background(Color.black.opacity(0.1))
                    .saveSize(in: $filterSelectSize)
                HStack {
                    Text(vm.selectModeMessage)
                        .frame(maxWidth: .infinity)
                    Image(systemName: "chevron.backward")
                        .rotationEffect(Angle(degrees: isShowSelectFilter ? 180 : 0))
                }
                .padding(8)
                .background(Color(hex: "#D9D9D9").cornerRadius(5))
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.black, lineWidth: 2)
                )
                .onTapGesture { withAnimation { isShowSelectFilter.toggle() } }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private var selectListSection: some View {
        VStack {
            ScrollView {
                ForEach(vm.selectModeList, id: \.self) { selectInfo in
                    HStack {
                        Text(selectInfo)
                        Image(systemName: "checkmark")
                            .opacity(vm.selectFilter.contains(selectInfo) ? 1 : 0)
                        Spacer()
                    }
                    .onTapGesture {
                        let lastMode = vm.selectMode
                        vm.selectMode = .notCertainTable
                        vm.tapFilter(lastMode: lastMode, filter: selectInfo)
                        vm.selectModeMessage = selectInfo
                        withAnimation { isShowSelectFilter.toggle() }
                    }
                    .padding(.bottom, 16)
                }
                ForEach(vm.selectTableList, id: \.self) { selectInfo in
                    HStack {
                        Text("\(selectInfo)桌")
                        Image(systemName: "checkmark")
                            .opacity(vm.selectFilter.contains(selectInfo) ? 1 : 0)
                        Spacer()
                    }
                    .onTapGesture {
                        let lastMode = vm.selectMode
                        vm.selectMode = .certainTable
                        vm.tapFilter(lastMode: lastMode, filter: selectInfo)
                    }
                    .padding(.bottom, 16)
                }
            }
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color.white.shadow(.drop(radius: 10)))
        )
        .padding(.horizontal)
        .offset(x: filterSelectSize.width)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
        .transition(AnyTransition.move(edge: .trailing))
    }
    
    private var tablesInfoSection: some View {
        ScrollView {
            VStack {
                ForEach(vm.tablesInfosShow.keys.sorted(), id: \.self) { tableName in
                    HStack {
                        Text("\(tableName)桌")
                            .padding(8)
                            .padding(.horizontal)
                            .background(Color.white)
                            .background(
                                Rectangle()
                                    .stroke(Color.black, lineWidth: 3)
                            )
                        Image(systemName: "arrow.forward")
                        Text(vm.tablesInfosShow[tableName] ?? "查無資料")
                            .padding(8)
                            .frame(maxWidth: 150)
                            .background(Color.white)
                            .background(
                                Rectangle()
                                    .stroke(Color.black, lineWidth: 3)
                            )
                    }
                    .padding(8)
                }
                Spacer()
            }
        }
        .padding(8)
        .background(
            Rectangle()
                .foregroundColor(Color(hex: "#C3B7A9").opacity(vm.tablesInfosShow.keys.count > 0 ? 0.3 : 0))
        )
        .padding(.horizontal, 8)
    }
    
    private var customerViewInfoSelectSection: some View {
        ScrollView {
            VStack {
                ForEach(vm.merchantCustomViewInfoList, id: \.self) { info in
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: vm.merchantCustomViewInfo.infoShowFilters.contains(info) ? "checkmark.square" : "square")
                            Text(info)
                        }
                        .padding(.horizontal)
                        .onTapGesture { vm.updateCustomerViewInfo(selectedName: info) }
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundColor(Color(hex: "#FFF3B2").opacity(0.65))
                            .frame(width: 300, height: 3)
                    }
                }
            }
        }
        .frame(height: 150)
        .font(.title2)
        .bold()
    }
    
    private var smallAlert: some View {
        VStack {
            HStack {
                Spacer()
                Image(systemName: "xmark")
                    .onTapGesture { vm.isShowError.toggle() }
            }
            Text("至少勾選一項")
        }
        .font(.headline)
        .padding()
        .background(
            Rectangle()
                .foregroundColor(Color(hex: "#F2C8C8"))
        )
        .background(
            Rectangle()
                .stroke(Color.black, lineWidth: 3)
        )
        .frame(width: 200)
    }
    
    private var clearTableSection: some View {
        HStack(spacing: 16) {
            Text("空桌狀態: \(vm.clearTableName.count)")
            HStack {
                Text("桌名:")
                ForEach(vm.clearTableName, id: \.self) { tableName in
                    Text("\(tableName), ")
                }
            }
            .padding(8)
            .frame(width: 200, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .foregroundColor(Color(hex: "#D9D9D9"))
            )
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.black, lineWidth: 2)
            )
            .onTapGesture { isShowAllClearTable.toggle() }
        }
    }
    
    private var clearTableDetail: some View {
        VStack {
            HStack {
                Spacer()
                Image(systemName: "xmark")
                    .onTapGesture { isShowAllClearTable.toggle() }
            }
            Text("目前有\(vm.clearTableName.count)張空桌")
            ScrollView {
                ForEach(vm.clearTableName, id: \.self) { tableName in
                    Text("\(tableName)桌")
                }
            }
        }
        .frame(width: 180)
        .font(.headline)
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color.white.shadow(.drop(radius: 10)))
        )
    }
}

struct SizeCalculator: ViewModifier {
    
    @Binding var size: CGSize
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear.onAppear {
                        size = proxy.size
                    }
                }
            )
    }
}

extension View {
    func saveSize(in size: Binding<CGSize>) -> some View {
        modifier(SizeCalculator(size: size))
    }
}
