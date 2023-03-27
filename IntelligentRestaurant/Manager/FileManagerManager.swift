//
//  FileManagerManager.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/3/16.
//

import Foundation

class FileManagerManager {
    
    /// 獲取指定URL
    static func getUrlPath(directory searchPathDirectory: FileManager.SearchPathDirectory,
                                   domainMask searchPathDomainMask: FileManager.SearchPathDomainMask,
                                   pathsName: [String]) -> URL? {
        guard var url = FileManager
            .default
            .urls(for: searchPathDirectory, in: searchPathDomainMask)
            .first else { return nil }
        for pathName in pathsName {
            url = url.appendingPathComponent(pathName)
        }
        return url
    }
    
    /// 如果資料夾不存在就會創建
    static func createFolderIfNotExist(searchPathDirectory: FileManager.SearchPathDirectory,
                                       searchPathDomainMask: FileManager.SearchPathDomainMask,
                                       pathsName: [String]) {
        guard let url = FileManagerManager.getUrlPath(directory: searchPathDirectory, domainMask: searchPathDomainMask, pathsName: pathsName) else { return }
        if !FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.createDirectory(atPath: url.path, withIntermediateDirectories: true)
        }
    }
    
    /// 存擋
    static func saveData(data: Data,
                         searchPathDirectory: FileManager.SearchPathDirectory,
                         searchPathDomainMask: FileManager.SearchPathDomainMask,
                         pathsName: [String]) {
        guard let url = FileManagerManager.getUrlPath(directory: searchPathDirectory, domainMask: searchPathDomainMask, pathsName: pathsName) else { return }
        try? data.write(to: url)
    }
    
    /// 讀取指定位置的資料，並且回傳Data或是nil
    static func loadData(searchPathDirectory: FileManager.SearchPathDirectory,
                         searchPathDomainMask: FileManager.SearchPathDomainMask,
                         pathsName: [String]) -> Data? {
        guard let url = FileManagerManager.getUrlPath(directory: searchPathDirectory, domainMask: searchPathDomainMask, pathsName: pathsName),
              let data = try? Data(contentsOf: url) else { return nil }
        return data
    }
    
    /// 回傳指定資料是否存在
    static func checkFileIsExist(searchPathDirectory: FileManager.SearchPathDirectory,
                                 searchPathDomainMask: FileManager.SearchPathDomainMask,
                                 pathsName: [String]) -> Bool {
        guard let url = FileManagerManager.getUrlPath(directory: searchPathDirectory, domainMask: searchPathDomainMask, pathsName: pathsName)?.path else { return false }
        return FileManager.default.fileExists(atPath: url)
    }
}
