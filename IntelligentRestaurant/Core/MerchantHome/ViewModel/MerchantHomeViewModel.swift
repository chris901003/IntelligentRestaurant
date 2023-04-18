//
//  MerchantHomeViewModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/3/11.
//

import Foundation
import Combine

class MerchantHomeViewModel: ObservableObject {
    
    // Published Variable
    @Published var tableChoiceList: [String] = []
    @Published var selectedTableIdx: String = "0"
    @Published var tableFoodChoiceList: [String] = []
    @Published var selectedFoodIdx: String = "-1"
    @Published var tableInfoShowIdx: [String] = []
    @Published var tablesFoodsInfo: [String: [String: FoodStatusInfoModel]] = [:]
    
    @Published var isProgressing: Bool = false
    @Published var isProgressError: Bool = false
    @Published var progressErrorMessage: String = ""
    @Published var isShowUsingMesssage: Bool = false
    @Published var isAutoRefresh: Bool = true
    
    // Private Variable
    private var cancellable = Set<AnyCancellable>()
    private var refreshTimer: Timer? = nil
    private let allTableWithFoodInfoDatabaseUrl = "http://120.126.151.186/API/eating/table/all-table-with-food-info"
    
    init() {
        // Need
        subscribeTableSelect()
        Task { await getInitialData() }
    }
    
    // Public Function
    func startRefreshTimer() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.isProgressing || !self.isAutoRefresh { return }
            Task { await self.refreshData() }
        }
    }
    
    func endRefreshTimer() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    /// 強制更新狀態
    func forceUpdateData() {
        if isProgressing { return }
        Task { await refreshData() }
    }
    
    // Private Function
    /// 初始化時將資料全部讀入
    private func getInitialData() async {
        await MainActor.run {
            isProgressing.toggle()
        }
        
        // 透過MerchantUid獲取所有桌子以及當中的食物資訊
        guard await fetchAllTableWithFoodInfo() else {
            await processErrorHandler(errorStatus: InitError.errorLoadInfo)
            return
        }
        
        await MainActor.run {
            isProgressing.toggle()
        }
    }
    
    /// 更新資料
    private func refreshData() async {
        await MainActor.run {
            isProgressing.toggle()
        }
        
        guard await fetchAllTableWithFoodInfo() else {
            await processErrorHandler(errorStatus: RefreshError.refetchDataError)
            return
        }
        
        await MainActor.run {
            isProgressing.toggle()
        }
    }
    
    /// 獲取店家所有桌子以及當中所有食物資訊
    private func fetchAllTableWithFoodInfo() async -> Bool {
        let queryAllTableWithFoodInfoModel = AllTableInfoQueryModel(merchantUid: MerchantShareInfoManager.instance.merchantAccount.uid)
        // 獲取資料並且放上去，最後處理更新部分
        let queryResult = await DatabaseManager.shared.uploadData(to: allTableWithFoodInfoDatabaseUrl, data: queryAllTableWithFoodInfoModel)
        switch queryResult {
        case .success(let returnedResult):
            switch returnedResult.1 {
            case 200:
                guard let allTableWithFoodInfo = try? JSONDecoder().decode(AllTableWithFoodInfoModel.self, from: returnedResult.0) else {
                    await processErrorHandler(errorStatus: UniversalError.fetchEmptyData)
                    await MainActor.run {
                        tablesFoodsInfo = [:]
                    }
                    return false
                }
                await MainActor.run {
                    var oldTableName = Set<String>()
                    for tableName in tablesFoodsInfo.keys {
                        oldTableName.insert(tableName)
                    }
                    for (tableName, foodsInfo) in allTableWithFoodInfo.results {
                        oldTableName.remove(tableName)
                        if !tableChoiceList.contains(tableName) {
                            tableChoiceList.append(tableName)
                        }
                        if !tableInfoShowIdx.contains(tableName) {
                            tableInfoShowIdx.append(tableName)
                        }
                        if tablesFoodsInfo[tableName] == nil { tablesFoodsInfo[tableName] = [:] }
                        var oldFoodUid = Set<String>()
                        for foodUid in tablesFoodsInfo[tableName]!.keys { oldFoodUid.insert(foodUid) }
                        for foodInfo in foodsInfo {
                            tablesFoodsInfo[tableName]![foodInfo.trackId] = foodInfo
                            oldFoodUid.remove(foodInfo.trackId)
                        }
                        for foodUid in oldFoodUid {
                            tablesFoodsInfo[tableName]?.removeValue(forKey: foodUid)
                        }
                    }
                    for tableName in oldTableName {
                        tablesFoodsInfo.removeValue(forKey: tableName)
                    }
                }
            default:
                let message = returnedResult.0.tranformToString() ?? "Status Code: \(returnedResult.1)"
                await processErrorHandler(errorStatus: UniversalError.serverStatusCodeError, customMessage: message)
                return false
            }
        case .failure(_):
            await processErrorHandler(errorStatus: UniversalError.fetchAllTableWithFoodInfoError)
            return false
        }
        return true
    }
    
    /// 處理過程中錯誤
    private func processErrorHandler(errorStatus: any RawRepresentable, customMessage: String = "") async {
        await MainActor.run {
            progressErrorMessage = customMessage.isEmpty ? errorStatus.rawValue as! String : customMessage
            isProgressError.toggle()
        }
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        await MainActor.run {
            isProgressError.toggle()
            isProgressing = false
            progressErrorMessage = ""
        }
    }
    
    // Subscribe Private Function
    /// 追蹤目前桌號的選擇
    private func subscribeTableSelect() {
        $selectedTableIdx
            .receive(on: DispatchQueue.main)
            .sink { [weak self] returnedSelectTableIdx in
                self?.selectedFoodIdx = "-1"
                self?.tableFoodChoiceList = []
                self?.tableInfoShowIdx = []
                if returnedSelectTableIdx == "-1" { return }
                if returnedSelectTableIdx == "0" { self?.tableInfoShowIdx = (self?.tablesFoodsInfo.keys.sorted())! }
                else { self?.tableInfoShowIdx = [returnedSelectTableIdx] }
                guard let filterShowFoodIdx = self?.tablesFoodsInfo[returnedSelectTableIdx]?.keys.sorted() else { return }
                self?.tableFoodChoiceList = filterShowFoodIdx
            }
            .store(in: &cancellable)
    }
}

extension MerchantHomeViewModel {
    
    enum InitError: String, LocalizedError {
        case errorLoadInfo = "獲取資料失敗，請確認網路狀態"
    }
    
    enum RefreshError: String, LocalizedError {
        case refetchDataError = "自動更新失敗，請確認網路狀態"
    }
    
    enum UniversalError: String, LocalizedError {
        case fetchAllTableWithFoodInfoError = "獲取所有桌子以及食物資料錯誤，請檢查網路"
        case serverStatusCodeError = "Status Code不為200"
        case fetchEmptyData = "目前沒有任何攝影機開啟"
        case fetchAllTableWithFoodInfoTransformError = "資料轉換錯誤"
    }
}
