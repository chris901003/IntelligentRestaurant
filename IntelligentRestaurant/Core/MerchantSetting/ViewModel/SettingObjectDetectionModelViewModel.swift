//
//  SettingObjectDetectionModelViewModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/4/29.
//

import Foundation

class SettingObjectDetectionModelViewModel: ObservableObject {
    
    // Published Variable
    @Published var isProcess: Bool = false
    @Published var isProcessError: Bool = false
    
    // Public Variable
    var loadingMessage: String = ""
    var processErrorMessage: String = ""
}
