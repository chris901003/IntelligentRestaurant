//
//  CreateCustomerAccountViewModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/5/5.
//

import Foundation
import Combine

class CreateCustomerAccountViewModel: ObservableObject {
    
    // Published Variable
    @Published var accountInform: [String] = ["", "", "", ""]
    @Published var isCanLogin: Bool = false
    
    @Published var isProcess: Bool = false
    @Published var isProcessError: Bool = false
    
    // Public Variable
    var loadingMessage: String = ""
    var errorMessage: String = ""
    
    // Private Variable
    private var cancellable = Set<AnyCancellable>()
    private var createCustomerURL = "http://120.126.151.186/API/eating/user/signin/customer"
    
    // Init Function
    init() {
        subscribeUserInfoNotEmpty()
    }
    
    // Public Function
    /// 創建帳號
    func createCustomerAccount() async -> Bool {
        await MainActor.run {
            loadingMessage = "創建帳號中"
            isProcess.toggle()
        }
        
        let customerInfo = CustomerInfoModel(name: accountInform[0], email: accountInform[1], password: accountInform[2])
        let uploadResult = await DatabaseManager.shared.uploadData(to: createCustomerURL, data: customerInfo)
        switch uploadResult {
        case .success(let returnedResult):
            switch returnedResult.1 {
            case 200:
                break
            case 403:
                await processErrorHandler(errorStatus: CreateCustomerError.accountIsExist)
                return false
            default:
                guard let serverMessage = returnedResult.0.tranformToString() else {
                    await processErrorHandler(errorStatus: CreateCustomerError.serverResponseError)
                    return false
                }
                await processErrorHandler(errorStatus: CreateCustomerError.serverResponseError, customMessage: serverMessage)
                return false
            }
        case .failure(_):
            await processErrorHandler(errorStatus: CreateCustomerError.internetError)
            return false
        }
        
        await MainActor.run {
            isProcess.toggle()
            loadingMessage = ""
        }
        return true
    }
    
    // Private Function
    /// 處理過程中發生錯誤
    private func processErrorHandler(errorStatus: any RawRepresentable, customMessage: String = "") async {
        await MainActor.run {
            errorMessage = customMessage.isEmpty ? errorStatus.rawValue as! String : customMessage
            isProcessError.toggle()
        }
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        await MainActor.run {
            isProcessError.toggle()
            isProcess.toggle()
            errorMessage = ""
            loadingMessage = ""
        }
    }
    
    // Subscribe Private Function
    private func subscribeUserInfoNotEmpty() {
        $accountInform
            .receive(on: DispatchQueue.main)
            // 使用 sink, 取得分別可以應對收到結束與收到元素的執行閉包設定方式
            .sink { [weak self] returnedUserInfo in
                // field 不為空
                for userInfo in returnedUserInfo {
                    if userInfo.isEmpty {
                        self?.isCanLogin = false
                        return
                    }
                }
                // 密碼 = 確認密碼
                if returnedUserInfo[2] != returnedUserInfo[3] {
                    self?.isCanLogin = false
                    return
                }
                // email 限制
                var temp: Bool = false
                for char in returnedUserInfo[1] {
                    if char == "@"{
                        temp = true
                    }
                }
                if !temp {
                    self?.isCanLogin = false
                    return
                }
                self?.isCanLogin = true
            }
            .store(in: &cancellable)
    }
}

extension CreateCustomerAccountViewModel {
    enum CreateCustomerError: String, LocalizedError {
        case internetError = "網路發生錯誤，請確認網路狀態"
        case accountIsExist = "帳號已存在，請直接登入"
        case serverResponseError = "服務器回傳錯誤"
    }
}
