//
//  CustomerAccountViewModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/5/5.
//

import Foundation
import Combine

class CustomerAccountViewModel: ObservableObject {
    
    // Published Variable
    @Published var customerInfo: CustomerAccountModel
    @Published var newCustomerInfo: CustomerAccountModel
    @Published var oldPassword: String = ""
    @Published var newPasswordConfirm: String = ""
    
    @Published var isProcess: Bool = false
    @Published var isProcessError: Bool = false
    
    // Public Variable
    var loadingMessage: String = ""
    var errorMessage: String = ""
    
    // Private Variable
    private var updateAccountURL = "http://120.126.151.185/API/eating/user/customer"
    
    // Init Function
    init() {
        customerInfo = CustomerShareInfoManager.instance.customerAccount
        newCustomerInfo = CustomerShareInfoManager.instance.customerAccount
        newCustomerInfo.password = ""
    }
    
    // Public Function
    /// 更新使用者資料
    func updateCustomerAccount() async -> Bool {
        await MainActor.run {
            loadingMessage = "更新資料中"
            isProcess.toggle()
        }
        
        if newCustomerInfo.name.isEmpty {
            await processErrorHandler(errorStatus: UpdateCustomerAccountInfoError.emptyName)
            return false
        }
        if newCustomerInfo.email.isEmpty {
            await processErrorHandler(errorStatus: UpdateCustomerAccountInfoError.emptyEmail)
            return false
        }
        if oldPassword != customerInfo.password {
            await processErrorHandler(errorStatus: UpdateCustomerAccountInfoError.oldPasswordError)
            return false
        }
        if newCustomerInfo.password.isEmpty {
            await processErrorHandler(errorStatus: UpdateCustomerAccountInfoError.emptyNewPassword)
            return false
        }
        if newCustomerInfo.password != newPasswordConfirm {
            await processErrorHandler(errorStatus: UpdateCustomerAccountInfoError.newPasswordConfirmError)
            return false
        }
        
        let updateAccountResult = await DatabaseManager.shared.uploadData(to: updateAccountURL, data: newCustomerInfo, httpMethod: "PUT")
        switch updateAccountResult {
        case .success(let returnedResult):
            switch returnedResult.1 {
            case 200:
                break
            case 403:
                await processErrorHandler(errorStatus: UpdateCustomerAccountInfoError.emailExist)
                return false
            default:
                await processErrorHandler(errorStatus: UpdateCustomerAccountInfoError.internetError)
                return false
            }
        case .failure(_):
            await processErrorHandler(errorStatus: UpdateCustomerAccountInfoError.internetError)
            return false
        }
        
        await MainActor.run {
            isProcess = false
            loadingMessage = ""
            customerInfo = newCustomerInfo
            CustomerShareInfoManager.instance.customerAccount = newCustomerInfo
            oldPassword = ""
            newPasswordConfirm = ""
            newCustomerInfo.password = ""
        }
        return true
    }
}

extension CustomerAccountViewModel {
    enum UpdateCustomerAccountInfoError: String, LocalizedError {
        case emptyName = "名稱不可為空"
        case emptyEmail = "郵件不可為空"
        case emailExist = "郵件已存在"
        case oldPasswordError = "舊密碼不一致"
        case emptyNewPassword = "新密碼不可為空"
        case newPasswordConfirmError = "新密碼不一致"
        case internetError = "網路發生錯誤，請確認網路狀態"
    }
}

extension CustomerAccountViewModel {
    private func processErrorHandler(errorStatus: any RawRepresentable, customMessage: String = "") async {
        await MainActor.run {
            errorMessage = customMessage.isEmpty ? errorStatus.rawValue as! String : customMessage
            isProcessError.toggle()
        }
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        await MainActor.run {
            isProcessError.toggle()
            isProcess.toggle()
            loadingMessage = ""
            errorMessage = ""
        }
    }
}
