//
//  ArticleModel.swift
//  Task
//
//  Created by Łukasz Sypniewski on 20/02/2018.
//  Copyright © 2018 Łukasz Sypniewski. All rights reserved.
//

import CoreData

class ArticleModel {
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
    
    private init() {}
}
