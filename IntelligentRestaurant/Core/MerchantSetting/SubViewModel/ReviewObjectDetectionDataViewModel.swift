//
//  ReviewObjectDetectionDataViewModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/4/25.
//

import Foundation

class ReviewObjectDetectionDataViewModel: ObservableObject {
    
    // 你知道接下來要幹嘛的，問題不大
    
    // Published Variable
    @Published var uploadTrainData: [ReviewObjectDetectionDataModel] = []
    
    @Published var isProcessing: Bool = false
    @Published var isProcessError: Bool = false
    
    // Public Variable
    var loadingMessage: String = ""
    var errorMessage: String = ""
    
    // Private
    private let uid: String = MerchantShareInfoManager.instance.merchantAccount.uid
    private var totalTrainImage: Int = 0
    private let trainDataCountURL = "http://120.126.151.186/API/eating/model-weight/object-detection-train-image-count"
    
    // Init Function
    init() {
        Task { await initialProcess() }
    }
    
    // Private Function
    /// 初始化流
    private func initialProcess() async {
        await MainActor.run {
            loadingMessage = "請稍候"
            isProcessing.toggle()
        }
        
        await fetchAllTrainImage()
        
        await MainActor.run {
            loadingMessage = ""
            isProcessing.toggle()
        }
    }
    
    /// 獲取總共有多少訓練圖像
    private func fetchAllTrainImage() async {
        let fetchModel = AllTableInfoQueryModel(merchantUid: uid)
        let queryTrainInfoResult = await DatabaseManager.shared.uploadData(to: trainDataCountURL, data: fetchModel)
        switch queryTrainInfoResult {
        case .success(let queryResult):
            guard let serverMessage = queryResult.0.tranformToString() else {
                await processErrorHandler(errorStatus: InitializeError.serverTrainDataCountReturnError)
                return
            }
            guard let trainImageCount = Int(serverMessage) else {
                await processErrorHandler(errorStatus: InitializeError.serverTrainDataCountReturnError)
                return
            }
            totalTrainImage = trainImageCount
        case .failure(_):
            await processErrorHandler(errorStatus: InitializeError.fetchAllTrainDataCountError)
            return
        }
    }
}

extension ReviewObjectDetectionDataViewModel {
    /// 處理意外狀況
    private func processErrorHandler(errorStatus: any RawRepresentable, customMessage: String = "") async {
        await MainActor.run {
            errorMessage = customMessage.isEmpty ? errorStatus.rawValue as! String : customMessage
            isProcessError.toggle()
        }
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        await MainActor.run {
            isProcessError.toggle()
            isProcessing.toggle()
            errorMessage = ""
        }
    }
}

extension ReviewObjectDetectionDataViewModel {
    enum InitializeError: String, LocalizedError {
        case fetchAllTrainDataCountError = "無法獲取總訓練圖像數，請檢查網路狀態"
        case serverTrainDataCountReturnError = "服務器資料回傳錯誤"
    }
}
