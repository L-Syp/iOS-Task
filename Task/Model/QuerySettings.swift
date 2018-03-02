//
//  QuerySettings.swift
//  Task
//
//  Created by Łukasz Sypniewski on 28/02/2018.
//  Copyright © 2018 Łukasz Sypniewski. All rights reserved.
//

import Foundation
import UIKit

struct QuerySettings {
    var apiKey: String?
    var endpoint: ArticlesProvider.Endpoints?
    var itemsCount: Int?
    var queries: [URLQueryItem]?
    
    enum Keys: String {
        case ApiKey
        case Endpoint
        case ItemsCount
        case Queries
    }
    
    init(apiKey: String, endpoint: ArticlesProvider.Endpoints, itemsCount: Int, queries: [URLQueryItem]) {
        self.apiKey = apiKey
        self.endpoint = endpoint
        self.itemsCount = itemsCount
        self.queries = queries
    }
    
    init() {
        self.apiKey = nil
        self.endpoint = nil
        self.itemsCount = nil
        self.queries = nil
    }
}
