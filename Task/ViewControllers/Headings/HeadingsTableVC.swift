//
//  ArticleHeadingTableVC.swift
//  Task
//
//  Created by Łukasz Sypniewski on 14/02/2018.
//  Copyright © 2018 Łukasz Sypniewski. All rights reserved.
//

import UIKit
import CoreData

class HeadingsTableVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Properties
    let persistentContainer: NSPersistentContainer
    let articleFerchRequest: NSFetchRequest<NSFetchRequestResult>
    lazy var dataSource = HeadingsTableDataSource(fetchedResultsController: fetchedResultsController, persistentContainer: persistentContainer)
    var isOnline = false {
        didSet {
            let title = isOnline ? "Breaking news" : "Breaking news (offline mode)"
            self.navigationItem.title = title
        }
    }
    private lazy var fetchedResultsController: NSFetchedResultsController<Article> = {
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<Article> = Article.fetchRequest()
        
        // Configure Fetch Request
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Article.sourceName), ascending: true)]
        
        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.persistentContainer.viewContext,
                                                                  sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    // MARK: Initializers
    required init?(coder aDecoder: NSCoder) {
        self.persistentContainer = NSPersistentContainer(name: "Articles")
        self.articleFerchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Article")
        super.init(coder: aDecoder)
    }
    
    
    // MARK: Actions
    @IBAction func refreshButton(_ sender: Any?) {
        if checkNetworkConnection() {
            DataModel.deleteArticlesFromMemory(fetchedResultsController: fetchedResultsController)
            dataSource.downloadData(settings: SettingsManager.loadAppSettings())
        }
    }
    
    @IBAction func unwindToArticleList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? SettingsVC {
            SettingsManager.saveAppSettings(settings: sourceViewController.settings)
            refreshButton(self)
        }
    }
    
    // MARK: View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = dataSource
        dataSource.delegate = self
        tableView.delegate = self
        DataModel.LoadPersistentStore(persistentContainer: persistentContainer, fetchedResultsController: fetchedResultsController)
        if checkNetworkConnection(){
            DataModel.deleteArticlesFromPersistentStorage(persistentContainer: persistentContainer, fetchRequest: articleFerchRequest,
                                                          tableView: self.tableView, fetchedResultsController: fetchedResultsController)
        }
        self.updateView()
        dataSource.downloadData(settings: SettingsManager.loadAppSettings())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailsSegue" {
            let article = fetchedResultsController.object(at: tableView.indexPathForSelectedRow!)
            let vc = segue.destination as! DetailsVC
            guard sender as? HeadingsTableViewCell != nil else { return }
            if let data = article.image
            {
                vc.image = UIImage(data: data)
            } else {
                vc.image = HeadingsTableDataSource.defaultImage
            }
            vc.defaultImage = HeadingsTableDataSource.defaultImage
            vc.article = article
        }
        if segue.identifier == "showSettingsSegue" {
            let navigationVC = segue.destination as! UINavigationController
            let settingsVC = navigationVC.viewControllers.first as! SettingsVC
            guard sender as? UIBarButtonItem != nil else { return }
            settingsVC.settings = SettingsManager.loadAppSettings()
        }
    }
    
    private func updateView() {
        var hasArticles = false
        if let articles = fetchedResultsController.fetchedObjects {
            hasArticles = articles.count > 0
        }
        tableView.isHidden = !hasArticles
    }
    
    func getSavedPersitentArticleCount() -> Int? {
        return DataModel.getEntitiesCount(persistentContainer: persistentContainer, fetchRequest: articleFerchRequest)
    }
}

// MARK: UITableViewDelegate
extension HeadingsTableVC : UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: HeadingsTableDataSourceDelegate
extension HeadingsTableVC : HeadingsTableDataSourceDelegate
{
    func downloadData(endpoint: ArticlesProvider.Endpoints, itemsCount: Int, queries: [URLQueryItem], apiKey: String, callBack: @escaping (Articles?, URLResponse?, Error?) -> ()) {
        ArticlesProvider.downloadData(endpoint: endpoint, itemsCount: itemsCount, queries: queries, apiKey: apiKey, callBack: callBack)
    }
    
    func downloadImage(from url: URL?, callBack: @escaping (Data?) -> ()) {
        ArticlesProvider.downloadImage(from: url, callBack: callBack)
    }
    
    func handleNoConnectionError(error: Error) {
        Utils.showNoConnectionAlert(self)
    }
    
    func handleNoDataError(error: Error) {
        Utils.showNoDataAlert(self)
    }
    
    func handleInvalidDataError(error: Error) {
        Utils.showInvalidDataFormat(self)
    }
    
    func handleUnknownError(error: Error) {
        Utils.showAlert(self, title: "Unknown error", message: "Error message: \(error.localizedDescription)", buttonText: "OK")
    }
    
    func checkNetworkConnection() -> Bool {
        isOnline = Utils.connectedToNetwork()
        return isOnline
    }
}

// MARK: NSFetchedResultsControllerDelegate
extension HeadingsTableVC: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        updateView()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any,
                    at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .none)
            }
            break;
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break;
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? HeadingsTableViewCell {
                dataSource.configure(cell, at: indexPath)
            }
            break;
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .none)
            }
            
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .none)
            }
            break;
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            break;
        }
    }
}
