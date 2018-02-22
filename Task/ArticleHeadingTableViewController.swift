//
//  ArticleHeadingTableViewController.swift
//  Task
//
//  Created by Łukasz Sypniewski on 14/02/2018.
//  Copyright © 2018 Łukasz Sypniewski. All rights reserved.
//

import UIKit

class ArticleHeadingTableViewController: UITableViewController {
    
    // MARK: Properties
    let apiKey = "2beb5953fd92424983abae1dc1c7d58c"
    let defaultImage: UIImage = #imageLiteral(resourceName: "newsImage")
    var articles = [Article]()
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
        guard checkNetworkConnection()  else {
            showNoConnectionAlert()
            return
        }
        loadDataToViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard checkNetworkConnection()  else {
            articles = DataPersistence.persistLoadAtricle()
            self.tableView.reloadData()
            return
        }
        loadDataToViewController()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailsSegue" {
            let vc = segue.destination as! ArticleDetailsViewController
            if sender as? ArticleHeadingTableViewCell != nil {
                vc.image = articles[tableView.indexPathForSelectedRow!.row].image ?? defaultImage
                vc.defaultImage = defaultImage
                vc.article = articles[tableView.indexPathForSelectedRow!.row]
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
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
        
        cell.articleHeadingTitle.text = articles[indexPath.row].title ?? "No title"
        cell.articleHeadingSource.text = "Source: \(articles[indexPath.row].sourceName ?? "-")"
        cell.articleHeadingImage.image = self.articles[indexPath.row].image ?? self.defaultImage
        
        ArticlesProvider.downloadImage(from: self.articles[indexPath.row].urlToImage) { imageData in
            self.loadImageToCell(imageData, cell, indexPath)
            if !self.articles[indexPath.row].isSavedToCache{
                DispatchQueue.main.async {
                    DataPersistence.persistSaveArticle(self.articles[indexPath.row], imageData: imageData)
                    self.articles[indexPath.row].isSavedToCache = true
                }
            }
        }
        return cell
    }
    
    // MARK: - Fetching data
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
            DispatchQueue.main.sync {
                self.articles = [Article]()
                DataPersistence.persistDeleteData()
            }
            self.articles = [Article]() // to avoid duplicated posts
            for i in 0..<data!.articles.count {
                let article = Article(with: data!.articles[i])
                self.articles.append(article)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func loadImageToCell(_ imageData: Data?,_ cell: ArticleHeadingTableViewCell, _ indexPath: IndexPath) {
        if articles[indexPath.row].urlToImage != nil {
            guard let imageData = imageData else {
                self.articles[indexPath.row].image = self.defaultImage
                return
            }
            let image = UIImage(data: imageData)
            self.articles[indexPath.row].image = image
            DispatchQueue.main.async {
                cell.articleHeadingImage.image = image
            }
        } else if !self.articles[indexPath.row].isSavedToCache {
            self.articles[indexPath.row].image = defaultImage
        }
    }
    
    func loadDataToViewController() {
        self.downloadData(endpoint: ArticlesProvider.Endpoints.topHeadlines, itemsCount: 7, additionalQueries: [URLQueryItem(name: "country", value: "us")])
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
        showAlert(title: "Downloaded data is in wrong format", message: "Downloaded data is in wrong format" +
            "therefore cannot be parsed! Check if correct JSON file has been downloaded.", buttonText: "OK")
    }
}
