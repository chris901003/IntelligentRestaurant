//
//  CameraUidSettingViewModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/3/20.
//

import Foundation

class CameraUidSettingViewModel: ObservableObject {
    
    // Published Variable
    @Published var isProcessing: Bool = false
    @Published var isProcessError: Bool = false
    @Published var processErrorMessage: String = ""
    @Published var tablesInfo: [(String, String)] = []
    
    private var merchantUid: String = MerchantShareInfoManager.instance.merchantAccount.uid
    private let allTableInfoDatabaseUrl: String = "http://120.126.151.186/API/eating/table/all-table-info"
    
    // Init Function
    init() {
        Task { await loadTableInfo() }
    }
    
    // Private Function
    /// 讀取桌子資料
    private func loadTableInfo() async {
        await MainActor.run {
            isProcessing.toggle()
        }
        
        guard await fetchAllTable() else { return }
        
        await MainActor.run {
            isProcessing.toggle()
        }
    }
    
    /// 獲取該店家有的所有桌子以及桌子的uid
    private func fetchAllTable() async -> Bool {
        let allTableInfoQueryModel = AllTableInfoQueryModel(merchantUid: merchantUid)
        let queryResult = await DatabaseManager.shared.uploadData(to: allTableInfoDatabaseUrl, data: allTableInfoQueryModel)
        switch queryResult {
        case .success(let results):
            switch results.1 {
            case 200:
                guard let fetchAllTableItemResult = try? JSONDecoder().decode(AllTableInfoReturnedModel.self, from: results.0) else {
                    await processErrorHandler(errorStatus: InitError.allTableInfoTransferError)
                    return false
                }
                for itemInfo in fetchAllTableItemResult.results {
                    await MainActor.run {
                        tablesInfo.append((itemInfo.name, itemInfo.uid))
                    }
                }
            default:
                let message = results.0.tranformToString() ?? "意外了"
                await processErrorHandler(errorStatus: InitError.queryAllTableInfoError, customMessage: message)
            }
        case .failure(_):
            return false
        }
        return true
    }
    
    /// 處理過程中發生錯誤
    private func processErrorHandler(errorStatus: any RawRepresentable, customMessage: String = "") async {
        await MainActor.run {
            processErrorMessage = customMessage.isEmpty ? errorStatus.rawValue as! String : customMessage
            isProcessError.toggle()
        }
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        await MainActor.run {
            isProcessError.toggle()
            isProcessing = false
            processErrorMessage = ""
        }
    }
}

extension CameraUidSettingViewModel {
    
    enum InitError: String, LocalizedError {
        case queryAllTableInfoError = "獲取所有桌子資訊失敗，請檢查網路連線狀態"
        case allTableInfoTransferError = "桌子資料轉換錯誤"
    }
}
