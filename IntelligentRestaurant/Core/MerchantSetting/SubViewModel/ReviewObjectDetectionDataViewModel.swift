//
//  ReviewObjectDetectionDataViewModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/4/25.
//

import Foundation

class ReviewObjectDetectionDataViewModel: ObservableObject {
    
    // Published Variable
    @Published var uploadTrainData: [ReviewObjectDetectionDataModel] = []
    @Published var totalPage: Int = 0
    @Published var nextPage: Int = 1
    
    @Published var isProcessing: Bool = false
    @Published var isProcessError: Bool = false
    
    // Public Variable
    var loadingMessage: String = ""
    var errorMessage: String = ""
    
    // Private
    private let uid: String = MerchantShareInfoManager.instance.merchantAccount.uid
    private let imagePerPage: Int = 10
    private var totalTrainImage: Int = 0
    private let trainDataCountURL = "http://120.126.151.185/API/eating/model-weight/object-detection-train-image-count"
    private let trainDataInfoURL = "http://120.126.151.185/API/eating/model-weight/object-detection-train-image-info"
    private let trainDataDeleteURL = "http://120.126.151.185/API/eating/model-weight/delete-object-detection-train-image"
    
    // Init Function
    init() {
        Task { await initialProcess() }
    }
    
    // Public Function
    /// 獲取指定頁數的圖像資料
    func fetchTainImagesForm(page: Int) async {
        guard page <= totalPage else { return }
        let fetchModel = FetchObjectDetectionTrainInfoModel(merchantUid: uid, page: page, gap: imagePerPage)
        let fetchTrainInfoResult = await DatabaseManager.shared.uploadData(to: trainDataInfoURL, data: fetchModel)
        switch fetchTrainInfoResult {
        case .success(let returnedResult):
            switch returnedResult.1 {
            case 200:
                guard let returnedReviewModel = try? JSONDecoder().decode([ReviewObjectDetectionDataModel].self, from: returnedResult.0) else {
                    await processErrorHandler(errorStatus: RuntimeProcessError.dataTransferError)
                    return
                }
                await MainActor.run {
                    uploadTrainData.append(contentsOf: returnedReviewModel)
                }
            default:
                guard let serverMessage = returnedResult.0.tranformToString() else {
                    await processErrorHandler(errorStatus: RuntimeProcessError.fetchTrainImageError)
                    return
                }
                await processErrorHandler(errorStatus: RuntimeProcessError.fetchTrainImageError, customMessage: serverMessage)
                return
            }
        case .failure(_):
            break
        }
    }
    
    /// 刪除指定訓練資料
    func deleteTrainData(trainDataInfo: ReviewObjectDetectionDataModel) async {
        await MainActor.run {
            loadingMessage = "刪除中"
            isProcessing.toggle()
        }
        
        let idx = uploadTrainData.firstIndex { $0.id == trainDataInfo.id }
        guard let idx = idx else {
            await processErrorHandler(errorStatus: DeleteTrainImageError.neverFail)
            return
        }
        await MainActor.run {
            uploadTrainData[idx].isShow = false
        }
        guard await deleteObjectDetectionTrainInfo(trainDataInfo: trainDataInfo) else { return }
        
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        await MainActor.run {
            isProcessing.toggle()
            loadingMessage = ""
        }
    }
    
    // Private Function
    /// 初始化流
    private func initialProcess() async {
        await MainActor.run {
            loadingMessage = "請稍候"
            isProcessing.toggle()
        }
        
        await fetchAllTrainImageCount()
        await MainActor.run {
            totalPage = Int(ceil(Double(totalTrainImage) / Double(imagePerPage)))
        }
//        if totalPage >= 1 {
//            await MainActor.run {
//                nextPage = 1
//            }
//            await fetchTainImagesForm(page: nextPage)
//            await MainActor.run {
//                nextPage += 1
//            }
//        }
        
        await MainActor.run {
            isProcessing = false
            loadingMessage = ""
        }
    }
    
    /// 獲取總共有多少訓練圖像
    private func fetchAllTrainImageCount() async {
        let fetchModel = AllTableInfoQueryModel(merchantUid: uid)
        let queryTrainInfoResult = await DatabaseManager.shared.uploadData(to: trainDataCountURL, data: fetchModel)
        switch queryTrainInfoResult {
        case .success(let queryResult):
            switch queryResult.1 {
            case 200, 201:
                guard let serverMessage = queryResult.0.tranformToString() else {
                    await processErrorHandler(errorStatus: InitializeError.serverTrainDataCountReturnError)
                    return
                }
                guard let trainImageCount = Int(serverMessage) else {
                    totalTrainImage = 0
                    return
                }
                totalTrainImage = trainImageCount
            default:
                totalTrainImage = -1
            }
        case .failure(_):
            await processErrorHandler(errorStatus: InitializeError.fetchAllTrainDataCountError)
            return
        }
    }
    
    /// 將資料庫中的目標檢測資料刪除
    private func deleteObjectDetectionTrainInfo(trainDataInfo: ReviewObjectDetectionDataModel) async -> Bool {
        let deleteModel = DeleteObjectDetectionTrainInfoModel(merchantUid: uid, target: trainDataInfo.target)
        let deleteResult = await DatabaseManager.shared.uploadData(to: trainDataDeleteURL, data: deleteModel)
        switch deleteResult {
        case .success(let returnedResult):
            switch returnedResult.1 {
            case 200:
                break
            default:
                guard let serverMessage = returnedResult.0.tranformToString() else {
                    await processErrorHandler(errorStatus: DeleteTrainImageError.serverMessageError)
                    return false
                }
                await processErrorHandler(errorStatus: DeleteTrainImageError.deleteTrainInfoError, customMessage: serverMessage)
                return false
            }
        case .failure(_):
            await processErrorHandler(errorStatus: DeleteTrainImageError.internetError)
            return false
        }
        return true
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
            isProcessing = false
            errorMessage = ""
        }
    }
}

extension ReviewObjectDetectionDataViewModel {
    enum InitializeError: String, LocalizedError {
        case fetchAllTrainDataCountError = "無法獲取總訓練圖像數，請檢查網路狀態"
        case serverTrainDataCountReturnError = "服務器資料回傳錯誤"
    }
    
    enum RuntimeProcessError: String, LocalizedError {
        case fetchTrainImageError = "獲取訓練圖像資料失敗，請確認網路狀態"
        case dataTransferError = "資料轉換錯誤"
    }
    
    enum DeleteTrainImageError: String, LocalizedError {
        case neverFail = "不可能發生錯誤"
        case deleteTrainInfoError = "刪除資料失敗，請確認網路狀態"
        case internetError = "網路發生錯誤，請重新試一次"
        case serverMessageError = "資料庫回傳錯誤"
    }
}
