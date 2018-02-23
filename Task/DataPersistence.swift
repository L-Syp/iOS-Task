//
//  DataPersistence.swift
//  Task
//
//  Created by Łukasz Sypniewski on 20/02/2018.
//  Copyright © 2018 Łukasz Sypniewski. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class DataPersistence {
    static private func persistSaveArticle(_ article: ArticleClass) -> Article {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let entity = Article(context: context)
        entity.author = article.author
        entity.articleDescription = article.description
        entity.publishedAt = article.publishedAt
        entity.sourceID = article.sourceID
        entity.sourceName = article.sourceName
        entity.title = article.title
        entity.url = article.url
        entity.urlToImage = article.urlToImage
        return entity
    }
    
    static func persistSaveArticle(_ article: ArticleClass, imageData: Data?) {
        let entity = persistSaveArticle(article)
        entity.image = imageData
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    static func persistLoadAtricle() -> [ArticleClass] {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        var articles = [ArticleClass]()
        do {
            let articleCacheArray = try context.fetch(Article.fetchRequest())
            
            print(articleCacheArray.count)
            for i in 0..<articleCacheArray.count {
                let entity: Article = articleCacheArray[i] as! Article
                let source = Source(id: entity.sourceID, name: entity.sourceName)
                let articleData = ArticleData(source: source, author: entity.author, title: entity.title, description: entity.articleDescription,
                                              url: entity.url, urlToImage: entity.url, publishedAt: entity.publishedAt)
                if let data = entity.image {
                articles.append(ArticleClass(with: articleData, image: UIImage(data: data)))
                } else {
                    articles.append(ArticleClass(with: articleData, image: nil))
                }
            }
        } catch {
            fatalError("Fetching articles failed!")
        }
        return articles
    }
    
    static func persistDeleteData() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            let articleCacheArray = try context.fetch(Article.fetchRequest())
            for i in 0..<articleCacheArray.count {
                context.delete(articleCacheArray[i] as! NSManagedObject)
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
            }
        } catch {
            fatalError("Deleting articles failed!")
        }
    }
    
    static func getEntitiesCount() -> Int {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            let articleCacheArray = try context.fetch(Article.fetchRequest())
            return articleCacheArray.count
        } catch {
            fatalError("Deleting articles failed!")
        }
    }
}
