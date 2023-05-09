//
//  CustomerHomeViewModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/5/5.
//

import Foundation
import Combine

class CustomerHomeViewModel: ObservableObject {
    
    // Published Variable
    @Published var status : Bool = false
    
    @Published var remainTimeCategorySelect: [CustomerShowTableInfoCategoryModel] = []
    @Published var selectedRemainTimeCategoryIdx: Int = 0
    
    @Published var tableInfo: CustomerTableInfoModel = .init(merchantUid: "")
    @Published var selectedMerchantUid: String = ""
    @Published var isMerchantNotStart: Bool = false
    
    @Published var isProcess: Bool = false
    @Published var isProcessError: Bool = false
    
    // Public Variable
    var loadingMessage: String = ""
    var errorMessage: String = ""
    var emptyTablePressedDownScreen: [Bool] = []
    
    // Private Variable
    private var cancellable = Set<AnyCancellable>()
    private var getTableInfoURL = "http://120.126.151.186/API/eating/food/customer"
    
    // Init Function
    init() {
        initRemainTimeCategorySelect()
        subscribeMerchantSelect()
    }
    
    // Public Function
    /// 點選剩餘等待時間觸發
    func selectRemainTimeCategory(selected: CustomerShowTableInfoCategoryModel) {
        guard !selected.isSelected else { return }
        let pastIdx = remainTimeCategorySelect.firstIndex { $0.isSelected }
        guard let pastIdx = pastIdx else { fatalError("不可能發生此錯誤") }
        remainTimeCategorySelect[pastIdx].isSelected = false
        let currentIdx = remainTimeCategorySelect.firstIndex { $0.id == selected.id }
        guard let currentIdx = currentIdx else { fatalError("不可能發生此錯誤") }
        remainTimeCategorySelect[currentIdx].isSelected = true
        selectedRemainTimeCategoryIdx = currentIdx
    }
    
    /// 計算空桌數量
    func countEmptyTable() -> Int {
        tableInfo.remainTime.reduce(0) { prefixSum, info in
            prefixSum + (info.remainTime == "0" ? 1 : 0)
        }
    }
    
    /// 顯示空桌的桌號，用字串的方式表示，中間用「，」隔開
    func fetchEmptyTableString() -> String {
        var emptyTableName: [String] = []
        emptyTablePressedDownScreen = []
        tableInfo.remainTime.forEach { info in
            emptyTablePressedDownScreen.append(info.remainTime == "0" ? true : false)
            guard info.remainTime == "0" else { return }
            emptyTableName.append(info.tableName)
        }
        let res = emptyTableName.joined(separator: ",")
        return res
    }
    
    /// 更新當前顯示中的店家資料
    func updateMerchantInfo() async {
        await MainActor.run {
            loadingMessage = "資料更新中"
            isProcess.toggle()
        }
        
        let queryTableInfo = CustomerTableInfoModel(merchantUid: selectedMerchantUid)
        let queryResult = await DatabaseManager.shared.uploadData(to: getTableInfoURL, data: queryTableInfo)
        var newTableInfo: CustomerTableInfoModel? = nil
        switch queryResult {
        case .success(let returnedResult):
            switch returnedResult.1 {
            case 200:
                newTableInfo = try? JSONDecoder().decode(CustomerTableInfoModel.self, from: returnedResult.0)
            case 403:
                let serverMessage = returnedResult.0.tranformToString()
                guard let serverMessage = serverMessage else {
                    await processErrorHandler(errorStatus: FetchMerchantTableInfoError.serverMessageError)
                    return
                }
                switch serverMessage {
                case "無此商家":
                    await processErrorHandler(errorStatus: FetchMerchantTableInfoError.neverFail, customMessage: serverMessage)
                    return
                case "此商家尚未準備好":
                    await MainActor.run {
                        tableInfo = .init(merchantUid: "")
                        isMerchantNotStart = true
                        isProcess.toggle()
                        loadingMessage = ""
                    }
                    return
                default:
                    await processErrorHandler(errorStatus: FetchMerchantTableInfoError.neverFail)
                    return
                }
            default:
                await processErrorHandler(errorStatus: FetchMerchantTableInfoError.internetError)
                return
            }
        case .failure(_):
            await processErrorHandler(errorStatus: FetchMerchantTableInfoError.internetError)
            return
        }
        
        guard let newTableInfo = newTableInfo else {
            await processErrorHandler(errorStatus: FetchMerchantTableInfoError.dataTransferError)
            return
        }
        await MainActor.run {
            isMerchantNotStart = false
            tableInfo = newTableInfo
        }
        
        var removeTablesName: [String] = []
        let stable: [String] = ["不顯示", "最短剩餘時間", "所有桌子資訊"]
        for info in remainTimeCategorySelect {
            if stable.contains(info.name) { continue }
            let idx = newTableInfo.remainTime.firstIndex { $0.tableName == info.name }
            if let _ = idx { continue }
            removeTablesName.append(info.name)
        }
        for removeTableName in removeTablesName {
            let idx = remainTimeCategorySelect.firstIndex { $0.name == removeTableName }
            guard let idx = idx else {
                await processErrorHandler(errorStatus: FetchMerchantTableInfoError.neverFail)
                return
            }
            await MainActor.run {
                let _ = remainTimeCategorySelect.remove(at: idx)
            }
        }
        for newInfo in newTableInfo.remainTime {
            let idx = remainTimeCategorySelect.firstIndex { $0.name == newInfo.tableName }
            if let _ = idx { continue }
            await MainActor.run {
                remainTimeCategorySelect.append(.init(name: newInfo.tableName, isSelected: false))
            }
        }
        
        await MainActor.run {
            isProcess.toggle()
            loadingMessage = ""
        }
    }
    
    // Private Function
    /// 獲取店家狀態資料的協助函數
    private func getTableInfoHelper() {
        Task { await getTableInfo() }
    }
    
    /// 獲取店家狀態資料
    private func getTableInfo() async {
        await MainActor.run {
            loadingMessage = "獲取店家資料中"
            isProcess.toggle()
        }
        
        let queryTableInfo = CustomerTableInfoModel(merchantUid: selectedMerchantUid)
        let queryResult = await DatabaseManager.shared.uploadData(to: getTableInfoURL, data: queryTableInfo)
        switch queryResult {
        case .success(let returnedQueryResult):
            switch returnedQueryResult.1 {
            case 200:
                let returnedTableInfo = try? JSONDecoder().decode(CustomerTableInfoModel.self, from: returnedQueryResult.0)
                guard let returnedTableInfo = returnedTableInfo else {
                    await processErrorHandler(errorStatus: FetchMerchantTableInfoError.dataTransferError)
                    return
                }
                await MainActor.run { tableInfo = returnedTableInfo }
            case 403:
                guard let serverMessage = returnedQueryResult.0.tranformToString() else {
                    await processErrorHandler(errorStatus: FetchMerchantTableInfoError.serverMessageError)
                    return
                }
                switch serverMessage {
                case "無此商家":
                    await processErrorHandler(errorStatus: FetchMerchantTableInfoError.neverFail)
                    return
                case "此商家尚未準備好":
                    await MainActor.run {
                        tableInfo = .init(merchantUid: "")
                        isMerchantNotStart = true
                        isProcess.toggle()
                        loadingMessage = ""
                    }
                    return
                default:
                    await processErrorHandler(errorStatus: FetchMerchantTableInfoError.internetError)
                    return
                }
            default:
                await processErrorHandler(errorStatus: FetchMerchantTableInfoError.internetError)
                return
            }
        case .failure(_):
            await processErrorHandler(errorStatus: FetchMerchantTableInfoError.internetError)
            return
        }
        
        await MainActor.run {
            initRemainTimeCategorySelect()
            for info in tableInfo.remainTime {
                remainTimeCategorySelect.append(.init(name: info.tableName, isSelected: false))
            }
        }
        
        await MainActor.run {
            isProcess.toggle()
            loadingMessage = ""
        }
    }
    
    // Subscribe Private Function
    /// 持續查看選中的店家
    private func subscribeMerchantSelect() {
        CustomerShareInfoManager.instance.$selectedMerchantUid
            .receive(on: DispatchQueue.main)
            .sink { [weak self] returnedSelectedMerchantUid in
                if returnedSelectedMerchantUid == "" { return }
                self?.selectedMerchantUid = returnedSelectedMerchantUid
                self?.getTableInfoHelper()
            }
            .store(in: &cancellable)
    }
}

// MARK: 初始化方面，全為Private Function
extension CustomerHomeViewModel {
    /// 初始化剩餘時間選項
    private func initRemainTimeCategorySelect() {
        remainTimeCategorySelect = []
        remainTimeCategorySelect.append(contentsOf: [
            .init(name: "不顯示", isSelected: true),
            .init(name: "最短剩餘時間", isSelected: false),
            .init(name: "所有桌子資訊", isSelected: false)
        ])
    }
}

extension CustomerHomeViewModel {
    /// 過程中發生錯誤
    private func processErrorHandler(errorStatus: any RawRepresentable, customMessage: String = "") async {
        await MainActor.run {
            errorMessage = customMessage.isEmpty ? errorStatus.rawValue as! String : customMessage
            isProcessError.toggle()
        }
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        await MainActor.run {
            isProcessError.toggle()
            isProcess.toggle()
            errorMessage = ""
            loadingMessage = ""
        }
    }
}

extension CustomerHomeViewModel {
    enum FetchMerchantTableInfoError: String, LocalizedError {
        case internetError = "網路發生錯誤，請確認網路狀態"
        case serverMessageError = "服務器回傳錯誤"
        case neverFail = "不可能發生錯誤"
        case dataTransferError = "資料轉換錯誤"
    }
}
