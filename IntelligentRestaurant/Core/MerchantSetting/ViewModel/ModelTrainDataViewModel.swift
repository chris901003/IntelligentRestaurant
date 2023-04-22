//
//  ModelTrainDataViewModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/4/22.
//

import Foundation
import SwiftUI
import PhotosUI

class ModelTrainDataViewModel: ObservableObject {
    
    // Published Variable
    @Published var trainImage: UIImage? = nil
    
    @Published var isProcessing: Bool = false
    @Published var isProcessError: Bool = false
    @Published var isShowSuccessSaveTrainData: Bool = false
    
    // Public Variable
    var imageWidth: CGFloat = 0
    var imageHeight: CGFloat = 0
    var processErrorMessage: String = ""
    var loadingMessage: String = ""
    
    // Private Variable
    private let uid: String = MerchantShareInfoManager.instance.merchantAccount.uid
    private let trainDataDatabaseURL = "http://120.126.151.186/API/eating/model-weight/upload-object-detection-single-image"
    
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
        let labelInfo = "\(minX) \(minY) \(maxX) \(maxY) 0"
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

extension ModelTrainDataViewModel {
    enum UploadTrainDataError: String, LocalizedError {
        case withoutTrainImage = "缺少圖像資料"
        case uploadError = "上傳失敗"
        case serverResponseError = "服務器回傳訊息錯誤"
    }
}
