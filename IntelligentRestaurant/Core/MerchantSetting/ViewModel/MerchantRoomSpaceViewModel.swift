//
//  MerchantRoomSpaceViewModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/3/14.
//

import Foundation
import SwiftUI

class MerchantRoomSpaceViewModel: ObservableObject {
    
    // Published Variable
    @Published var oldRoomItemsInfo: [MerchantRoomSpaceItemModel] = []
    @Published var newRoomItemsInfo: [MerchantRoomSpaceItemModel] = []
    @Published var selectedItemFrom: ItemFrom = .newAppend
    @Published var selectedRoomItem: MerchantRoomSpaceItemModel = .init(uid: "", item: .door, name: "", capacity: 1, offset: .zero, merchantUid: "")
    
    @Published var isProcessing: Bool = false
    @Published var isProcessError: Bool = false
    @Published var processErrorMessage: String = ""
    @Published var updateTableErrorMessage: String = ""
    @Published var isShowSuccessSaveSpaceItem: Bool = false
    
    // Public Variable
    let merchantUid: String = MerchantShareInfoManager.instance.merchantAccount.uid
    
    // Private Variable
    private var originalItemsInfo: [MerchantRoomSpaceItemModel] = []
    private let tableItemDatabaseUrl: String = "http://120.126.151.186/API/eating/table"
    
    // Init Function
    init() {
        Task { await initRoomSpaceData() }
    }
    
    // Public Function
    func updateItemOffset(offset: CGSize) {
        switch selectedItemFrom {
        case .newAppend:
            let selectedIdx = newRoomItemsInfo.firstIndex { itemInfo in
                itemInfo == selectedRoomItem
            }
            guard let selectedIdx = selectedIdx else { return }
            newRoomItemsInfo[selectedIdx].offset.width += offset.width
            newRoomItemsInfo[selectedIdx].offset.height += offset.height
        case .old:
            let selectedIdx = oldRoomItemsInfo.firstIndex { itemInfo in
                itemInfo == selectedRoomItem
            }
            guard let selectedIdx = selectedIdx else { return }
            oldRoomItemsInfo[selectedIdx].offset.width += offset.width
            oldRoomItemsInfo[selectedIdx].offset.height += offset.height
        }
    }
    
    /// 更新桌子資訊
    func updateTableInfo() -> Bool {
        updateTableErrorMessage = ""
        if selectedRoomItem.name == "" {
            updateTableErrorMessage = "名稱不可為空"
            return false
        } else if selectedRoomItem.capacity <= 0 {
            updateTableErrorMessage = "人數不可小於1"
            return false
        }
        
        switch selectedItemFrom {
        case .newAppend:
            let selectedIdx = newRoomItemsInfo.firstIndex { itemInfo in
                itemInfo.uid == selectedRoomItem.uid
            }
            guard let selectedIdx = selectedIdx else {
                updateTableErrorMessage = "發生內部錯誤，請檢查"
                return false
            }
            newRoomItemsInfo[selectedIdx].name = selectedRoomItem.name
            newRoomItemsInfo[selectedIdx].capacity = selectedRoomItem.capacity
        case .old:
            let selectedIdx = oldRoomItemsInfo.firstIndex { itemInfo in
                itemInfo.uid == selectedRoomItem.uid
            }
            guard let selectedIdx = selectedIdx else {
                updateTableErrorMessage = "發生內部錯誤，請檢查"
                return false
            }
            oldRoomItemsInfo[selectedIdx].name = selectedRoomItem.name
            oldRoomItemsInfo[selectedIdx].capacity = selectedRoomItem.capacity
        }
        return true
    }
    
    /// 將所有動作還原
    func resetRoomSpaceItem() {
        oldRoomItemsInfo = originalItemsInfo
        newRoomItemsInfo = []
    }
    
    /// 保存更新資料
    func saveRoomSpaceItem() async {
        await MainActor.run {
            isProcessing.toggle()
        }
        
        // 檢查桌子是否資料合理
        for itemInfo in oldRoomItemsInfo {
            guard itemInfo.item == .table else { continue }
            if itemInfo.name == "" {
                await progressErrorHandler(errorStatus: .tableNoName)
                return
            }
            if itemInfo.capacity <= 0 {
                await progressErrorHandler(errorStatus: .tableCapacity)
                return
            }
        }
        for itemInfo in newRoomItemsInfo {
            if itemInfo.name == "" {
                await progressErrorHandler(errorStatus: .tableNoName)
                return
            }
            if itemInfo.capacity <= 0 {
                await progressErrorHandler(errorStatus: .tableCapacity)
                return
            }
        }
        
        // 將舊物件以及新物件回傳到後端資料庫中
        
        // 將新桌子傳到後端
        let addTableResult = await addNewTable()
        
        // 目前只有新增桌子以及刪除的後端，連查詢都沒有
        
        await MainActor.run {
            // 將新物件放到舊物件當中，不需重新從後端提取資料
            oldRoomItemsInfo.append(contentsOf: newRoomItemsInfo)
            newRoomItemsInfo = []
        }
        
        await MainActor.run {
            isProcessing.toggle()
            isShowSuccessSaveSpaceItem.toggle()
        }
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        await MainActor.run {
            isShowSuccessSaveSpaceItem.toggle()
        }
    }
    
    // Private Function
    /// 初始時讀取資料
    private func initRoomSpaceData() async {
        await MainActor.run {
            isProcessing.toggle()
        }
        
        // 所有物品的uid
        let _ = MerchantShareInfoManager.instance.merchantAccount.roomSpaceItemUid
        // 遍歷所有物品並且將資料加到oldRoomItemsInfo當中即可
        
        await MainActor.run {
            isProcessing.toggle()
        }
    }
    
    /// 新桌子資料回傳到後端
    private func addNewTable() async -> Bool {
        for newItem in newRoomItemsInfo {
            guard newItem.item == .table else { continue }
            let uploadResult = await DatabaseManager.shared.uploadData(to: tableItemDatabaseUrl, data: newItem)
            switch uploadResult {
            case .success(_):
                continue
            case .failure(_):
                await progressErrorHandler(errorStatus: ProgressErrorType.tableUpdateError)
                return false
            }
        }
        return true
    }
    
    /// 在與資料處理時發生錯誤，到這裡進行顯示控制
    private func progressErrorHandler(errorStatus: ProgressErrorType) async {
        await MainActor.run {
            processErrorMessage = errorStatus.rawValue
            isProcessError.toggle()
        }
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        await MainActor.run {
            processErrorMessage = ""
            isProcessError.toggle()
            isProcessing.toggle()
        }
    }
}

extension MerchantRoomSpaceViewModel {
    
    enum ItemFrom {
        case newAppend
        case old
    }
    
    enum ProgressErrorType: String {
        case tableNoName = "每張桌子需要有個別名稱"
        case tableCapacity = "桌子人數不可少於一人"
        case tableUpdateError = "桌子資料更新失敗，請確認網路狀態"
    }
}
