//
//  Settings.swift
//  Task
//
//  Created by Łukasz Sypniewski on 28/02/2018.
//  Copyright © 2018 Łukasz Sypniewski. All rights reserved.
//

import Foundation
import UIKit

struct QuerySettings {
    var apiKey: String
    var endpoint: ArticlesProvider.Endpoints
    var itemsCount: Int
    var additionalQueries: [URLQueryItem]
    
    init() {
        apiKey = "2beb5953fd92424983abae1dc1c7d58c"
        endpoint = ArticlesProvider.Endpoints.everything
        itemsCount = 20
        additionalQueries = [URLQueryItem(name: "q", value: "bitcoin"), URLQueryItem(name: "language", value: "pl")]
    }
}
