//
//  CustomerViewInfoViewModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/3/16.
//

import Foundation
import Combine

class CustomerViewInfoViewModel: ObservableObject {
    
    // Published Variable
    @Published var selectModeMessage: String = "-"
    @Published var selectModeList: [String] = ["最短剩餘時間", "所有桌子資訊"]
    @Published var selectTableList: [String] = []
    @Published var selectMode: SelectFilterMode = .notCertainTable
    @Published var selectFilter: [String] = ["-"]
    // 最終顯示在畫面上的資料[桌子名稱: 狀態]
    @Published var tablesInfosShow: [String: String] = [:]
    @Published var clearTableName: [String] = []
    @Published var merchantCustomViewInfoList: [String] = ["剩餘等待時間", "自動顯示空桌"]
    @Published var merchantCustomViewInfo = MerchantCustomViewInfoModel(uid: "")
    
    @Published var isProcessing: Bool = false
    @Published var isProcessError: Bool = false
    @Published var processErrorMessage: String = ""
    @Published var isShowError: Bool = false
    
    // Private Variable
    /// key = 每張桌子的名稱, value = 一張桌子中的食物資訊
    private var allTablesInfos: [String: [FoodStatusInfoModel]] = [:]
    private var originalCustomViewInfo = MerchantCustomViewInfoModel(uid: "")
    private var clearTableNameCancellable: AnyCancellable? = nil
    
    // Init Function
    init() {
        subscribeClearTableName()
        Task { await initData() }
    }
    
    // Public Function
    /// 點擊過濾處理
    func tapFilter(lastMode: SelectFilterMode, filter: String) {
        switch selectMode {
        case .notCertainTable:
            if lastMode == .notCertainTable && filter == selectFilter[0] { return }
            selectFilter = [filter]
            notCertainTableFilter(filter: filter)
        case .certainTable:
            if lastMode == .notCertainTable {
                // 上次是在notCertainTable模式
                selectFilter = [filter]
            } else {
                // 取消選取
                let idx = selectFilter.firstIndex { filterName in
                    filter == filterName
                }
                if let idx = idx {
                    selectFilter.remove(at: idx)
                } else {
                    selectFilter.append(filter)
                }
            }
            selectModeMessage = "桌名:"
            for tableName in selectFilter { selectModeMessage += "\(tableName), "}
            certainTableFilter()
            if selectFilter.count == 0 {
                selectFilter = ["最短剩餘時間"]
                notCertainTableFilter(filter: "最短剩餘時間")
                selectMode = .notCertainTable
                selectModeMessage = "最短剩餘時間"
            }
        }
    }
    
    /// 更新商家願意讓客戶看到的內容
    func updateCustomerViewInfo(selectedName: String) {
        let idx = merchantCustomViewInfo.infoShowFilters.firstIndex { info in
            info == selectedName
        }
        if let idx = idx {
            if merchantCustomViewInfo.infoShowFilters.count == 1 {
                isShowError.toggle()
                return
            }
            merchantCustomViewInfo.infoShowFilters.remove(at: idx)
        } else {
            merchantCustomViewInfo.infoShowFilters.append(selectedName)
        }
    }
    
    /// 還原設定
    func resetCustomViewInfo() {
        merchantCustomViewInfo = originalCustomViewInfo
    }
    
    /// 保存使用者介面資訊
    func saveCustomViewInfo() async {
        await MainActor.run {
            isProcessing.toggle()
        }
        
        await MainActor.run {
            isProcessing.toggle()
        }
    }
    
    // Private Function
    /// 初始化讀取資料
    private func initData() async {
        await MainActor.run {
            isProcessing.toggle()
        }
        
        let tablesUid: [String] = MerchantShareInfoManager.instance.merchantAccount.tableInfoUid
        for _ in tablesUid { }
        
        // 透過uid獲取桌子資料[TableInfoModel]，之後再透過TableInfoModel當中的foodsStatusUid獲取FoodStatusInfoModel
        var tablesModel: [TableInfoModel] = []
        // 假設有兩張桌子並且uid分別為"A"與"B"，裡面分別有偵測到2個以及3個食物，分別的uid為["A1", "A2"]以及["B1", "B2", "B3"]
        tablesModel.append(.init(uid: "A", name: "1", foodsStatusUid: ["A1", "A2"]))
        tablesModel.append(.init(uid: "B", name: "2", foodsStatusUid: ["B1", "B2", "B3"]))
        tablesModel.append(.init(uid: "C", name: "3", foodsStatusUid: []))
        tablesModel.append(.init(uid: "D", name: "4", foodsStatusUid: []))
        tablesModel.append(.init(uid: "E", name: "5", foodsStatusUid: []))
        tablesModel.append(.init(uid: "F", name: "6", foodsStatusUid: []))
        await MainActor.run {
            // 根據TableInfoModel獲取桌子名稱，並且獲取其中食物資訊
            allTablesInfos["1"] = []
            allTablesInfos["1"]!.append(.init(uid: "A1", name: "丼飯", trackId: "100", foodRemain: "10%", foodRemainTime: "20", foodRemainLine: ["100%", "60%", "50%", "49%", "10%"]))
            allTablesInfos["1"]!.append(.init(uid: "A2", name: "丼飯", trackId: "150", foodRemain: "43%", foodRemainTime: "9", foodRemainLine: ["100%", "90%", "77%", "64%", "43%"]))
            allTablesInfos["2"] = []
            allTablesInfos["2"]!.append(.init(uid: "B1", name: "丼飯", trackId: "10", foodRemain: "64%", foodRemainTime: "20", foodRemainLine: ["100%", "90%", "77%", "64%"]))
            allTablesInfos["2"]!.append(.init(uid: "B2", name: "丼飯", trackId: "20", foodRemain: "43%", foodRemainTime: "10", foodRemainLine: ["100%", "90%", "77%", "64%", "43%"]))
            allTablesInfos["2"]!.append(.init(uid: "B3", name: "丼飯", trackId: "30", foodRemain: "21%", foodRemainTime: "7", foodRemainLine: ["100%", "90%", "77%", "64%", "43%", "21"]))
            allTablesInfos["3"] = []
            allTablesInfos["4"] = []
            allTablesInfos["5"] = []
            allTablesInfos["6"] = []
            // 將桌子名稱放到selectTableList當中提供選取
            selectTableList.append("1")
            selectTableList.append("2")
            selectTableList.append("3")
            selectTableList.append("4")
            selectTableList.append("5")
            selectTableList.append("6")
        }
        
        // 透過此ID獲取商家願意讓使用端看到的資料
        let _ = MerchantShareInfoManager.instance.merchantAccount.customerViewInfoModelUid
        await MainActor.run {
            merchantCustomViewInfo.infoShowFilters.append("剩餘等待時間")
            merchantCustomViewInfo.infoShowFilters.append("自動顯示空桌")
            originalCustomViewInfo = merchantCustomViewInfo
        }
        
        await MainActor.run {
            isProcessing.toggle()
        }
    }
    
    private func notCertainTableFilter(filter: String) {
        tablesInfosShow = [:]
        if filter == "最短剩餘時間" {
            var tableName: String = ""
            var minTime: Int = 1000
            for tableInfos in allTablesInfos {
                if tableInfos.value.count == 0 {
                    tablesInfosShow[tableInfos.key] = "已為空桌"
                } else {
                    var maxTime = 0
                    for foodInfo in tableInfos.value {
                        maxTime = max(maxTime, Int(foodInfo.foodRemainTime) ?? 60)
                    }
                    if maxTime < minTime {
                        minTime = maxTime
                        tableName = tableInfos.key
                    }
                }
            }
            if tablesInfosShow.count == 0 {
                tablesInfosShow[tableName] = "剩餘: \(minTime) 分鐘"
            }
        } else {
            for tableInfos in allTablesInfos {
                if tableInfos.value.count == 0 {
                    tablesInfosShow[tableInfos.key] = "已為空桌"
                } else {
                    var maxTime = 0
                    for foodInfo in tableInfos.value {
                        maxTime = max(maxTime, Int(foodInfo.foodRemainTime) ?? 60)
                    }
                    tablesInfosShow[tableInfos.key] = "剩餘: \(maxTime) 分鐘"
                }
            }
        }
    }
    
    private func certainTableFilter() {
        tablesInfosShow = [:]
        for selectTableName in selectFilter {
            guard let tableInfos = allTablesInfos[selectTableName] else { continue }
            if tableInfos.count == 0 {
                tablesInfosShow[selectTableName] = "已為空桌"
            } else {
                var maxTime = 0
                for foodInfo in tableInfos {
                    maxTime = max(maxTime, Int(foodInfo.foodRemainTime) ?? 60)
                }
                tablesInfosShow[selectTableName] = "剩餘: \(maxTime) 分鐘"
            }
        }
    }
    
    // Subscribe Private Function
    /// 追蹤桌子資料的更新
    private func subscribeClearTableName() {
        clearTableNameCancellable = $tablesInfosShow
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] results in
                self?.clearTableName = []
                for result in results {
                    if result.value == "已為空桌" {
                        self?.clearTableName.append(result.key)
                    }
                }
            }
    }
}

extension CustomerViewInfoViewModel {
    
    enum SelectFilterMode {
        case certainTable
        case notCertainTable
    }
}
