//
//  CreateAccountViewModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/3/10.
//

import Foundation
import SwiftUI
import PhotosUI
import Combine

class CreateMerchantAccountViewModel: ObservableObject {
    
    // Published Variable
    @Published var selectedPhotoItem: PhotosPickerItem? = nil
    @Published var selectedPhotoData: Data? = nil
    @Published var isShowMap: Bool = false
    @Published var isPasswordSame: Bool = false
    @Published var isProgressing: Bool = false
    @Published var isProgressError: Bool = false
    @Published var progressErrorMessage: String = ""
    
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var location: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    // Private Varibale
    private var confirmPasswordCancellable: AnyCancellable? = nil
    private var registerUrl: String = "http://120.126.151.186/API/eating/user/signin"
    
    // Init Function
    init() {
        subscribeConfirmPassword()
    }
    
    // Published Function
    /// 創建新帳號
    func createNewAccount() async -> Bool {
        await MainActor.run {
            isProgressing.toggle()
        }
        
        if name.count == 0 {
            await createMerchantAccountErrorHandler(errorStatus: .nameIsEmpty)
            return false
        }
        if email.count == 0 {
            await createMerchantAccountErrorHandler(errorStatus: .emailIsEmpty)
            return false
        }
        if !email.isValidEmail() {
            await createMerchantAccountErrorHandler(errorStatus: .invalidEmailAddress)
            return false
        }
        if password.count == 0 {
            await createMerchantAccountErrorHandler(errorStatus: .passwordIsEmpty)
            return false
        }
        if !isPasswordSame {
            await createMerchantAccountErrorHandler(errorStatus: .confirmPasswordNotSame)
            return false
        }
        
        let merchantAccount = MerchantAccountModel(name: name, phoneNumber: "未知", email: email, photoLink: "", password: password, location: location, intro: "")
        
        let registerResult = await DatabaseManager.shared.uploadData(to: registerUrl, data: merchantAccount)
        switch registerResult {
        case .success(let returnedInfo):
            switch returnedInfo.1 {
            case 200:
                break
            case 401:
                await createMerchantAccountErrorHandler(errorStatus: .statusCode401)
                return false
            default:
                let errorMessage = try? JSONDecoder().decode(String.self, from: returnedInfo.0)
                await createMerchantAccountErrorHandler(errorStatus: .statusCodeUndefined, customErrorMessage: errorMessage ?? "無法獲取資訊")
                return false
            }
        case .failure(let errorStatus):
            await createMerchantAccountErrorHandler(errorStatus: .somethingError, customErrorMessage: errorStatus.rawValue)
            return false
        }
        
        if selectedPhotoData != nil {
            guard let url = URL(string: "http://120.126.151.186/API/eating/user/photo") else {
                await createMerchantAccountErrorHandler(errorStatus: .uploadImageUrlError)
                return false
            }
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            var userPhotoUpload = UserPhotoUpload(email: email, password: password, image: selectedPhotoData!)
            guard let data = try? JSONEncoder().encode(userPhotoUpload) else { return false }
            request.httpBody = data
            guard let (data, response) = try? await URLSession.shared.data(for: request) else {
                print("❌ Fail upload image")
                return false
            }
            guard let response = response as? HTTPURLResponse else {
                return false
            }
            print(response.statusCode)
        }
    
        await MainActor.run {
            isProgressing.toggle()
        }
        return true
    }
    
    // Private Function
    private func createMerchantAccountErrorHandler(errorStatus: createMerchantAccountError, customErrorMessage: String = "") async {
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
    
    // Subscribe Private Function
    private func subscribeConfirmPassword() {
        confirmPasswordCancellable = $confirmPassword
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .combineLatest($password)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.isPasswordSame = $0 == $1 && $0.count > 0
            }
    }
}

extension CreateMerchantAccountViewModel {
    
    enum createMerchantAccountError: String, LocalizedError {
        case internalError = "內部錯誤"
        case nameIsEmpty = "名稱不可為空"
        case emailIsEmpty = "電子郵件不可為空"
        case passwordIsEmpty = "須設定密碼"
        case invalidEmailAddress = "不合法的電子郵件"
        case confirmPasswordNotSame = "確認密碼不符合"
        case somethingError = "存在錯誤"
        case statusCode401 = "帳號已存在"
        case statusCodeUndefined = "未定義狀態碼"
        case uploadImageUrlError = "圖片上傳網址錯誤"
    }
}

struct UserPhotoUpload: Encodable {
    var email: String
    var password: String
    var image: Data
    var role: String = "Merchant"
}
