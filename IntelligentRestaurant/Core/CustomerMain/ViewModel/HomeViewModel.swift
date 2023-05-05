//
//  HomeViewModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/5/5.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    
    // Published Variable
    @Published var status : Bool = false
    
    // Private Variable
    private var getTableInfoURL = "http://120.126.151.186/API/eating/food/customer"
    
    // Public Variable
    func getTableInfo(merchantUid: String) {
        let tableInfo = CustomerTableInfoModel(merchantUid: merchantUid)
        Task {
            let getResult = await DatabaseManager.shared.uploadData(to: getTableInfoURL, data: tableInfo, httpMethod: "POST")
            switch getResult {
            case .success(let returnedResult):
                switch returnedResult.1 {
                case 200:
                    let returnedData = returnedResult.0
                    guard let Info = try? JSONDecoder().decode(CustomerTableInfoModel.self, from: returnedData) else {
                        return
                    }
                    await MainActor.run {
                        CustomerShareInfoManager.instance.homeTable = Info
                        status = false
                    }
                    print("success!")
                    print(Info)
//                    print(ShareInfoManager.shared.homeTable.remainTime.indices)
                    break
                default:
                    print(returnedResult.1)
                    await MainActor.run {
                        status = true
                    }
                }
            case .failure(let errorStatus):
                print("fail")
                print(errorStatus.rawValue)
            }
        }
    }
    
    var sortedTable: [RemainTime] {
        CustomerShareInfoManager.instance.homeTable.remainTime.sorted(by: RemainTime.sortByTime)
    }
    var emptyTablePressedDownScreen: [Bool] = []
    
    // 計算空桌數量
    func emptyTableCountFunc() -> Int {
        var count : Int = 0
        
        for index in CustomerShareInfoManager.instance.homeTable.remainTime.indices {
            if CustomerShareInfoManager.instance.homeTable.remainTime[index].remainTime == "0" {
                count += 1
            }
        }
        return count
    }
    
    // 顯示空桌的桌號（存在string裏面）
    func emptyTableString(count: Int) -> String {
        
        var emptyTable: String = ""
        var temp: Int = 0
        
        // 先清空陣列
        self.emptyTablePressedDownScreen.removeAll()
        
        for index in CustomerShareInfoManager.instance.homeTable.remainTime.indices {
            if CustomerShareInfoManager.instance.homeTable.remainTime[index].remainTime == "0" {
                emptyTable.append(CustomerShareInfoManager.instance.homeTable.remainTime[index].tableName)
                self.emptyTablePressedDownScreen.append(true)
                temp += 1
                if temp != count {
                    emptyTable.append(",")
                }
            }
            else {
                self.emptyTablePressedDownScreen.append(false)
            }
        }
        return emptyTable
    }
}
