//
//  DataModel.swift
//  Task
//
//  Created by Łukasz Sypniewski on 20/02/2018.
//  Copyright © 2018 Łukasz Sypniewski. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class DataModel {
    static func LoadPersistentStore<T>(persistentContainer: NSPersistentContainer, fetchedResultsController: NSFetchedResultsController<T>) {
        persistentContainer.loadPersistentStores { (persistentStoreDescription, error) in
            if let error = error {
                print("Unable to Load Persistent Store")
                print("\(error), \(error.localizedDescription)")
            } else {
                do {
                    try fetchedResultsController.performFetch()
                } catch {
                    let fetchError = error as NSError
                    print("Unable to Perform Fetch Request")
                    print("\(fetchError), \(fetchError.localizedDescription)")
                }
            }
        }
    }
    
    static func addArticle(_ article: ArticleData, context: NSManagedObjectContext) {
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
                                                    tableView: UITableView, fetchedResultsController: NSFetchedResultsController<Article>) {
        let context = persistentContainer.viewContext
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(deleteRequest)
            try fetchedResultsController.performFetch()
            tableView.reloadData()
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
}
