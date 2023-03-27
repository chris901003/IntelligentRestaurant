//
//  MainViewModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/3/16.
//

import Foundation
import Combine

class MainViewModel: ObservableObject {
    
    // Published Variable
    @Published var isLogin: Bool = MerchantShareInfoManager.instance.isLogin
    @Published var userMode: MerchantShareInfoManager.UserMode = .merchant
    
    // Private Variable
    private var cancellable = Set<AnyCancellable>()
    
    // Init Function
    init() {
        subscribeLoginState()
        subscribeAccountMode()
    }
    
    // Subscribe Private Function
    private func subscribeLoginState() {
        MerchantShareInfoManager.instance.$isLogin
            .receive(on: DispatchQueue.main)
            .sink { [weak self] returnLoginState in
                self?.isLogin = returnLoginState
            }
            .store(in: &cancellable)
    }
    
    private func subscribeAccountMode() {
        MerchantShareInfoManager.instance.$userMode
            .receive(on: DispatchQueue.main)
            .sink { [weak self] returnedAccountMode in
                self?.userMode = returnedAccountMode
            }
            .store(in: &cancellable)
    }
}
