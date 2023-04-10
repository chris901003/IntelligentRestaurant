//
//  MerchantAccountViewModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/3/11.
//

import Foundation
import SwiftUI
import CoreLocation
import PhotosUI

class MerchantAccountViewModel: ObservableObject {
    
    // Published Variable
    @Published var name: String = ""
    @Published var photo: UIImage? = nil
    @Published var phoneNumber: String = ""
    @Published var emailAddress: String = ""
    @Published var password: String = ""
    @Published var location: CLLocationCoordinate2D = CLLocationCoordinate2D()
    @Published var intro: String = ""
    
    @Published var selectedImageItem: PhotosPickerItem? = nil
    @Published var selectedImageData: Data? = nil
    
    @Published var isProgressing: Bool = false
    @Published var isProgressError: Bool = false
    @Published var progressErrorMessage: String = ""
    @Published var isShowSaveSuccess: Bool = false
    
    // Private Variable
    private var updateLink: String = "http://120.126.151.186/API/eating/user"
    private var originalAccountInfo: MerchantAccountModel = MerchantAccountModel()
    private var accountUid: String = ""
    
    // Init Function
    init() {
        let merchantAccountInfo = MerchantShareInfoManager.instance.merchantAccount
        originalAccountInfo = merchantAccountInfo
        name = merchantAccountInfo.name
        phoneNumber = merchantAccountInfo.phoneNumber
        emailAddress = merchantAccountInfo.email
        password = merchantAccountInfo.password
        location = merchantAccountInfo.location
        intro = merchantAccountInfo.intro
        accountUid = merchantAccountInfo.uid
        if let image = UIImage(data: MerchantShareInfoManager.instance.merchantAccount.photo) {
            photo = image
        }
        if intro.count == 0 {
            intro = "(增加更多資訊...)"
        }
    }
    
    // Public Function
    func transferSelectedImage() async {
        guard let selectedImageItem = selectedImageItem else { return }
        if let data = try? await selectedImageItem.loadTransferable(type: Data.self) {
            await MainActor.run {
                selectedImageData = data
            }
        }
    }
    
    // 檢查是否有修改
    func checkIsModify() -> Bool {
        if name != originalAccountInfo.name || selectedImageData != nil || phoneNumber != originalAccountInfo.phoneNumber || emailAddress != originalAccountInfo.email || password != originalAccountInfo.password || location.latitude != originalAccountInfo.location.latitude || location.longitude != location.longitude || (intro != originalAccountInfo.intro && intro != "(增加更多資訊...)") { return true }
        return false
    }
    
    /// 將資料還原
    func resetUserInfo() {
        name = originalAccountInfo.name
        phoneNumber = originalAccountInfo.phoneNumber
        emailAddress = originalAccountInfo.email
        password = originalAccountInfo.password
        location = originalAccountInfo.location
        intro = originalAccountInfo.intro
        selectedImageItem = nil
        selectedImageData = nil
        if intro.count == 0 {
            intro = "(增加更多資訊...)"
        }
    }
    
    /// 更新帳號資料
    func changeMerchantAccount() async {
        await MainActor.run {
            isProgressing.toggle()
        }
        
        if name.count == 0 {
            await updateMerchantAccountErrorHandler(errorStatus: .emptyName)
            return
        }
        
        if phoneNumber.count != 0 && phoneNumber.count != 10 {
            await updateMerchantAccountErrorHandler(errorStatus: .phoneNumberLen)
            return
        }
        
        if emailAddress.count != 0 && !emailAddress.isValidEmail() {
            await updateMerchantAccountErrorHandler(errorStatus: .emailFormat)
            return
        }
        
        var newMerchantAccountInfo = MerchantAccountModel(uid: accountUid, name: name, phoneNumber: phoneNumber, email: emailAddress, photo: Data(), password: password, location: location, intro: intro)
        if selectedImageData != nil {
            newMerchantAccountInfo.photo = (UIImage(data: selectedImageData!)?.jpegData(compressionQuality: 0)!)!
        }
        let updateResult = await DatabaseManager.shared.uploadData(to: updateLink, data: newMerchantAccountInfo, httpMethod: "Put")
        switch updateResult {
        case .success(let updateInfo):
            switch updateInfo.1 {
            case 200:
                MerchantShareInfoManager.instance.merchantAccount = newMerchantAccountInfo
            default:
                await updateMerchantAccountErrorHandler(errorStatus: .stateCodeUndefined)
                return
            }
        case .failure(let errorStatus):
            await updateMerchantAccountErrorHandler(errorStatus: .somethingError, customErrorMessage: errorStatus.rawValue)
            return
        }
        
        await MainActor.run {
            isProgressing.toggle()
        }
        
        Task { await showSaveSuccess() }
    }
    
    /// 刪除帳號
    func deleteMerchantAccount() async {
        await MainActor.run {
            isProgressing.toggle()
        }
        
        let merchantAccountInfo = MerchantShareInfoManager.instance.merchantAccount
        let deleteResult = await DatabaseManager.shared.uploadData(to: updateLink, data: merchantAccountInfo, httpMethod: "Delete")
        switch deleteResult {
        case .success(let returnInfo):
            switch returnInfo.1 {
            case 200:
                break
            default:
                await updateMerchantAccountErrorHandler(errorStatus: .stateCodeUndefined)
                return
            }
        case .failure(let errorStatus):
            await updateMerchantAccountErrorHandler(errorStatus: .somethingError, customErrorMessage: errorStatus.rawValue)
            return
        }
        
        await MainActor.run {
            MerchantShareInfoManager.instance.isLogin = false
            isProgressing.toggle()
        }
    }
    
    // Private Function
    /// 處理在保存帳號時的意外
    private func updateMerchantAccountErrorHandler(errorStatus: SavingAccountError, customErrorMessage: String = "") async {
        await MainActor.run {
            progressErrorMessage = customErrorMessage == "" ? errorStatus.rawValue : customErrorMessage
            isProgressError.toggle()
        }
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        await MainActor.run {
            isProgressError.toggle()
            progressErrorMessage = ""
            isProgressing.toggle()
        }
    }
    
    /// 成功更新動畫
    private func showSaveSuccess() async {
        await MainActor.run {
            isShowSaveSuccess.toggle()
        }
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        await MainActor.run {
            isShowSaveSuccess.toggle()
        }
    }
}

extension MerchantAccountViewModel {
    
    enum SavingAccountError: String, LocalizedError {
        case emptyName = "名稱不可為空"
        case phoneNumberLen = "電話長度有誤"
        case emailFormat = "電子郵件格式錯誤"
        case passwordNotEnoughStrong = "密碼強度不夠"
        case stateCodeUndefined = "未定義狀態碼"
        case somethingError = "發生其他錯誤"
    }
}
