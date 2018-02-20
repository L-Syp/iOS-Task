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
    
    // MARK: Actions
    @IBAction func refreshButton(_ sender: UIBarButtonItem) {
        articles = [Article]() // to avoid duplicated posts
        self.loadData(endpoint: RestCall.Endpoints.topHeadlines, itemsCount: 7, additionalQueries: [URLQueryItem(name: "country", value: "us")])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if RestCall.connectedToNetwork() {
            DataPersistence.persistDeleteData(&articles)
            self.loadData(endpoint: RestCall.Endpoints.topHeadlines, itemsCount: 7, additionalQueries: [URLQueryItem(name: "country", value: "us")])
        } else {
            DataPersistence.persistLoadAtricle(&articles)
            self.tableView.reloadData()
        }
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
        cell.articleHeadingImage.image = articles[indexPath.row].image ?? defaultImage //without this line some images are duplicated and rendered in a wrong cells
        if let imgURL = articles[indexPath.row].urlToImage{
            if let cachedImage = articles[indexPath.row].image {
                cell.articleHeadingImage.image = cachedImage
                print("************** Set an image cell from cache")
            } else {
                let session = URLSession.shared
                let task = session.dataTask(with: imgURL) { (data, response, error) in
                    if error == nil {
                        let downloadedImage = UIImage(data: data!)
                        print("************** Downloaded an image cell")
                        self.articles[indexPath.row].image = downloadedImage
                       DispatchQueue.main.sync {
                           DataPersistence.persistSaveArticle(self.articles[indexPath.row], imageData: data)
                           self.articles[indexPath.row].isSavedToCache = true
                           print("Entities count: \(DataPersistence.getEntitiesCount())")
                        }
                        print("Article has been saved to the device")
                        DispatchQueue.main.async {
                            cell.articleHeadingImage.image = downloadedImage
                            print("************** Set an image cell from web")
                        }
                    } else {
                        self.articles[indexPath.row].image = self.defaultImage
                        DispatchQueue.main.sync {
                            DataPersistence.persistSaveArticle(self.articles[indexPath.row], imageData: nil)
                            self.articles[indexPath.row].isSavedToCache = true
                            print("Entities count: \(DataPersistence.getEntitiesCount())")
                        }
                        print("Article has been saved to the device, but error has occured")
                    }
                }
                task.resume()
            }
        } else if !self.articles[indexPath.row].isSavedToCache {
            DataPersistence.persistSaveArticle(self.articles[indexPath.row], imageData: nil)
            self.articles[indexPath.row].isSavedToCache = true
             self.articles[indexPath.row].image = defaultImage
            print("Entities count: \(DataPersistence.getEntitiesCount())")
        }
        return cell
    }
    
    func loadData(endpoint: RestCall.Endpoints, itemsCount: Int, additionalQueries: [URLQueryItem]) {
        RestCall.makeGetCall(endpoint: endpoint, itemsCount: itemsCount, additionalQueries: additionalQueries, apiKey: apiKey) { data, response in
            self.articles = [Article]()
            for i in 0..<data.articles.count {
                let article = Article(with: data.articles[i])
                self.articles.append(article)
                print((response as! HTTPURLResponse).statusCode)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}
