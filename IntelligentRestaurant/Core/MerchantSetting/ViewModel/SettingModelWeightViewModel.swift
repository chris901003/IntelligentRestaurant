//
//  SettingModelWeightViewModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/3/13.
//

import Foundation
import Combine

class SettingModelWeightViewModel: ObservableObject {
    
    // Published Variable
    @Published var foodCategorySelect: String = "-"
    @Published var foodCategorys: [String] = []
    @Published var modelWeightsInfo: [ModelWeightInfoModel] = []
    @Published var selectedModelWeight: ModelWeightInfoModel = ModelWeightInfoModel()
    
    @Published var isProcessing: Bool = false
    @Published var isPorcessError: Bool = false
    @Published var processErrorMessage: String = ""
    
    // Private Variable
    private var modelWeightsInfoDict: [String: [ModelWeightInfoModel]] = [:]
    private var modelsWeightsModel: [ModelWeightsModel] = []
    private var foodCategorySelectCancellable: AnyCancellable? = nil
    
    // Init Function
    init() {
        Task { await initInfo() }
        subscribeFoodCategorySelect()
    }
    
    // Public Function
    /// 處理模型權重更新相關事項
    func changeModelWeight() async {
        await MainActor.run {
            isProcessing.toggle()
        }
        
        await MainActor.run {
            isProcessing.toggle()
        }
    }
    
    // Private Function
    /// 初始化資料
    private func initInfo() async {
        await MainActor.run {
            isProcessing.toggle()
        }
        
        // 透過MerchantAccountModel中的modelWeightsUid獲取所有模型權重的Uid(一個Uid表示一個食物類型)
        // 一個食物類型會由ModelWeightModel組成
        
        // Using merchantAccount's modelWeightsUid to get ModelWeightsModel
        modelsWeightsModel.append(.init(uid: "1", name: "丼飯", weightsInfoUid: ["A", "B"]))
        modelsWeightsModel.append(.init(uid: "2", name: "麵", weightsInfoUid: ["C"]))
        
        // Using weightsInfoUid to get single model weight info
        modelWeightsInfoDict["丼飯"] = []
        modelWeightsInfoDict["丼飯"]?.append(.init(uid: "1A", name: "第一個權重", reliability: "90.1", someNote: "主要使用", isSelected: true))
        modelWeightsInfoDict["丼飯"]?.append(.init(uid: "1B", name: "增加兩張圖像", reliability: "89.2", someNote: "考慮使用", isSelected: false))
        modelWeightsInfoDict["麵"] = []
        modelWeightsInfoDict["麵"]?.append(.init(uid: "2A", name: "麵的唯一權重", reliability: "45.2", someNote: "不太行", isSelected: true))
        
        await MainActor.run {
            for categoryInfo in modelsWeightsModel {
                foodCategorys.append(categoryInfo.name)
            }
        }
        
        await MainActor.run {
            isProcessing.toggle()
        }
    }
    
    // Subscribe Private Function
    private func subscribeFoodCategorySelect() {
        foodCategorySelectCancellable = $foodCategorySelect
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedFood in
                if selectedFood == "-" {
                    self?.modelWeightsInfo = []
                    return
                }
                guard let selectedInfo = self?.modelWeightsInfoDict[selectedFood] else { return }
                self?.modelWeightsInfo = selectedInfo
                let selectIdx = selectedInfo.firstIndex { modelInfo in modelInfo.isSelected }
                if let selectIdx = selectIdx { self?.selectedModelWeight = selectedInfo[selectIdx] }
            }
    }
}
