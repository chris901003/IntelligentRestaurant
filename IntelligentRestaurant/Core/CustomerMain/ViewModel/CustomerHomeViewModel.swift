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
    func getTableInfo(merchantUid: String) {
        let tableInfo = CustomerTableInfoModel(merchantUid: merchantUid)
        Task {
            let getResult = await DatabaseManager.shared.uploadData(to: getTableInfoURL, data: tableInfo, httpMethod: "POST")
            switch getResult {
            case .success(let returnedResult):
                switch returnedResult.1 {
                case 200:
                    let returnedData = returnedResult.0
                    guard let Info = try? JSONDecoder().decode(CustomerTableInfoModel.self, from: returnedData) else {
                        return
                    }
                    await MainActor.run {
                        CustomerShareInfoManager.instance.homeTable = Info
                        status = false
                    }
                    print("success!")
                    print(Info)
//                    print(ShareInfoManager.shared.homeTable.remainTime.indices)
                    break
                default:
                    print(returnedResult.1)
                    await MainActor.run {
                        status = true
                    }
                }
            case .failure(let errorStatus):
                print("fail")
                print(errorStatus.rawValue)
            }
        }
    }
    
    var sortedTable: [RemainTime] {
        CustomerShareInfoManager.instance.homeTable.remainTime.sorted(by: RemainTime.sortByTime)
    }
    
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
                    await MainActor.run { isMerchantNotStart = true }
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
                DispatchQueue.main.async {
                    self?.selectedMerchantUid = returnedSelectedMerchantUid
                    self?.getTableInfoHelper()
                }
            }
            .store(in: &cancellable)
    }
}

// MARK: 初始化方面，全為Private Function
extension CustomerHomeViewModel {
    /// 初始化剩餘時間選項
    private func initRemainTimeCategorySelect() {
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
