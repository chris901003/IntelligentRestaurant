//
//  ModelTrainDataViewModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/4/22.
//

import Foundation
import SwiftUI
import PhotosUI

class ModelObjectDetectionTrainDataViewModel: ObservableObject {
    
    // Published Variable
    @Published var trainImage: UIImage? = nil
    @Published var trainImageCount: String = ""
    
    @Published var isProcessing: Bool = false
    @Published var isProcessError: Bool = false
    @Published var isShowSuccessSaveTrainData: Bool = false
    
    // Public Variable
    var imageWidth: CGFloat = 0
    var imageHeight: CGFloat = 0
    var selectedCategory: String = "0"
    var processErrorMessage: String = ""
    var loadingMessage: String = ""
    let categoryList: [(String, String)] = [("Donburi", "0"), ("SoupRice", "1"), ("Rice", "2"), ("Countable", "3"), ("SoupNoodle", "4"), ("Noodle", "5"), ("SideDish", "6"), ("SolidSoup", "7"), ("Soup", "8")]
    
    // Private Variable
    private let uid: String = MerchantShareInfoManager.instance.merchantAccount.uid
    private let trainDataDatabaseURL = "http://120.126.151.186/API/eating/model-weight/upload-object-detection-single-image"
    private let trainDataCountURL = "http://120.126.151.186/API/eating/model-weight/object-detection-train-image-count"
    private let trainModelURL = "http://120.126.151.186/API/eating/model-weight/train-object-detection-model"
    
    // Public Function
    /// 將所選圖像轉成UIImage型態
    func transferTrainImage(selecteItem: PhotosPickerItem) async {
        guard let imageData = try? await selecteItem.loadTransferable(type: Data.self) else { return }
        await MainActor.run {
            trainImage = UIImage(data: imageData)
        }
    }
    
    /// 上傳圖像以及標註資料
    func uploadTrainData(boxFrame: CGSize, boxOffset: CGSize) async {
        await MainActor.run {
            loadingMessage = "添加訓練資料中"
            isProcessing.toggle()
        }
        
        guard let image = trainImage,
              let imageData = image.jpegData(compressionQuality: 0.5) else {
            await processErrorHandler(errorStatus: UploadTrainDataError.withoutTrainImage)
            return
        }
        
        let minX = (-boxFrame.width / 2 + boxOffset.width + imageWidth / 2) / imageWidth
        let maxX = (boxFrame.width / 2 + boxOffset.width + imageWidth / 2) / imageWidth
        let minY = (-boxFrame.height / 2 + boxOffset.height + imageHeight / 2) / imageHeight
        let maxY = (boxFrame.height / 2 + boxOffset.height + imageHeight / 2) / imageHeight
        
        // 這裡需要改成指定的類別
        let labelInfo = "\(selectedCategory) \(minX) \(minY) \(maxX) \(maxY)"
        let trainDataInfo = ObjectDetectionTrainDataModel(uid: uid, image: imageData, labelInfo: labelInfo)
        let uploadResult = await DatabaseManager.shared.uploadData(to: trainDataDatabaseURL, data: trainDataInfo)
        switch uploadResult {
        case .success(let uploadResult):
            switch uploadResult.1 {
            case 200:
                break
            default:
                guard let serverMessage = uploadResult.0.tranformToString() else {
                    await processErrorHandler(errorStatus: UploadTrainDataError.serverResponseError)
                    return
                }
                await processErrorHandler(errorStatus: UploadTrainDataError.uploadError, customMessage: serverMessage)
                return
            }
        case .failure(_):
            await processErrorHandler(errorStatus: UploadTrainDataError.uploadError)
            return
        }
        
        await MainActor.run {
            isProcessing.toggle()
            loadingMessage = ""
            isShowSuccessSaveTrainData.toggle()
        }
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        await MainActor.run {
            isShowSuccessSaveTrainData.toggle()
        }
    }
    
    /// 獲取當前訓練圖像數量
    func fetchTraiDataCount() async {
        let fetchModel: AllTableInfoQueryModel = AllTableInfoQueryModel(merchantUid: uid)
        let fetchResult = await DatabaseManager.shared.uploadData(to: trainDataCountURL, data: fetchModel)
        await MainActor.run {
            switch fetchResult {
            case .success(let returnedResult):
                guard let serverMessage = returnedResult.0.tranformToString() else {
                    trainImageCount = "服務器資料轉換錯誤"
                    return
                }
                trainImageCount = serverMessage
            case .failure(_):
                trainImageCount = "請稍後再試"
            }
        }
    }
    
    /// 開始訓練目標檢測模型
    func startTrainModel() async -> Bool {
        await MainActor.run {
            loadingMessage = "請求訓練中"
            isProcessing.toggle()
        }
        
        let queryModel = AllTableInfoQueryModel(merchantUid: uid)
        let queryResult = await DatabaseManager.shared.uploadData(to: trainModelURL, data: queryModel, timeout: 2)
        switch queryResult {
        case .success(_):
            break
        case .failure(let errorStatus):
            switch errorStatus {
            case .responseTimeOut:
                // 在請求訓練時一定會超時，因為訓練需要時間，所以當超時表示已經正在訓練
                break
            default:
                await processErrorHandler(errorStatus: TrainModelError.queryError)
                return false
            }
        }
        
        await MainActor.run {
            isProcessing.toggle()
            loadingMessage = "請求成功"
            isProcessing.toggle()
        }
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        await MainActor.run {
            isProcessing.toggle()
            loadingMessage = ""
        }
        return true
    }
    
    // Private Function
    /// 處理中發生錯誤
    private func processErrorHandler(errorStatus: any RawRepresentable, customMessage: String = "") async {
        await MainActor.run {
            processErrorMessage = customMessage.isEmpty ? errorStatus.rawValue as! String : customMessage
            isProcessError.toggle()
        }
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        await MainActor.run {
            isProcessError.toggle()
            isProcessing = false
            loadingMessage = ""
            processErrorMessage = ""
        }
    }
}

extension ModelObjectDetectionTrainDataViewModel {
    enum UploadTrainDataError: String, LocalizedError {
        case withoutTrainImage = "缺少圖像資料"
        case uploadError = "上傳失敗"
        case serverResponseError = "服務器回傳訊息錯誤"
    }
    
    enum TrainModelError: String, LocalizedError {
        case queryError = "請求失敗，請確認網路狀態"
    }
}
