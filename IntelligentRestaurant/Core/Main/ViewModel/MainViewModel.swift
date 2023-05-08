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
    @Published var userMode: UserMode = .none
    
    // Private Variable
    private var cancellable = Set<AnyCancellable>()
    
    // Init Function
    init() {
        subscribeMerchantLoginState()
//        subscribeCustomerLoginState()
    }
    
    // Subscribe Private Function
    private func subscribeMerchantLoginState() {
        MerchantShareInfoManager.instance.$isLogin
            .receive(on: DispatchQueue.main)
            .sink { [weak self] returnLoginState in
                self?.isLogin = returnLoginState
                if returnLoginState { self?.userMode = .merchant }
                else { self?.userMode = .none }
            }
            .store(in: &cancellable)
    }
    
    private func subscribeCustomerLoginState() {
        // 這裡異常發生問題
        CustomerShareInfoManager.instance.$isLogin
            .receive(on: DispatchQueue.main)
            .sink { [weak self] returnLoginState in
                self?.isLogin = returnLoginState
                if returnLoginState { self?.userMode = .customer }
                else { self?.userMode = .none }
            }
            .store(in: &cancellable)
    }
}

extension MainViewModel {
    enum UserMode {
        case merchant
        case customer
        case none
    }
}
