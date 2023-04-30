//
//  SettingObjectDetectionModelViewModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/4/29.
//

import Foundation

class SettingObjectDetectionModelViewModel: ObservableObject {
    
    // Published Variable
    @Published var modelWeightInfo: [ObjectDetectionModelWeightModel] = []
    
    @Published var isProcess: Bool = false
    @Published var isProcessError: Bool = false
    
    // Public Variable
    var loadingMessage: String = ""
    var processErrorMessage: String = ""
    
    // Private Variable
    private let uid: String = MerchantShareInfoManager.instance.merchantAccount.uid
    private let objectDetectionModelUrl: String = "http://120.126.151.186/API/eating/model-weight/fetch-object-detection-model-info"
    
    // Init Function
    init() {
        Task { await initModelWeightInfo() }
    }
    
    // Private Function
    /// 初始化目標檢測權重資料
    private func initModelWeightInfo() async {
        await MainActor.run {
            loadingMessage = "獲取資料中"
            isProcess.toggle()
        }
        
        let queryModel = AllTableInfoQueryModel(merchantUid: uid)
        let queryModelWeightResult = await DatabaseManager.shared.uploadData(to: objectDetectionModelUrl, data: queryModel)
        switch queryModelWeightResult {
        case .success(let returnedModelWeightResult):
            switch returnedModelWeightResult.1 {
            case 200:
                guard let returnedModelWeightInfo = try? JSONDecoder().decode([ObjectDetectionModelWeightModel].self, from: returnedModelWeightResult.0) else {
                    await processErrorHandler(errorStatus: InitModelWeightInfoError.modelWeightTransferError)
                    return
                }
                await MainActor.run {
                    modelWeightInfo = returnedModelWeightInfo
                }
            default:
                await processErrorHandler(errorStatus: InitModelWeightInfoError.modelWeightTransferError)
                return
            }
        case .failure(_):
            await processErrorHandler(errorStatus: InitModelWeightInfoError.modelWeightTransferError)
            return
        }
        
        await MainActor.run {
            isProcess.toggle()
            loadingMessage = ""
        }
    }
}

extension SettingObjectDetectionModelViewModel {
    /// 處理中發生錯誤
    private func processErrorHandler(errorStatus: any RawRepresentable, customMessage: String = "") async {
        await MainActor.run {
            processErrorMessage = customMessage.isEmpty ? errorStatus.rawValue as! String : customMessage
            isProcessError.toggle()
        }
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        await MainActor.run {
            isProcessError.toggle()
            isProcess.toggle()
            processErrorMessage = ""
            loadingMessage = ""
        }
    }
}

extension SettingObjectDetectionModelViewModel {
    enum InitModelWeightInfoError: String, LocalizedError {
        case modelWeightTransferError = "資料轉換錯誤，請確認資料庫"
    }
}
