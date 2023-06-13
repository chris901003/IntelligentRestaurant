//
//  ChangePasswordViewModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/3/12.
//

import Foundation
import Combine

class ChangePasswordViewModel: ObservableObject {
    
    // Published Variable
    @Published var oldPassword: String = ""
    @Published var newPassword: String = ""
    @Published var confirmNewPassword: String = ""
    
    @Published var isConfirmNewPasswordValid: Bool = false
    
    @Published var isProgressing: Bool = false
    @Published var isProgressError: Bool = false
    @Published var progressErrorMessage: String = ""
    
    // Private Variable
    private var verifyOldPasswordUrl: String = "http://120.126.151.185/API/eating/user/login"
    private var cancellable = Set<AnyCancellable>()
    
    // Init Function
    init() {
        subscribeConfirmNewPassword()
    }
    
    // Public Function
    /// 更新密碼
    func changePassword() async -> Bool {
        await MainActor.run {
            isProgressing.toggle()
        }
        
        // 密碼強度檢查
        if !newPassword.isPasswordValid() {
            await processErrorHandler(errorStatus: .passwordNotStrongEnough)
            return false
        }
        
        // 原始密碼輸入錯誤
        var tmpMerchantAccount = MerchantShareInfoManager.instance.merchantAccount
        tmpMerchantAccount.password = oldPassword
        let checkOldPasswordResult = await DatabaseManager.shared.uploadData(to: verifyOldPasswordUrl, data: tmpMerchantAccount)
        switch checkOldPasswordResult {
        case .success(let checkInfo):
            switch checkInfo.1 {
            case 200:
                break
            case 400:
                await processErrorHandler(errorStatus: .statusCode400)
                return false
            case 403:
                await processErrorHandler(errorStatus: .statusCode403)
                return false
            default:
                await processErrorHandler(errorStatus: .statusCodeUndefined)
                return false
            }
        case .failure(let errorStatus):
            await processErrorHandler(errorStatus: .somethingError, customErrorMessage: errorStatus.rawValue)
            return false
        }
        
        await MainActor.run {
            isProgressing.toggle()
        }
        return true
    }
    
    // Private Function
    private func processErrorHandler(errorStatus: changePasswordError, customErrorMessage: String = "") async {
        await MainActor.run {
            progressErrorMessage = customErrorMessage == "" ? errorStatus.rawValue : customErrorMessage
            isProgressError.toggle()
        }
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        await MainActor.run {
            isProgressError.toggle()
            progressErrorMessage = ""
            isProgressing.toggle()
        }
    }
    
    // Subscribe Private Function
    private func subscribeConfirmNewPassword() {
        $confirmNewPassword
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .combineLatest($newPassword)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] returnedConfirmNewPassword, _ in
                if returnedConfirmNewPassword == self?.newPassword && self?.newPassword != "" {
                    self?.isConfirmNewPasswordValid = true
                } else {
                    self?.isConfirmNewPasswordValid = false
                }
            }
            .store(in: &cancellable)
    }
}

extension ChangePasswordViewModel {
    
    enum changePasswordError: String, LocalizedError {
        case passwordNotStrongEnough = "密碼強度不夠"
        case statusCode400 = "內部錯誤，傳入資料錯誤"
        case statusCode403 = "原始密碼錯誤"
        case statusCodeUndefined = "未定義狀態碼"
        case somethingError = "其他錯誤"
    }
}
