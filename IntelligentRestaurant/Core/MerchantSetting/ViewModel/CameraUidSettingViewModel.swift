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
        
        let _ = MerchantShareInfoManager.instance.merchantAccount.tableInfoUid
        await MainActor.run {
            // 從資料庫獲取桌子資料
            tablesInfo.append(("1", "A"))
            tablesInfo.append(("2", "B"))
            tablesInfo.append(("3", "C"))
        }
        
        await MainActor.run {
            isProcessing.toggle()
        }
    }
}
