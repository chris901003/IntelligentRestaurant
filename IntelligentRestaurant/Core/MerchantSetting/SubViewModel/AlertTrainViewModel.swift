//
//  AlertTrainViewModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/4/29.
//

import Foundation

class AlertTrainViewModel: ObservableObject {
    
    // Published Variable
    @Published var isProcess: Bool = false
    @Published var isProcessError: Bool = false
    
    // Public Variable
    var loadingMessage: String = ""
    var processErrorMessage: String = ""
    
    // Private Variable
    private let uid: String = MerchantShareInfoManager.instance.merchantAccount.uid
    private let stopTrainUrl = "http://120.126.151.185/API/eating/model-weight/stop-train"
    
    // Public Function
    /// 暫停訓練
    func stopTrain() async {
        await MainActor.run {
            loadingMessage = "暫停訓練中"
            isProcess.toggle()
        }
        
        let queryStopTrain = AllTableInfoQueryModel(merchantUid: uid)
        let stopResult = await DatabaseManager.shared.uploadData(to: stopTrainUrl, data: queryStopTrain)
        switch stopResult {
        case .success(let returnStopResult):
            switch returnStopResult.1 {
            case 200:
                break
            case 201:
                guard let serverMessage = returnStopResult.0.tranformToString() else {
                    await processErrorHandler(errorStatus: .serverMessageError)
                    return
                }
                await processErrorHandler(errorStatus: .pleaseWait, customMessage: serverMessage)
            default:
                await processErrorHandler(errorStatus: .serverError)
                return
            }
        case .failure(_):
            await processErrorHandler(errorStatus: .serverError)
            return
        }
        
        await MainActor.run {
            isProcess = false
            loadingMessage = ""
        }
    }
}

extension AlertTrainViewModel {
    private func processErrorHandler(errorStatus: StopTrainError, customMessage: String = "") async {
        await MainActor.run {
            processErrorMessage = customMessage.isEmpty ? errorStatus.rawValue : customMessage
            isProcessError.toggle()
        }
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        await MainActor.run {
            isProcessError.toggle()
            isProcess = false
            processErrorMessage = ""
        }
    }
    
    enum StopTrainError: String, LocalizedError {
        case serverError = "網路發生錯誤"
        case serverMessageError = "服務器回傳資料錯誤"
        case pleaseWait = "請稍候"
    }
}
