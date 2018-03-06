//
//  ArticleController.swift
//  iOS-Task
//
//  Created by Łukasz Sypniewski on 14/02/2018.
//  Copyright © 2018 Łukasz Sypniewski. All rights reserved.
//

import CoreData

class ArticleController {
    enum Endpoints : String {
        case topHeadlines = "/v2/top-headlines"
        case everything = "/v2/everything"
    }
    
    static func downloadData(withSettings settings: Settings,
                             callBack: @escaping (_ articlesData: ArticleModel.Articles?, _ response: URLResponse?, _ error: Error?) -> ())  {
        var urlComponents = URLComponents()
        let queryItems : [URLQueryItem] = [URLQueryItem(name: "pageSize", value: String(settings.itemsCount!))] + settings.queries!
        urlComponents.scheme = "http"
        urlComponents.host = "newsapi.org"
        urlComponents.path =  settings.endpoint!.rawValue
        urlComponents.queryItems = queryItems
        
        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.setValue(settings.apiKey!, forHTTPHeaderField: "X-Api-Key")
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: urlRequest) {
            (data, response, taskError) in
            do {
                if let data = data {
                    let articlesData = try JSONDecoder().decode(ArticleModel.Articles.self, from: data)
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
    
    static func LoadPersistentStore<T>(persistentContainer: NSPersistentContainer, fetchedResultsController: NSFetchedResultsController<T>) {
        persistentContainer.loadPersistentStores { (persistentStoreDescription, error) in
            guard error == nil else {
                print("Unable to Load Persistent Store")
                fatalError("\(error!), \(error!.localizedDescription)")
            }
            do {
                try fetchedResultsController.performFetch()
            } catch {
                let fetchError = error as NSError
                print("Unable to Perform Fetch Request")
                fatalError("\(fetchError), \(fetchError.localizedDescription)")
            }
        }
    }
    
    static func addArticle(_ article: ArticleModel.ArticleData, context: NSManagedObjectContext) {
        // Create Article
        let newArticle = Article(context: context)
        
        // Configure Article
        newArticle.articleDescription = article.description
        newArticle.author = article.author
        newArticle.image = nil
        newArticle.publishedAt = article.publishedAt
        newArticle.sourceID = article.source.id
        newArticle.sourceName = article.source.name
        newArticle.title = article.title
        newArticle.url = article.url
        newArticle.urlToImage = article.urlToImage
    }
    
    static func SaveToPeristent(persistentContainer: NSPersistentContainer) {
        do {
            try persistentContainer.viewContext.save()
        } catch {
            print("Unable to Save Changes")
            print("\(error), \(error.localizedDescription)")
        }
    }
    
    static func deleteArticlesFromPersistentStorage(persistentContainer: NSPersistentContainer, fetchRequest: NSFetchRequest<NSFetchRequestResult>,
                                                    fetchedResultsController: NSFetchedResultsController<Article>) {
        let context = persistentContainer.viewContext
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(deleteRequest)
            try fetchedResultsController.performFetch()
        } catch {
            let updateError = error as NSError
            print("\(updateError), \(updateError.userInfo)")
        }
    }
    
    static func deleteArticlesFromMemory(fetchedResultsController: NSFetchedResultsController<Article>) {
        guard let articles = fetchedResultsController.fetchedObjects else { return }
        for article in articles {
            article.managedObjectContext?.delete(article)
        }
    }
    
    static func getEntitiesCount(persistentContainer: NSPersistentContainer, fetchRequest: NSFetchRequest<NSFetchRequestResult>) -> Int? {
        let count: Int?
        do {
            count = try persistentContainer.viewContext.count(for: fetchRequest)
        } catch {
            print("Unable to Save Changes")
            print("\(error), \(error.localizedDescription)")
            count = nil
        }
        return count
    }
    private init() {}
}
