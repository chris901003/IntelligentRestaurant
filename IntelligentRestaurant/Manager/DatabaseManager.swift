//
//  DatabaseManager.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/3/20.
//

import Foundation

class DatabaseManager {
    
    // Singleton
    static let shared: DatabaseManager = DatabaseManager()
    
    // Init Function
    private init() { }
    
    // Private Variable
    private var jsonEncoder = JSONEncoder()
    
    // Public Function
    /// 將資料上傳到資料庫
    func uploadData(to urlString: String, data: Encodable, httpMethod: String = "POST", timeout: Double = 5) async -> Result<(Data, Int), uploadDataError> {
        guard let url = URL(string: urlString) else { return .failure(.urlError) }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let data = try? jsonEncoder.encode(data) else { return .failure(.encodeError) }
        request.httpBody = data
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = timeout
        configuration.timeoutIntervalForRequest = timeout
        let session = URLSession(configuration: configuration)
        do {
            let (data, response) = try await session.data(for: request)
            guard let response = response as? HTTPURLResponse else { return .failure(.responseCodeError) }
            let statusCode = response.statusCode
            return .success((data, statusCode))
        } catch {
            switch error.localizedDescription {
            case "The request timed out.":
                return .failure(.responseTimeOut)
            default:
                return .failure(.httpConnectError)
            }
        }
    }
}

extension DatabaseManager {
    
    /// 處理上傳資料相關錯誤
    enum uploadDataError: String, LocalizedError {
        case urlError = "URL格式錯誤"
        case encodeError = "資料Encode失敗"
        case httpConnectError = "網路發生錯誤，請稍後再試"
        case responseCodeError = "Http狀態碼錯誤"
        case responseTimeOut = "請求超時"
    }
}
