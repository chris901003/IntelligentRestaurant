//
//  MerchantMainViewModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/3/11.
//

import Foundation
import Combine

class MerchantMainViewModel: ObservableObject {
    
    // Published Variable
    @Published var tabViewSelection = 2
    
    // Private Variable
    private var shareInfoTabViewSelectionCancellable: AnyCancellable? = nil
    
    // Init Function
    init() {
        subscribeTabViewSelection()
    }
    
    // Subscribe Private Function
    private func subscribeTabViewSelection() {
        shareInfoTabViewSelectionCancellable = MerchantShareInfoManager.instance.$tabViewSelect
            .receive(on: DispatchQueue.main)
            .sink { [weak self] returnedValue in
                self?.tabViewSelection = returnedValue
            }
    }
}
