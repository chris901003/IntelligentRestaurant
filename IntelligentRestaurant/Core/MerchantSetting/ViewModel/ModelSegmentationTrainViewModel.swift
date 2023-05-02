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
    
    // Public Function
    /// 將相簿選的圖像轉成UIImage
    func transferTrainImage(selectItem: PhotosPickerItem) async {
        guard let imageData = try? await selectItem.loadTransferable(type: Data.self) else { return }
        await MainActor.run {
            trainImage = UIImage(data: imageData)
        }
    }
}
