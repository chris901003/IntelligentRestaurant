//
//  CustomerSearchViewModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/5/5.
//

import Foundation

class CustomerSearchViewModel: ObservableObject {
    
    // Published variable
    @Published var merchantName: String = ""
    @Published var searchedMerchant: [CustomerMerchantInfoModel] = []
    @Published var showedMerchant = CustomerMerchantInfoModel(customerUid: "", merchantUid: "",name: "")
    @Published var myFavMerchants: [CustomerMerchantInfoModel] = []
    
    @Published var isProcess: Bool = false
    @Published var isProcessError: Bool = false
    
    // Public Variable
    var loadingMessage: String = ""
    var errorMessage: String = ""
    
    // Private variable
    private var searchMerchantURL = "http://120.126.151.185/API/eating/user/customer/keyName"
    private var getMerchantDetailURL = "http://120.126.151.185/API/eating/user/customer/getDetails"
    private var getMyFavListURL = "http://120.126.151.185/API/eating/user/customer/favorite"
    private var addFavoriateMerchant = "http://120.126.151.185/API/eating/user/customer/favorite"
    private var deleteFavoriateMerchant = "http://120.126.151.185/API/eating/user/customer/favorite"
    private let uid: String = CustomerShareInfoManager.instance.customerAccount.uid
    
    // Pubilc function
    /// 搜尋店家
    func searchMerchantName() async {
        await MainActor.run {
            loadingMessage = "搜尋中"
            isProcess.toggle()
        }
        
        let queryModel = CustomerSearchMerchantModel(name: merchantName, customerUid: uid)
        let searchResult = await DatabaseManager.shared.uploadData(to: searchMerchantURL, data: queryModel)
        switch searchResult {
        case .success(let returnedResult):
            switch returnedResult.1 {
            case 200:
                guard let merchantInfo = try? JSONDecoder().decode([CustomerMerchantInfoModel].self, from: returnedResult.0) else {
                    await processErrorHandler(errorStatus: SearchMerchantError.dataTransformError)
                    return
                }
                await MainActor.run {
                    searchedMerchant = merchantInfo
                }
            default:
                break
            }
        case .failure(_):
            await processErrorHandler(errorStatus: SearchMerchantError.internetError)
            return
        }
        
        await MainActor.run {
            isProcess = false
            loadingMessage = ""
        }
    }
    
    /// 獲取商家詳細資訊
    func getMerchantInfo(merchantUid: String) async {
        await MainActor.run {
            loadingMessage = "讀取店家資訊中"
            isProcess.toggle()
        }

        let queryModel = CustomerFetchMerchantDetailModel(customerUid: uid, merchantUid: merchantUid)
        let searchResult = await DatabaseManager.shared.uploadData(to: getMerchantDetailURL, data: queryModel)
        switch searchResult {
        case .success(let returnedResult):
            switch returnedResult.1 {
            case 200:
                guard let merchantDetail = try? JSONDecoder().decode(CustomerMerchantInfoModel.self, from: returnedResult.0) else {
                    await processErrorHandler(errorStatus: SearchMerchantError.dataTransformError)
                    return
                }
                let idx = searchedMerchant.firstIndex { $0.uid == merchantDetail.uid }
                guard let idx = idx else {
                    await processErrorHandler(errorStatus: SearchMerchantError.neverFail)
                    return
                }
                await MainActor.run {
                    searchedMerchant[idx] = merchantDetail
                    showedMerchant = merchantDetail
                }
            default:
                await processErrorHandler(errorStatus: SearchMerchantError.neverFail)
                return
            }
        case .failure(_):
            await processErrorHandler(errorStatus: SearchMerchantError.internetError)
            return
        }
        
        await MainActor.run {
            isProcess.toggle()
            loadingMessage = ""
        }
    }
    
    func getMyFavList() {
        let merchantInfo = CustomerMerchantInfoModel(customerUid: CustomerShareInfoManager.instance.customerAccount.id, merchantUid: "", name: "")
        Task {
            let listResult = await DatabaseManager.shared.uploadData(to: getMyFavListURL, data: merchantInfo, httpMethod: "POST")
            
            switch listResult {
            case .success(let returnedResult):
                let returnData = returnedResult.0
                guard let merchantInfo = try? JSONDecoder().decode([CustomerMerchantInfoModel].self, from: returnData) else {
                    return
                }
                await MainActor.run{
                    myFavMerchants = merchantInfo
                }
                print(merchantInfo)
                
            case .failure(let errorStatus):
                print(errorStatus.rawValue)
            }
            
        }
        
    }
    
    /// 添加到喜好店家中
    func putIntoMyFavList(merchantUid: String) async {
        await MainActor.run {
            loadingMessage = "添加中"
            isProcess.toggle()
        }
        
        let queryModel = CustomerFetchMerchantDetailModel(customerUid: uid, merchantUid: merchantUid)
        let saveResult = await DatabaseManager.shared.uploadData(to: addFavoriateMerchant, data: queryModel, httpMethod: "PUT")
        switch saveResult {
        case .success(let returnedResult):
            switch returnedResult.1 {
            case 200:
                let idx = searchedMerchant.firstIndex { $0.uid == merchantUid }
                guard let idx = idx else {
                    await processErrorHandler(errorStatus: UpdateFavoriateMerchantError.neverFail)
                    return
                }
                await MainActor.run {
                    searchedMerchant[idx].favorite = true
                    if searchedMerchant[idx].uid == showedMerchant.uid {
                        showedMerchant.favorite = true
                    }
                }
            default:
                await processErrorHandler(errorStatus: UpdateFavoriateMerchantError.neverFail)
                return
            }
        case .failure(_):
            await processErrorHandler(errorStatus: UpdateFavoriateMerchantError.internetError)
            return
        }
        
        await MainActor.run {
            loadingMessage = ""
            isProcess = false
        }
    }
    
    /// 移除喜好店家
    func deleteMyFavItem(merchantUid: String) async {
        await MainActor.run {
            loadingMessage = "刪除中"
            isProcess.toggle()
        }
        
        let queryModel = CustomerFetchMerchantDetailModel(customerUid: uid, merchantUid: merchantUid)
        let deleteResult = await DatabaseManager.shared.uploadData(to: deleteFavoriateMerchant, data: queryModel, httpMethod: "Delete")
        switch deleteResult {
        case .success(let returnedResult):
            switch returnedResult.1 {
            case 200:
                let idx = searchedMerchant.firstIndex { $0.uid == merchantUid }
                guard let idx = idx else {
                    await processErrorHandler(errorStatus: UpdateFavoriateMerchantError.neverFail)
                    return
                }
                await MainActor.run {
                    searchedMerchant[idx].favorite = false
                    if searchedMerchant[idx].uid == showedMerchant.uid {
                        showedMerchant.favorite = false
                    }
                }
            default:
                await processErrorHandler(errorStatus: UpdateFavoriateMerchantError.internetError)
                return
            }
        case .failure(_):
            await processErrorHandler(errorStatus: UpdateFavoriateMerchantError.internetError)
            return
        }
        
        await MainActor.run {
            isProcess = false
            loadingMessage = ""
        }
    }
    
    // Private Function
    /// 處理中發生錯誤
    private func processErrorHandler(errorStatus: any RawRepresentable, customMessage: String = "") async {
        await MainActor.run {
            errorMessage = customMessage.isEmpty ? errorStatus.rawValue as! String : customMessage
            isProcessError.toggle()
        }
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        await MainActor.run {
            isProcessError.toggle()
            isProcess = false
            errorMessage = ""
            loadingMessage = ""
        }
    }
}

extension CustomerSearchViewModel {
    enum SearchMerchantError: String, LocalizedError {
        case internetError = "網路發生錯誤，請確認網路狀態"
        case dataTransformError = "資料轉換錯誤"
        case neverFail = "不可能發生此錯誤"
    }
    enum UpdateFavoriateMerchantError: String, LocalizedError {
        case internetError = "網路發生錯誤，請確認網路狀態"
        case neverFail = "不可能發生此錯誤"
    }
}
