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
    @Published var selectedWeightInfo: ObjectDetectionModelWeightModel = .init()
    
    @Published var isProcess: Bool = false
    @Published var isProcessError: Bool = false
    
    // Public Variable
    var loadingMessage: String = ""
    var processErrorMessage: String = ""
    
    // Private Variable
    private let uid: String = MerchantShareInfoManager.instance.merchantAccount.uid
    private let objectDetectionModelUrl: String = "http://120.126.151.186/API/eating/model-weight/fetch-object-detection-model-info"
    private let changeModelWeightUrl: String = "http://120.126.151.186/API/eating/model-weight/change-object-detection-weight-name"
    private let changeModelWeightUseUrl: String = "http://120.126.151.186/API/eating/model-weight/object-detection-model-selected"
    
    // Init Function
    init() {
        Task { await initModelWeightInfo() }
    }
    
    // Public Function
    /// 更新權重名稱
    public func changeModelWeight() async -> Bool {
        await MainActor.run {
            loadingMessage = "更新中"
            isProcess.toggle()
        }
        
        let idx = modelWeightInfo.firstIndex { $0.id == selectedWeightInfo.id }
        guard let idx = idx else {
            await processErrorHandler(errorStatus: ChangeModelWeightError.neverFail)
            return false
        }
        let changeModelWeightNameModel = ObjectDetectionWeightModelRenameModel(merchantUid: uid, oldName: modelWeightInfo[idx].name, newName: selectedWeightInfo.name, recommend: selectedWeightInfo.recommend)
        let changeResult = await DatabaseManager.shared.uploadData(to: changeModelWeightUrl, data: changeModelWeightNameModel)
        switch changeResult {
        case .success(let returnedChangeResult):
            switch returnedChangeResult.1 {
            case 200:
                break
            default:
                await processErrorHandler(errorStatus: ChangeModelWeightError.internetError)
                return false
            }
        case .failure(_):
            await processErrorHandler(errorStatus: ChangeModelWeightError.internetError)
            return false
        }
        
        await MainActor.run {
            modelWeightInfo[idx] = selectedWeightInfo
        }
        
        await MainActor.run {
            isProcess.toggle()
            loadingMessage = ""
        }
        return true
    }
    
    /// 更新使用的模型
    public func changeModelUse() async {
        await MainActor.run {
            loadingMessage = "更換權重中"
            isProcess.toggle()
        }
        
        let modelWeightUseChange = ObjectDetectionWeightModelUse(merchantUid: uid, fileName: selectedWeightInfo.name, recommend: selectedWeightInfo.recommend, reset: 0)
        let updateModelWeightChangeResult = await DatabaseManager.shared.uploadData(to: changeModelWeightUseUrl, data: modelWeightUseChange)
        switch updateModelWeightChangeResult {
        case .success(let returnedResult):
            switch returnedResult.1 {
            case 200:
                break
            default:
                await processErrorHandler(errorStatus: ChangeModelWeightError.internetError)
                return
            }
        case .failure(_):
            await processErrorHandler(errorStatus: ChangeModelWeightError.internetError)
            return
        }
        
        let idx = modelWeightInfo.firstIndex { $0.isChoose }
        if let idx = idx {
            await MainActor.run {
                modelWeightInfo[idx].isChoose = false
            }
        }
        let infoIdx = modelWeightInfo.firstIndex { $0.id == selectedWeightInfo.id }
        guard let infoIdx = infoIdx else {
            await processErrorHandler(errorStatus: ChangeModelWeightError.neverFail)
            return
        }
        await MainActor.run {
            modelWeightInfo[infoIdx].isChoose = true
        }
        
        await MainActor.run {
            isProcess.toggle()
            loadingMessage = ""
        }
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
    
    enum ChangeModelWeightError: String, LocalizedError {
        case neverFail = "若發生此錯誤請重啟"
        case internetError = "網路發生錯誤，請稍後再試"
    }
    
    enum ChangeModelWeightUseError: String, LocalizedError {
        case neverFail = "若發生此錯誤請重啟"
        case internetError = "網路發生錯誤，請稍後再試"
    }
}
