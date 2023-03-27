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
    private var tableInfoUid: [String] = MerchantShareInfoManager.instance.merchantAccount.tableInfoUid
    private var cancellable = Set<AnyCancellable>()
    private var refreshTimer: Timer? = nil
    
    init() {
        
        // Mock Data (TableInfoModel uid，這裡假設有3張桌子，分別的uid假設成["A"~"C"])
        tableInfoUid.append("A")
        tableInfoUid.append("B")
        tableInfoUid.append("C")
        
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
        
        await MainActor.run {
            // 透過TableInfoModel獲取桌子資訊
            // name獲取桌名
            tableChoiceList.append(contentsOf: ["一", "二", "三"])
            
            // 獲取每張桌子當中相機抓取到的食物資料
            // 遍歷每張桌子
            if tablesFoodsInfo["一"] == nil { tablesFoodsInfo["一"] = [:] }
            if tablesFoodsInfo["二"] == nil { tablesFoodsInfo["二"] = [:] }
            if tablesFoodsInfo["三"] == nil { tablesFoodsInfo["三"] = [:] }
            // 透過foodsStatusUid獲取FoodStatusInfoModel資料
            // ["桌子的名稱"]["trackId"]
            tablesFoodsInfo["一"]!["100"] = FoodStatusInfoModel(uid: "1", name: "丼飯", trackId: "100", foodRemain: "100%", foodRemainTime: "20", foodRemainLine: ["100%", "60%", "50%", "49%", "10%"])
            tablesFoodsInfo["一"]!["200"] = FoodStatusInfoModel(uid: "2", name: "丼飯", trackId: "200", foodRemain: "100%", foodRemainTime: "19", foodRemainLine: ["100%", "90%", "77%", "64%", "43%"])
            tablesFoodsInfo["二"]!["150"] = FoodStatusInfoModel(uid: "3", name: "丼飯", trackId: "150", foodRemain: "100%", foodRemainTime: "18", foodRemainLine: ["100%", "93%", "90%", "85%", "79%"])
            tablesFoodsInfo["二"]!["250"] = FoodStatusInfoModel(uid: "3", name: "丼飯", trackId: "250", foodRemain: "100%", foodRemainTime: "18", foodRemainLine: ["100%", "80%", "24%", "17%", "0%"])
            
            tableInfoShowIdx = tablesFoodsInfo.keys.sorted()
        }
        
//        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        await MainActor.run {
            isProgressing.toggle()
        }
    }
    
    /// 更新資料
    private func refreshData() async {
        await MainActor.run {
            isProgressing.toggle()
        }
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        await MainActor.run {
            isProgressing.toggle()
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
