//
//  LoginViewModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/3/8.
//

import Foundation
import LocalAuthentication
import CoreLocation

class LoginViewModel: ObservableObject {
    
    // Published Variable
    @Published var account: String = ""
    @Published var password: String = ""
    @Published var isProcessing: Bool = false
    @Published var isProcessingError: Bool = false
    @Published var processingErrorMessage: String = ""
    @Published var isRememberAccount: Bool = false
    
    // 使用生物識別登陸相關
    @Published var isLoginBefore: Bool = false
    private let accountSavePath: [String] = ["IntelligentRestaurant", "Account", "account.json"]
    private var lastLoginAccount: String = ""
    private var bioContext = LAContext()
    @Published private(set) var biometryType: LABiometryType = .none
    private(set) var canEvaluatePolicy: Bool = false
    @Published private(set) var isAuthenticated = false
    
    // 創建帳號相關
    @Published var isShowSelectCreateAccountMode: Bool = false
    
    // Private Variable
    private var loginUrl: String = "http://120.126.151.186/API/eating/user/login"
    
    // Init Function
    init() {
        getBiometryType()
        getLastLoginAccount()
    }
    
    /// 進行生物辨識
    func authenticateWithBiometrics() async {
        bioContext = LAContext()
        if canEvaluatePolicy {
            let reason = "用來登陸帳號使用"
            guard let success = try? await bioContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason),
                  success == true else { return }
            let recordPasswordResult = KeyChainManager.getKey(name: lastLoginAccount)
            switch recordPasswordResult {
            case.success(let recordPassword):
                await MainActor.run {
                    account = lastLoginAccount
                    password = recordPassword
                    isRememberAccount = false
                }
                await login()
            case .failure(let error):
                await MainActor.run {
                    processingErrorMessage = error.localizedDescription
                    isProcessingError = true
                }
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                await MainActor.run {
                    isProcessingError = false
                    processingErrorMessage = ""
                }
            }
        }
    }
    
    // Public Function
    func login() async {
        
        await MainActor.run {
            isProcessing.toggle()
        }
        
        if account == "" {
            await loginAccountErrorHandler(errorStatus: .emailIsEmpty)
            return
        }
        
        // 處理登錄相關資料
        let merchantAccount = MerchantAccountModel(name: "", phoneNumber: "", email: account, photo: Data(), password: password, location: CLLocationCoordinate2D(), intro: "")
        
        let loginResult = await DatabaseManager.shared.uploadData(to: loginUrl, data: merchantAccount)
        switch loginResult {
        case .success(let returnedInfo):
            switch returnedInfo.1 {
            case 200:
                guard let returnedAccountInfo = try? JSONDecoder().decode(MerchantAccountModel.self, from: returnedInfo.0) else {
                    await loginAccountErrorHandler(errorStatus: .accountInfoTransferError)
                    return
                }
                await MainActor.run {
                    MerchantShareInfoManager.instance.merchantAccount = returnedAccountInfo
                    MerchantShareInfoManager.instance.merchantAccount.password = password
                }
            case 400:
                await loginAccountErrorHandler(errorStatus: .statusCode400)
                return
            case 403:
                await loginAccountErrorHandler(errorStatus: .statusCode403)
                return
            default:
                await loginAccountErrorHandler(errorStatus: .statusCodeUndefine)
                return
            }
        case .failure(let errorStatus):
            await loginAccountErrorHandler(errorStatus: .somethingError, customErrorMessage: errorStatus.rawValue)
            return
        }
        
        if isRememberAccount {
            // 將帳號密碼保存，下次可使用生物辨識登陸(最後一步在做)
            guard let accountJsonData = try? JSONEncoder().encode(account) else { return }
            FileManagerManager.createFolderIfNotExist(searchPathDirectory: .documentDirectory, searchPathDomainMask: .userDomainMask, pathsName: ["IntelligentRestaurant", "Account"])
            FileManagerManager.saveData(data: accountJsonData, searchPathDirectory: .documentDirectory, searchPathDomainMask: .userDomainMask, pathsName: accountSavePath)
            KeyChainManager.deleteKey(name: account)
            let _ = KeyChainManager.createNewKey(name: account, key: password)
        }
        
        await MainActor.run {
            isProcessing.toggle()
            MerchantShareInfoManager.instance.isLogin = true
        }
    }
    
    // Private Function
    /// 獲取裝置可使用的生物識別方式
    private func getBiometryType() {
        canEvaluatePolicy = bioContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        biometryType = bioContext.biometryType
    }
    
    /// 檢查並且讀取上次保存登陸的帳號
    private func getLastLoginAccount() {
        if !FileManagerManager.checkFileIsExist(searchPathDirectory: .documentDirectory, searchPathDomainMask: .userDomainMask, pathsName: accountSavePath) { return }
        guard let accountData = FileManagerManager.loadData(searchPathDirectory: .documentDirectory, searchPathDomainMask: .userDomainMask, pathsName: accountSavePath) else { return }
        guard let account = try? JSONDecoder().decode(String.self, from: accountData) else { return }
        lastLoginAccount = account
        isLoginBefore = true
    }
    
    /// 處理登陸時發生錯誤
    private func loginAccountErrorHandler(errorStatus: loginMerchantAccountError, customErrorMessage: String = "") async {
        await MainActor.run {
            processingErrorMessage = customErrorMessage == "" ? errorStatus.rawValue : customErrorMessage
            isProcessingError.toggle()
        }
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        await MainActor.run {
            isProcessing.toggle()
            isProcessingError.toggle()
            processingErrorMessage = ""
        }
        return
    }
}

extension LoginViewModel {
    
    enum loginMerchantAccountError: String, LocalizedError {
        case emailIsEmpty = "帳號不可為空"
        case statusCode400 = "內部錯誤，傳入資料錯誤"
        case statusCode403 = "帳號或密碼錯誤(帳號請填電子郵件)"
        case statusCodeUndefine = "狀態碼未定義"
        case accountInfoTransferError = "帳號資料轉換錯誤"
        case somethingError = "發生其他錯誤"
    }
}
