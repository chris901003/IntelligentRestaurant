//
//  MerchantSettingViewModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/3/12.
//

import Foundation
import Combine

class MerchantSettingViewModel: ObservableObject {
    
    @Published var navigationPath: [Int] = []
    
    // Private Variable
    private var settingModeAnycancellable: AnyCancellable? = nil
    
    // Init Function
    init() {
        navigationPath = MerchantShareInfoManager.instance.settingModeSelect
        subscribeSettingMode()
    }
    
    // Subscribe Private Function
    private func subscribeSettingMode() {
        settingModeAnycancellable = MerchantShareInfoManager.instance.$settingModeSelect
            .receive(on: DispatchQueue.main)
            .sink { [weak self] returnSelectMode in
                self?.navigationPath = returnSelectMode
            }
    }
}
