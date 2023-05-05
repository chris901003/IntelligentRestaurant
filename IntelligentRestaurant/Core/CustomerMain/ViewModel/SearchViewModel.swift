//
//  SearchViewModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/5/5.
//

import Foundation

class SearchViewModel: ObservableObject {
    
    // Published variable
    @Published var merchantName: String = ""
    @Published var searchedMerchant: [CustomerMerchantInfoModel] = []
    @Published var showedMerchant = CustomerMerchantInfoModel(customerUid: "", merchantUid: "",name: "")
    @Published var myFavMerchants: [CustomerMerchantInfoModel] = []
    
    // Private variable
    private var searchMerchantURL = "http://120.126.151.186/API/eating/user/customer/keyName"
    private var getMerchantURL = "http://120.126.151.186/API/eating/user/customer/getDetails"
    private var getMyFavListURL = "http://120.126.151.186/API/eating/user/customer/favorite"
    private var putIntoMyFavListURL = "http://120.126.151.186/API/eating/user/customer/favorite"
    private var deleteMyFavItemURL = "http://120.126.151.186/API/eating/user/customer/favorite"
//    private var getTableInfoURL = "http://120.126.151.186/API/eating/food/customer"
    
    // Pubilc function
    func searchMerchantName() {
        let merchantInfo = CustomerMerchantInfoModel(customerUid: CustomerShareInfoManager.instance.customerAccount.id, merchantUid: "", name: merchantName)
        searchedMerchant = []
        
        Task {
            let searchResult = await DatabaseManager.shared.uploadData(to: searchMerchantURL, data: merchantInfo, httpMethod: "POST")
            
            switch searchResult {
            case .success(let returnedResult):
                let returnedData = returnedResult.0
                guard let merchantInfo = try? JSONDecoder().decode([CustomerMerchantInfoModel].self, from: returnedData) else {
                    return
                }
                await MainActor.run {
                    searchedMerchant = merchantInfo
                }
                print("success")
                print(merchantInfo)
                
            case .failure(let errorStatus):
                print(errorStatus.rawValue)
                print("failure")
            }
        }
    }
    
    func getMerchantInfo(customerUid: String, merchantUid: String) {
        let merchantInfo = CustomerMerchantInfoModel(customerUid: customerUid, merchantUid: merchantUid, name: "")
        Task {
            let searchResult = await DatabaseManager.shared.uploadData(to: getMerchantURL, data: merchantInfo, httpMethod: "POST")
            
            switch searchResult {
            case .success(let returnedResult):
                let returnedData = returnedResult.0
                guard let merchantInfo = try? JSONDecoder().decode(CustomerMerchantInfoModel.self, from: returnedData) else {
                    return
                }
                await MainActor.run {
                    showedMerchant = merchantInfo
                }
                print("success")
                print(showedMerchant)
                
            case .failure(let errorStatus):
                print(errorStatus.rawValue)
            }
            
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
    
    func putIntoMyFavList(customerUid: String, merchantUid: String) {
        let merchantInfo = CustomerMerchantInfoModel(customerUid: customerUid, merchantUid: merchantUid, name: "")
        print(customerUid)
        print(merchantUid)
        Task {
            let savedResult = await DatabaseManager.shared.uploadData(to: putIntoMyFavListURL, data: merchantInfo, httpMethod: "PUT")
            
            switch savedResult {
            case .success(let returnedResult):
                switch returnedResult.1 {
                case 200:
                    print("✅ Create Success")
                    break
                default:
                    print(returnedResult.1)
                }
                
            case .failure(let errorStatus):
                print("Create Error: \(errorStatus.rawValue)")
            }
            
        }
    }
    
    func deleteMyFavItem(customerUid: String, merchantUid: String) {
        let merchantInfo = CustomerMerchantInfoModel(customerUid: customerUid, merchantUid: merchantUid, name: "")
        Task {
            let savedResult = await DatabaseManager.shared.uploadData(to: deleteMyFavItemURL, data: merchantInfo, httpMethod: "DELETE")
            
            switch savedResult {
            case .success(let returnedResult):
                switch returnedResult.1 {
                case 200:
                    print("✅ Delete Success")
                    break
                default:
                    print(returnedResult.1)
                }
                
            case .failure(let errorStatus):
                print("Create Error: \(errorStatus.rawValue)")
            }
            
        }
    }
    
//    func getTableInfo(merchantUid: String) {
//        let tableInfo = TableInfoModel(merchantUid: merchantUid)
//        print("getTableInfo")
//        Task {
//            let getResult = await DatabaseManager.shared.uploadData(to: getTableInfoURL, data: tableInfo, httpMethod: "POST")
//            switch getResult {
//            case .success(let returnedResult):
//                let returnedData = returnedResult.0
//                guard let tableInfo = try? JSONDecoder().decode(TableInfoModel.self, from: returnedData) else {
//                    return
//                }
//                await MainActor.run {
//                    ShareInfoManager.shared.homeTable = tableInfo
//                }
//                print("success!")
//                print(tableInfo)
//            case .failure(let errorStatus):
//                print("fail")
//                print(errorStatus.rawValue)
//            }
//        }
//    }
}
