//
//  RestCall.swift
//  iOS-Task
//
//  Created by Łukasz Sypniewski on 14/02/2018.
//  Copyright © 2018 Łukasz Sypniewski. All rights reserved.
//

import Foundation
import SystemConfiguration

struct Articles: Codable {
    let status: String
    let articles: [ArticleData]
}

struct ArticleData: Codable {
    let source: Source
    let author: String?
    let title: String?
    let description: String?
    var url: URL?
    var urlToImage: URL?
    let publishedAt: String?
}

struct Source: Codable {
    let id: String?
    let name: String?
}

enum DownloadingDataError: Error {
    case NoInternetConnection
    case NoDataDownloaded
    case InvalidDataFormat
    case OtherError
}

class ArticlesProvider {
    enum Endpoints : String {
        case topHeadlines = "/v2/top-headlines"
        case everything = "/v2/everything"
    }
    
    static func downloadData(endpoint: Endpoints, itemsCount: Int, queries: [URLQueryItem], apiKey: String,
                             callBack: @escaping (_ articlesData: Articles?, _ response: URLResponse?, _ error: Error?) -> ())  {
        var urlComponents = URLComponents()
        let queryItems : [URLQueryItem] = [URLQueryItem(name: "pageSize", value: String(itemsCount))] + queries
        urlComponents.scheme = "http"
        urlComponents.host = "newsapi.org"
        urlComponents.path = endpoint.rawValue
        urlComponents.queryItems = queryItems
        
        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.setValue(apiKey, forHTTPHeaderField: "X-Api-Key")
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: urlRequest) {
            (data, response, taskError) in
            do {
                if let data = data {
                    let articlesData = try JSONDecoder().decode(Articles.self, from: data)
                    callBack(articlesData, response, taskError)
                } else {
                    callBack(nil, response, taskError)
                    return
                }
            } catch {
                callBack(nil, response, error)
                return
            }
        }
        task.resume()
    }
    
    static func downloadImage(from url: URL?, callBack: @escaping (_ imageData: Data?) -> ()) {
        guard let url = url else {
            callBack(nil)
            return
        }
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, response, error) in
            guard error == nil, let data = data else {
                callBack(nil)
                return
            }
            callBack(data)
        }
        task.resume()
    }
    
    // Taken from https://stackoverflow.com/questions/25623272/how-to-use-scnetworkreachability-in-swift/25623647#25623647
    static func connectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
}
