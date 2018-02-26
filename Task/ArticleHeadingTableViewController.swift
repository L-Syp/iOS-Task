//
//  ArticleHeadingTableViewController.swift
//  Task
//
//  Created by Łukasz Sypniewski on 14/02/2018.
//  Copyright © 2018 Łukasz Sypniewski. All rights reserved.
//

import UIKit
import CoreData

class ArticleHeadingTableViewController: UITableViewController,  NSFetchedResultsControllerDelegate {
    
    // MARK: Properties
    let apiKey = "2beb5953fd92424983abae1dc1c7d58c"
    let defaultImage: UIImage = #imageLiteral(resourceName: "newsImage")
    private let persistentContainer = NSPersistentContainer(name: "Articles")
    var cachedImages = [UIImage?]()
    var isOnline = false {
        didSet {
            if !isOnline {
                self.navigationItem.title = "Breaking news (offline mode)"
            } else {
                self.navigationItem.title = "Breaking news"
            }
        }
    }
    
    // MARK: Actions
    @IBAction func refreshButton(_ sender: UIBarButtonItem) {
        addArticle(article: ArticleData(source: Source(id:"XYZ", name: "Trojmiasto.pl"), author: "Autor", title: "Tytul", description: "Opis", url: nil, urlToImage: nil, publishedAt: "Dzisiaj"))
    }
    
    // MARK: CoreData
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Article> = {
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<Article> = Article.fetchRequest()
        
        // Configure Fetch Request
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Article.sourceName), ascending: true)]
        
        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.persistentContainer.viewContext, sectionNameKeyPath: nil/*#keyPath(Article.sourceName)*/, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        persistentContainer.loadPersistentStores { (persistentStoreDescription, error) in
            if let error = error {
                print("Unable to Load Persistent Store")
                print("\(error), \(error.localizedDescription)")
                
            } else {
                do {
                    try self.fetchedResultsController.performFetch()
                } catch {
                    let fetchError = error as NSError
                    print("Unable to Perform Fetch Request")
                    print("\(fetchError), \(fetchError.localizedDescription)")
                }
                self.updateView()
            }
        }
        self.downloadData(endpoint: ArticlesProvider.Endpoints.everything, itemsCount: 20, additionalQueries: [URLQueryItem(name: "q", value: "apple")])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailsSegue" {
            let article = fetchedResultsController.object(at: tableView.indexPathForSelectedRow!)
            let vc = segue.destination as! ArticleDetailsViewController
            if sender as? ArticleHeadingTableViewCell != nil {
                if let data = article.image
                {
                    vc.image = UIImage(data: data)
                } else {
                    vc.image = defaultImage
                }
                vc.defaultImage = defaultImage
                vc.article = article
            }
        }
    }
    
    fileprivate func updateView() {
        var hasArticles = false
        
        if let articles = fetchedResultsController.fetchedObjects {
            hasArticles = articles.count > 0
        }
        tableView.isHidden = !hasArticles
        // activityIndicatorView.stopAnimating()
    }
    
    // MARK: NSFetchedResultsControllerDelegate
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
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break;
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break;
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? ArticleHeadingTableViewCell {
                configure(cell, at: indexPath)
            }
            break;
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
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
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else { fatalError("Unexpected Section") }
        return sectionInfo.numberOfObjects
    }
    
    override  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionInfo = fetchedResultsController.sections?[section] else { fatalError("Unexpected Section") }
        return sectionInfo.name
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleHeadingCell", for: indexPath) as? ArticleHeadingTableViewCell else {
            fatalError("The dequeued cell is not an instance of ArticleHeadingTableViewCell")
        }
        if (indexPath.row % 2 == 0) {
            cell.backgroundColor = UIColor(red: 158.0/255.0, green: 184.0/255.0, blue: 226.0/255.0, alpha: 1.0)
        } else {
            cell.backgroundColor = UIColor(red: 184.0/255.0, green: 242.0/255.0, blue: 155.0/255.0, alpha: 1.0)
        }
        
        // Configure Cell
        configure(cell, at: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Fetch Quote
            let quote = fetchedResultsController.object(at: indexPath)
            
            // Delete Quote
            quote.managedObjectContext?.delete(quote)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func configure(_ cell: ArticleHeadingTableViewCell, at indexPath: IndexPath) {
        // Fetch Quote
        let index = indexPath
        let article = fetchedResultsController.object(at: indexPath)
        // Configure Cell
        cell.articleHeadingTitle.text = article.title
        cell.articleHeadingSource.text = article.sourceName
        
        if let articleImage = article.image{
            if let cachedImage = cachedImages[indexPath.row] {
                cell.articleHeadingImage.image = cachedImage
                print("Image set from cache")
            } else {
                cell.articleHeadingImage.image = UIImage(data: articleImage) ?? defaultImage
                print("Image set from article.image")
            }
        } else {
            cell.articleHeadingImage.image = defaultImage
            print("Image set from defaultImage")
        }
        
        if cachedImages[indexPath.row] == nil {
            ArticlesProvider.downloadImage(from: article.urlToImage) { data in
                if let data = data {
                    let image = UIImage(data: data)
                    DispatchQueue.main.async {
                        if index == indexPath {
                            cell.articleHeadingImage.image = image
                            self.cachedImages[index.row] = image
                            print("Image added to cache")
                            article.image = data
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Fetching data
    
    func addArticle(article: ArticleData) {
        let context = persistentContainer.viewContext
        
        // Create Quote
        let newArticle = Article(context: context)
        // Configure Quote
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
    
    func downloadData(endpoint: ArticlesProvider.Endpoints, itemsCount: Int, additionalQueries: [URLQueryItem]) {
        ArticlesProvider.downloadData(endpoint: endpoint, itemsCount: itemsCount, additionalQueries: additionalQueries, apiKey: apiKey) { data, response, error in
            if let error = error {
                if error.localizedDescription == "The Internet connection appears to be offline." {
                    self.showNoConnectionAlert()
                    return
                } else if data == nil {
                    if error.localizedDescription == "The data couldn’t be read because it isn’t in the correct format." {
                        self.showInvalidDataFormat()
                        return
                    } else {
                        self.showNoDataAlert()
                        return
                    }
                } else {
                    self.showAlert(title: "Unknown error", message: "Error message: \(error.localizedDescription)", buttonText: "OK")
                    return
                }
            }
            self.cachedImages = Array(repeating: nil, count: data!.articles.count)
            for i in 0..<data!.articles.count {
                var article = data!.articles[i]
                if let url = article.url {
                    var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
                    urlComponents!.scheme = "http"
                    article.url = urlComponents!.url
                }
                if let urlToImage = article.urlToImage {
                    var urlComponents = URLComponents(url: urlToImage, resolvingAgainstBaseURL: false)
                    urlComponents!.scheme = "http"
                    article.urlToImage = urlComponents!.url
                }
                self.addArticle(article: article)
            }
        }
    }
    
    // MARK: - Networking
    func checkNetworkConnection() -> Bool {
        isOnline = ArticlesProvider.connectedToNetwork()
        return isOnline
    }
    
    // MARK: - Displaying alerts
    func showAlert(title: String, message: String, buttonText: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString(buttonText, comment: "Default action"), style: .`default`, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showNoConnectionAlert() {
        showAlert(title: "No internet connection", message: "There is no internet connection, data cannot be downloaded now.", buttonText: "OK")
    }
    
    func showNoDataAlert() {
        showAlert(title: "No data has been downloaded", message: "No data has been downloaded. Check your internet connection and connection parameters!", buttonText: "OK")
    }
    
    func showInvalidDataFormat() {
        showAlert(title: "Downloaded data is in wrong format", message: "Downloaded data is in wrong format " +
            "therefore cannot be parsed! Check if correct JSON file has been downloaded.", buttonText: "OK")
    }
}
