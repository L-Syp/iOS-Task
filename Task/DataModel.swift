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
