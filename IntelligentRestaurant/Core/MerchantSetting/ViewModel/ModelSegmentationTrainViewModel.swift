//
//  ModelSegmentationTrainViewModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/4/24.
//

import Foundation
import SwiftUI
import PhotosUI

class ModelSegmentationTrainViewModel: ObservableObject {
    
    // Published Variable
    @Published var trainImage: UIImage? = nil
    @Published var drawFoodPath: [CGPoint] = []
    @Published var drawNotFoodPath: [CGPoint] = []
    
    @Published var isProcess: Bool = false
    @Published var isProcessError: Bool = false
    
    // Public Variable
    var loadingMessage: String = ""
    var errorMessage: String = ""
    var selectedCategory: String = "0"
    let categoryList: [(String, String)] = [("Donburi", "0"), ("SoupRice", "1"), ("Rice", "2"), ("Countable", "3"), ("SoupNoodle", "4"), ("Noodle", "5"), ("SideDish", "6"), ("SolidSoup", "7"), ("Soup", "8")]
    // 在畫面中圖像的大小
    var showImageHeight: Double = 0
    var showImageWidth: Double = 0

    // Private Variable
    private let uid: String = MerchantShareInfoManager.instance.merchantAccount.uid
    private let uploadTrainDataUrl: String = "http://120.126.151.185/API/eating/model-weight/upload-segmentation-single-image"
    
    // Public Function
    /// 將相簿選的圖像轉成UIImage
    func transferTrainImage(selectItem: PhotosPickerItem) async {
        guard let imageData = try? await selectItem.loadTransferable(type: Data.self) else { return }
        await MainActor.run {
            trainImage = UIImage(data: imageData)
        }
    }
    
    /// 將標注資料上傳到後端
    func uploadTrainData() async {
        await MainActor.run {
            loadingMessage = "上傳中"
            isProcess.toggle()
        }
        
        guard !drawFoodPath.isEmpty else {
            await processErrorHandler(errorStatus: UploadTainDataError.withoutFoodBox)
            return
        }
        guard !drawNotFoodPath.isEmpty else {
            await processErrorHandler(errorStatus: UploadTainDataError.withoutNotFoodBox)
            return
        }
        guard let image = trainImage else {
            await processErrorHandler(errorStatus: UploadTainDataError.withoutTrainImage)
            return
        }
        
        let oriImageHeight = Double(image.size.height)
        let oriImageWidth = Double(image.size.width)
        let heightScale = oriImageHeight / showImageHeight
        let widthScale = oriImageWidth / showImageWidth
        
        let foodPath: [[String]] = drawFoodPath.map { point -> [String] in
            [String(Double(point.x) * widthScale), String(Double(point.y) * heightScale)]
        }
        let notFoodPath: [[String]] = drawNotFoodPath.map { point -> [String] in
            [String(Double(point.x) * widthScale), String(Double(point.y) * heightScale)]
        }
        
        let uploadDataModel = SegmentationTrainDataModel(merchantUid: uid, foodType: .init(rawValue: selectedCategory)!, image: image, imageHeight: String(oriImageHeight), imageWidth: String(oriImageHeight), food: foodPath, notFood: notFoodPath)
        
        let uploadTrainDataResult = await DatabaseManager.shared.uploadData(to: uploadTrainDataUrl, data: uploadDataModel)
        switch uploadTrainDataResult {
        case .success(let uploadResult):
            switch uploadResult.1 {
            case 200:
                print("✅ Success")
            default:
                print("❌ Fail Status Code: \(uploadResult.1)")
            }
        case .failure(_):
            print("Fail")
        }
        
        await MainActor.run {
            isProcess.toggle()
            loadingMessage = ""
        }
    }
    
    // Private Function
    /// 處理中錯誤
    private func processErrorHandler(errorStatus: any RawRepresentable, customMessage: String = "") async {
        await MainActor.run {
            errorMessage = customMessage.isEmpty ? errorStatus.rawValue as! String : customMessage
            isProcessError.toggle()
        }
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        await MainActor.run {
            isProcessError.toggle()
            isProcess = false
            errorMessage = ""
            loadingMessage = ""
        }
    }
}

extension ModelSegmentationTrainViewModel {
    enum UploadTainDataError: String, LocalizedError {
        case withoutFoodBox = "須提供食物的範圍"
        case withoutNotFoodBox = "須提供非食物範圍"
        case withoutTrainImage = "缺少訓練圖像"
    }
}
