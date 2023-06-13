//
//  CustomerFavoriteViewModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/5/8.
//

import Foundation

class CustomerFavoriteViewModel: ObservableObject {
    
    // Published Variable
    @Published var favoriteMerchantInfo: [CustomerMerchantInfoModel] = []
    
    @Published var isProcess: Bool = false
    @Published var isProcessError: Bool = false
    
    // Public Variable
    var loadingMessage: String = ""
    var errorMessage: String = ""
    
    // Private Variable
    private let uid: String = CustomerShareInfoManager.instance.customerAccount.uid
    private let fetchFavoriteMerchantUrl: String = "http://120.126.151.185/API/eating/user/customer/favorite"
    
    // Init Function
    init() {
        Task { await initFavoriteMerchantInfo() }
    }
    
    // Public Function
    /// 新增或取消最愛店家
    public func toggleFavoriteMerchant(selected: CustomerMerchantInfoModel) async {
        switch selected.favorite {
        case true:
            await removeFavoriteMerchant(selected: selected)
        case false:
            await addFavoriteMerchant(selected: selected)
        }
    }
    
    /// 更新最愛店家
    public func updateFavoriteMerchant() async {
        await MainActor.run {
            loadingMessage = "更新中"
            isProcess.toggle()
        }
        
        let queryFavoriteMerchant = CustomerFetchMerchantDetailModel(customerUid: uid, merchantUid: "")
        let queryResult = await DatabaseManager.shared.uploadData(to: fetchFavoriteMerchantUrl, data: queryFavoriteMerchant)
        var newFavoriteMerchantInfo: [CustomerMerchantInfoModel] = []
        switch queryResult {
        case .success(let returnedResult):
            switch returnedResult.1 {
            case 200:
                let returnedMerchantInfo = try? JSONDecoder().decode([CustomerMerchantInfoModel].self, from: returnedResult.0)
                guard let returnedMerchantInfo = returnedMerchantInfo else {
                    await processErrorHandler(errorStatus: UpdateMerchantInfoError.dataTransferError)
                    return
                }
                let favorite = returnedMerchantInfo.compactMap { $0.favorite ? $0 : nil }
                newFavoriteMerchantInfo = favorite
            default:
                let serverMessage = returnedResult.0.tranformToString()
                guard let serverMessage = serverMessage else {
                    await processErrorHandler(errorStatus: UpdateMerchantInfoError.serverMessageError)
                    return
                }
                await processErrorHandler(errorStatus: UpdateMerchantInfoError.serverMessageError, customMessage: serverMessage)
                return
            }
        case .failure(_):
            await processErrorHandler(errorStatus: UpdateMerchantInfoError.internetError)
            return
        }
        
        var removeUids: [String] = []
        for info in favoriteMerchantInfo {
            let infoIdx = newFavoriteMerchantInfo.firstIndex { $0.uid == info.uid }
            if let _ = infoIdx { continue }
            removeUids.append(info.uid)
        }
        for removeUid in removeUids {
            let idx = favoriteMerchantInfo.firstIndex { $0.uid == removeUid }
            guard let idx = idx else {
                await processErrorHandler(errorStatus: UpdateMerchantInfoError.neverFail)
                return
            }
            await MainActor.run {
                let _ = favoriteMerchantInfo.remove(at: idx)
            }
        }
        
        for newMerchant in newFavoriteMerchantInfo {
            let idx = favoriteMerchantInfo.firstIndex { $0.uid == newMerchant.uid }
            if let _ = idx { continue }
            await MainActor.run { favoriteMerchantInfo.append(newMerchant) }
        }
        
        
        await MainActor.run {
            isProcess.toggle()
            loadingMessage = ""
        }
    }
    
    // Private Function
    /// 初始化獲取最愛商家資訊
    private func initFavoriteMerchantInfo() async {
        await MainActor.run {
            loadingMessage = "加載中"
            isProcess.toggle()
        }
        
        let queryModel = CustomerFetchMerchantDetailModel(customerUid: uid, merchantUid: "")
        let queryResult = await DatabaseManager.shared.uploadData(to: fetchFavoriteMerchantUrl, data: queryModel)
        switch queryResult {
        case .success(let returnedResult):
            switch returnedResult.1 {
            case 200:
                let returnedMerchantInfo = try? JSONDecoder().decode([CustomerMerchantInfoModel].self, from: returnedResult.0)
                guard let returnedMerchantInfo = returnedMerchantInfo else {
                    await processErrorHandler(errorStatus: InitFavoriteMerchantInfoError.dataTransferError)
                    return
                }
                let favorite = returnedMerchantInfo.compactMap { $0.favorite ? $0 : nil }
                await MainActor.run {
                    favoriteMerchantInfo = favorite
                }
            case 403:
                await processErrorHandler(errorStatus: InitFavoriteMerchantInfoError.neverFail)
                return
            default:
                let serverMessage = returnedResult.0.tranformToString()
                guard let serverMessage = serverMessage else {
                    await processErrorHandler(errorStatus: InitFavoriteMerchantInfoError.serverMessage)
                    return
                }
                await processErrorHandler(errorStatus: InitFavoriteMerchantInfoError.serverMessage, customMessage: serverMessage)
                return
            }
        case .failure(_):
            await processErrorHandler(errorStatus: InitFavoriteMerchantInfoError.internetError)
            return
        }
        await MainActor.run {
            isProcess.toggle()
            loadingMessage = ""
        }
    }
    
    /// 添加最愛店家
    private func addFavoriteMerchant(selected: CustomerMerchantInfoModel) async {
        await MainActor.run {
            loadingMessage = "新增中"
            isProcess.toggle()
        }
        
        let addFavoriteModel = CustomerFetchMerchantDetailModel(customerUid: uid, merchantUid: selected.uid)
        let addResult = await DatabaseManager.shared.uploadData(to: fetchFavoriteMerchantUrl, data: addFavoriteModel, httpMethod: "Put")
        switch addResult {
        case .success(let returnedResult):
            switch returnedResult.1 {
            case 200:
                break
            case 403:
                await processErrorHandler(errorStatus: UpdateFavoriteMerchantError.neverFail)
                return
            default:
                let serverMessage = returnedResult.0.tranformToString()
                guard let serverMessage = serverMessage else {
                    await processErrorHandler(errorStatus: UpdateFavoriteMerchantError.serverMessageError)
                    return
                }
                await processErrorHandler(errorStatus: UpdateFavoriteMerchantError.serverMessageError, customMessage: serverMessage)
                return
            }
        case .failure(_):
            await processErrorHandler(errorStatus: UpdateFavoriteMerchantError.internetError)
            return
        }
        
        let idx = favoriteMerchantInfo.firstIndex { $0.uid == selected.uid }
        guard let idx = idx else {
            await processErrorHandler(errorStatus: UpdateFavoriteMerchantError.neverFail)
            return
        }
        await MainActor.run {
            favoriteMerchantInfo[idx].favorite = true
        }
        
        await MainActor.run {
            isProcess.toggle()
            loadingMessage = ""
        }
    }
    
    /// 移除最愛店家
    private func removeFavoriteMerchant(selected: CustomerMerchantInfoModel) async {
        await MainActor.run {
            loadingMessage = "移除中"
            isProcess.toggle()
        }
        
        let removeFavoriteModel = CustomerFetchMerchantDetailModel(customerUid: uid, merchantUid: selected.uid)
        let removeResult = await DatabaseManager.shared.uploadData(to: fetchFavoriteMerchantUrl, data: removeFavoriteModel, httpMethod: "Delete")
        switch removeResult {
        case .success(let returnedResult):
            switch returnedResult.1 {
            case 200:
                break
            default:
                let serverMessage = returnedResult.0.tranformToString()
                guard let serverMessage = serverMessage else {
                    await processErrorHandler(errorStatus: UpdateFavoriteMerchantError.serverMessageError)
                    return
                }
                await processErrorHandler(errorStatus: UpdateFavoriteMerchantError.serverMessageError, customMessage: serverMessage)
                return
            }
        case .failure(_):
            await processErrorHandler(errorStatus: UpdateFavoriteMerchantError.internetError)
            return
        }
        
        let idx = favoriteMerchantInfo.firstIndex { $0.uid == selected.uid }
        guard let idx = idx else {
            await processErrorHandler(errorStatus: UpdateFavoriteMerchantError.neverFail)
            return
        }
        await MainActor.run {
            favoriteMerchantInfo[idx].favorite = false
        }
        
        await MainActor.run {
            isProcess.toggle()
            loadingMessage = ""
        }
    }
}

extension CustomerFavoriteViewModel {
    /// 處理中發生錯誤
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

extension CustomerFavoriteViewModel {
    enum InitFavoriteMerchantInfoError: String, LocalizedError {
        case internetError = "網路發生錯誤"
        case neverFail = "不可能發生此錯誤"
        case serverMessage = "服務器回傳訊息"
        case dataTransferError = "資料轉換錯誤"
    }
    enum UpdateFavoriteMerchantError: String, LocalizedError {
        case internetError = "網路發生錯誤"
        case serverMessageError = "服務器回傳訊息"
        case neverFail = "不可能發生此錯誤"
    }
    enum UpdateMerchantInfoError: String, LocalizedError {
        case internetError = "網路發生錯誤"
        case serverMessageError = "服務器回傳訊息"
        case dataTransferError = "資料轉換錯誤"
        case neverFail = "不可能發生此錯誤"
    }
}
