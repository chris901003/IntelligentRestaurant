//
//  MerchantRoomSpaceViewModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/3/14.
//

import Foundation
import SwiftUI
import Combine

class MerchantRoomSpaceViewModel: ObservableObject {
    
    // Published Variable
    @Published var oldRoomItemsInfo: [MerchantRoomSpaceItemModelExt] = []
    @Published var newRoomItemsInfo: [MerchantRoomSpaceItemModelExt] = []
    @Published var selectedItemFrom: ItemFrom = .newAppend
    @Published var selectedRoomItem: MerchantRoomSpaceItemModelExt = .init(info: .init(uid: "", item: .door, name: "", capacity: 1, offset: .zero, merchantUid: ""))
    
    @Published var isProcessing: Bool = false
    @Published var isProcessError: Bool = false
    @Published var processErrorMessage: String = ""
    @Published var updateTableErrorMessage: String = ""
    @Published var isShowSuccessSaveSpaceItem: Bool = false
    @Published var isChange: Bool = false
    
    // Public Variable
    let merchantUid: String = MerchantShareInfoManager.instance.merchantAccount.uid
    
    // Private Variable
    private var isChangeCancellable: AnyCancellable? = nil
    private var originalItemsInfo: [MerchantRoomSpaceItemModelExt] = []
    private let allTableInfoDatabaseUrl: String = "http://120.126.151.185/API/eating/table/all-table-info"
    private let roomTableDatabaseUrl: String = "http://120.126.151.185/API/eating/table"
    private let roomItemDatabaseUrl: String = "http://120.126.151.185/API/eating/item"
    private let allRoomItemDatabaseUrl: String = "http://120.126.151.185/API/eating/item/all-item-of-merchant"
    
    // Init Function
    init() {
        subscribeIsChange()
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
            newRoomItemsInfo[selectedIdx].info.offset.width += offset.width
            newRoomItemsInfo[selectedIdx].info.offset.height += offset.height
        case .old:
            let selectedIdx = oldRoomItemsInfo.firstIndex { itemInfo in
                itemInfo == selectedRoomItem
            }
            guard let selectedIdx = selectedIdx else { return }
            oldRoomItemsInfo[selectedIdx].info.offset.width += offset.width
            oldRoomItemsInfo[selectedIdx].info.offset.height += offset.height
        }
    }
    
    /// 更新桌子資訊
    func updateTableInfo() -> Bool {
        updateTableErrorMessage = ""
        if selectedRoomItem.info.name == "" {
            updateTableErrorMessage = "名稱不可為空"
            return false
        } else if selectedRoomItem.info.capacity <= 0 {
            updateTableErrorMessage = "人數不可小於1"
            return false
        }
        
        switch selectedItemFrom {
        case .newAppend:
            let selectedIdx = newRoomItemsInfo.firstIndex { itemInfo in
                itemInfo.info.uid == selectedRoomItem.info.uid
            }
            guard let selectedIdx = selectedIdx else {
                updateTableErrorMessage = "發生內部錯誤，請檢查"
                return false
            }
            newRoomItemsInfo[selectedIdx].info.name = selectedRoomItem.info.name
            newRoomItemsInfo[selectedIdx].info.capacity = selectedRoomItem.info.capacity
        case .old:
            let selectedIdx = oldRoomItemsInfo.firstIndex { itemInfo in
                itemInfo.info.uid == selectedRoomItem.info.uid
            }
            guard let selectedIdx = selectedIdx else {
                updateTableErrorMessage = "發生內部錯誤，請檢查"
                return false
            }
            oldRoomItemsInfo[selectedIdx].info.name = selectedRoomItem.info.name
            oldRoomItemsInfo[selectedIdx].info.capacity = selectedRoomItem.info.capacity
        }
        return true
    }
    
    /// 刪除桌子
    func deleteTable() {
        switch selectedItemFrom {
        case .newAppend:
            let selectedIdx = newRoomItemsInfo.firstIndex { itemInfo in
                itemInfo.info.uid == selectedRoomItem.info.uid
            }
            guard let selectedIdx = selectedIdx else {
                return
            }
            newRoomItemsInfo[selectedIdx].isDelete = true
        case .old:
            let selectedIdx = oldRoomItemsInfo.firstIndex { itemInfo in
                itemInfo.info.uid == selectedRoomItem.info.uid
            }
            guard let selectedIdx = selectedIdx else {
                return
            }
            oldRoomItemsInfo[selectedIdx].isDelete = true
        }
    }
    
    /// 將所有動作還原
    func resetRoomSpaceItem() {
        oldRoomItemsInfo = originalItemsInfo
        newRoomItemsInfo = []
    }
    
    /// 保存更新資料
    func saveRoomSpaceItem() async {
        if !isChange { return }
        await MainActor.run {
            isProcessing.toggle()
        }
        
        // 檢查桌子是否資料合理
        guard await checkRoomItemIsValid(roomItems: oldRoomItemsInfo),
              await checkRoomItemIsValid(roomItems: newRoomItemsInfo) else {
            await processErrorHandler(errorStatus: UpdateItemError.tableInfoError)
            return
        }
        guard await checkTableNameIsUnique(itemLists: [oldRoomItemsInfo, newRoomItemsInfo]) else {
            await processErrorHandler(errorStatus: UpdateItemError.tableNameIsNotUnique)
            return
        }
        
        // 將舊物件以及新物件回傳到後端資料庫中
        // 將舊桌子資料更新
        guard await updateOldTable() else {
            await processErrorHandler(errorStatus: UpdateItemError.updateOldTableError)
            return
        }
        
        // 將新桌子傳到後端
        guard await addNewTable() else {
            await processErrorHandler(errorStatus: UpdateItemError.uploadNewTableError)
            return
        }
        
        // 將就的其他物件更新
        guard await updateOtherItem() else {
            await processErrorHandler(errorStatus: UpdateItemError.updateOldOtherItemError)
            return
        }
        
        // 將新的其他物件上傳到後端
        guard await addNewOtherItem() else {
            await processErrorHandler(errorStatus: UpdateItemError.uploadOtherItemError)
            return
        }
        
        await MainActor.run {
            // 將新物件放到舊物件當中，不需重新從後端提取資料
            originalItemsInfo = oldRoomItemsInfo
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
    /// 在與資料處理時發生錯誤，到這裡進行顯示控制
    private func processErrorHandler(errorStatus: any RawRepresentable, customMessage: String = "") async {
        await MainActor.run {
            processErrorMessage = customMessage.isEmpty ? errorStatus.rawValue as! String : customMessage
            isProcessError.toggle()
        }
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        await MainActor.run {
            processErrorMessage = ""
            isProcessError.toggle()
            isProcessing = false
        }
    }
    
    // Subscribe Private Function
    /// 監看是否有對資料更新
    private func subscribeIsChange() {
        isChangeCancellable = $oldRoomItemsInfo
            .combineLatest($newRoomItemsInfo)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] returnedOldItems, returnedNewItems in
                guard let self = self else { return }
                self.isChange = returnedOldItems != self.originalItemsInfo || !returnedNewItems.isEmpty
            })
    }
}


// MARK: 資料初始化，從資料庫中拿取資料
extension MerchantRoomSpaceViewModel {
    
    // Private Function
    /// 初始時讀取資料
    private func initRoomSpaceData() async {
        await MainActor.run {
            isProcessing.toggle()
        }
        
        // 採用分段獲取，先獲取桌子的資訊，後面再獲取其他資料
        // 透過merchantUid獲取所有桌子資訊
        guard await getAllTableInfo() else {
            await processErrorHandler(errorStatus: InitError.getAllTableInfoError)
            return
        }
        // 透過merchantUid獲取其他物件資料
        // TODO: 等待後端接口後補上獲取其他物件
        guard await getAllOtherItemInfo() else {
            await processErrorHandler(errorStatus: InitError.getAllOtherInfoError)
            return
        }
        
        await MainActor.run {
            isProcessing.toggle()
        }
    }
    
    /// 獲取商家所有桌子資訊
    private func getAllTableInfo() async -> Bool {
        let queryModel = AllTableInfoQueryModel(merchantUid: merchantUid)
        let queryResults = await DatabaseManager.shared.uploadData(to: allTableInfoDatabaseUrl, data: queryModel)
        switch queryResults {
        case .success(let returnedQuery):
            switch returnedQuery.1 {
            case 200:
                guard let fetchTableItemResult = try? JSONDecoder().decode(AllTableInfoReturnedModel.self, from: returnedQuery.0) else {
                    await processErrorHandler(errorStatus: InitError.allTableInfoTransferError)
                    return false
                }
                await MainActor.run {
                    for fetchTableItem in fetchTableItemResult.results {
                        oldRoomItemsInfo.append(MerchantRoomSpaceItemModelExt(info: fetchTableItem))
                    }
                    originalItemsInfo = oldRoomItemsInfo
                }
            default:
                let message = returnedQuery.0.tranformToString()
                await processErrorHandler(errorStatus: InitError.getAllTableInfoError, customMessage: message ?? "")
                return false
            }
        case .failure(_):
            return false
        }
        return true
    }
    
    /// 獲取其他物件資料
    private func getAllOtherItemInfo() async -> Bool {
        let allItemQueryModel = AllTableInfoQueryModel(merchantUid: merchantUid)
        let fetchResult = await DatabaseManager.shared.uploadData(to: allRoomItemDatabaseUrl, data: allItemQueryModel)
        switch fetchResult {
        case .success(let returnedResult):
            switch returnedResult.1 {
            case 200:
                guard let allRoomItems = try? JSONDecoder().decode([MerchantRoomSpaceItemModel].self, from: returnedResult.0) else {
                    await processErrorHandler(errorStatus: InitError.otherItemTransferError)
                    return false
                }
                // 目前似乎在全空的狀態下會發生錯誤，以及桌子以外的物件無法刪除
                await MainActor.run {
                    for roomItem in allRoomItems {
                        oldRoomItemsInfo.append(.init(info: roomItem))
                    }
                    originalItemsInfo = oldRoomItemsInfo
                }
            case 201:
                break
            default:
                let serverErrorMessage = returnedResult.0.tranformToString() ?? "請檢查服務器回傳資訊"
                await processErrorHandler(errorStatus: InitError.getAllOtherInfoError, customMessage: serverErrorMessage)
                return false
            }
        case .failure(_):
            await processErrorHandler(errorStatus: InitError.getAllOtherInfoError)
            return false
        }
        return true
    }
}

// MARK: 更新資料
extension MerchantRoomSpaceViewModel {
    /// 檢查桌子資料內容是否皆正確
    private func checkRoomItemIsValid(roomItems: [MerchantRoomSpaceItemModelExt]) async -> Bool {
        for roomItem in roomItems {
            if roomItem.info.item != .table { continue }
            guard !roomItem.info.name.isEmpty else { return false }
            guard roomItem.info.capacity > 0 else { return false }
        }
        return true
    }
    
    /// 檢查每張桌子的名稱是否都不相同
    private func checkTableNameIsUnique(itemLists: [[MerchantRoomSpaceItemModelExt]]) async -> Bool {
        var tableCnt: Int = 0
        var record: Set<String> = Set<String>()
        for itemList in itemLists {
            for item in itemList {
                if item.info.item != .table { continue }
                record.insert(item.info.name)
                tableCnt += 1
            }
        }
        return tableCnt == record.count
    }
    
    /// 新桌子資料回傳到後端
    private func addNewTable() async -> Bool {
        for newItem in newRoomItemsInfo {
            guard newItem.info.item == .table, !newItem.isDelete else { continue }
            let uploadResult = await DatabaseManager.shared.uploadData(to: roomTableDatabaseUrl, data: newItem.info)
            switch uploadResult {
            case .success(let result):
                guard let tableUid = result.0.tranformToString() else {
                    await processErrorHandler(errorStatus: UpdateItemError.returnedTableUidError)
                    return false
                }
                let tableInfo = MerchantRoomSpaceItemModelExt(info: .init(uid: tableUid, item: .table, name: newItem.info.name, capacity: newItem.info.capacity, offset: newItem.info.offset, merchantUid: newItem.info.merchantUid))
                await MainActor.run {
                    oldRoomItemsInfo.append(tableInfo)
                }
            case .failure(_):
                await processErrorHandler(errorStatus: UpdateItemError.tableUpdateError)
                return false
            }
        }
        return true
    }
    
    /// 更新舊的桌子資料
    private func updateOldTable() async -> Bool {
        for idx in oldRoomItemsInfo.indices {
            guard oldRoomItemsInfo[idx].info.item == .table else { continue }
            if(originalItemsInfo[idx] == oldRoomItemsInfo[idx]) { continue }
            if oldRoomItemsInfo[idx].isDelete {
                let deleteResult = await DatabaseManager.shared.uploadData(to: roomTableDatabaseUrl, data: oldRoomItemsInfo[idx].info, httpMethod: "Delete")
                switch deleteResult {
                case .success(_):
                    break
                case .failure(_):
                    return false
                }
            } else {
                let updateResult = await DatabaseManager.shared.uploadData(to: roomTableDatabaseUrl, data: oldRoomItemsInfo[idx].info, httpMethod: "PUT")
                switch updateResult {
                case .success(_):
                    break
                case .failure(_):
                    return false
                }
            }
        }
        return true
    }
    
    /// 將新的其他資料上傳
    private func addNewOtherItem() async -> Bool {
        for newItem in newRoomItemsInfo {
            guard newItem.info.item != .table else { continue }
            // 上傳其他物件
            let uploadResult = await DatabaseManager.shared.uploadData(to: roomItemDatabaseUrl, data: newItem.info)
            switch uploadResult {
            case .success(let returnedResult):
                guard let itemUid = returnedResult.0.tranformToString() else {
                    await processErrorHandler(errorStatus: UpdateItemError.uploadOtherItemReturnUidError)
                    return false
                }
                let itemInfo = MerchantRoomSpaceItemModelExt(info: .init(uid: itemUid, item: newItem.info.item, name: newItem.info.name, capacity: newItem.info.capacity, offset: newItem.info.offset, merchantUid: newItem.info.merchantUid))
                await MainActor.run {
                    oldRoomItemsInfo.append(itemInfo)
                }
            case .failure(_):
                return false
            }
        }
        return true
    }
    
    /// 更新舊的其他物件資料
    private func updateOtherItem() async -> Bool {
        for idx in originalItemsInfo.indices {
            guard originalItemsInfo[idx].info.item != .table,
                  originalItemsInfo[idx] != oldRoomItemsInfo[idx] else { continue }
            if oldRoomItemsInfo[idx].isDelete {
                let deleteResult = await DatabaseManager.shared.uploadData(to: roomItemDatabaseUrl, data: oldRoomItemsInfo[idx].info, httpMethod: "Delete")
                switch deleteResult {
                case .success(_):
                    break
                case .failure(_):
                    return false
                }
            } else {
                let updateResult = await DatabaseManager.shared.uploadData(to: roomItemDatabaseUrl, data: oldRoomItemsInfo[idx].info, httpMethod: "PUT")
                switch updateResult {
                case .success(_):
                    break
                case .failure(_):
                    return false
                }
            }
        }
        return true
    }
}

extension MerchantRoomSpaceViewModel {
    
    enum ItemFrom {
        case newAppend
        case old
    }
    
    enum InitError: String, LocalizedError {
        case getAllTableInfoError = "桌子資料初始化失敗，請確認網路連線狀態"
        case allTableInfoTransferError = "所有桌子資料轉換錯誤"
        case getAllOtherInfoError = "獲取剩餘其他物件失敗，請確認網路連線狀態"
        case otherItemTransferError = "其他物件資訊轉換錯誤"
    }
    
    enum UpdateItemError: String, LocalizedError {
        case tableInfoError = "每張桌子需要名稱，並且人數至少大於1"
        case tableNameIsNotUnique = "桌子名稱不可重複"
        case tableUpdateError = "桌子資料更新失敗，請確認網路狀態"
        case uploadNewTableError = "上傳新桌子失敗，請確認網路狀態"
        case updateOldTableError = "更新舊桌子失敗，請確認網路狀態"
        case returnedTableUidError = "資料庫回傳桌子Uid錯誤"
        case uploadOtherItemError = "上傳其他物件失敗，請確認網路連線狀態"
        case uploadOtherItemReturnUidError = "回傳物件uid資料錯誤"
        case updateOldOtherItemError = "更新舊物件失敗，請確認網路連線"
    }
}
