//
//  ArticleHeadingTableViewController.swift
//  Task
//
//  Created by Łukasz Sypniewski on 14/02/2018.
//  Copyright © 2018 Łukasz Sypniewski. All rights reserved.
//

import UIKit
import CoreData

class ArticleHeadingTableViewController: UITableViewController {
    
    // MARK: Properties
    let apiKey = "2beb5953fd92424983abae1dc1c7d58c"
    var articles = [Article]()
    
    
    // MARK: Actions
    @IBAction func refreshButton(_ sender: UIBarButtonItem) {
        articles = [Article]() // to avoid duplicated posts
        self.loadData(endpoint: RestCall.Endpoints.topHeadlines, itemsCount: 20, additionalQueries: [URLQueryItem(name: "country", value: "us")])
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        persistLoadAtricle()
        self.tableView.reloadData()
        //self.loadData(endpoint: RestCall.Endpoints.topHeadlines, itemsCount: 3, additionalQueries: [URLQueryItem(name: "country", value: "us")])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "showDetailsSegue" {
            let vc = segue.destination as! ArticleDetailsViewController
            if sender as? ArticleHeadingTableViewCell != nil {
                vc.image = articles[tableView.indexPathForSelectedRow!.row].image ?? #imageLiteral(resourceName: "newsImage")
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
        
        if (indexPath.row % 2 == 0){
            cell.backgroundColor = UIColor(red: 158.0/255.0, green: 184.0/255.0, blue: 226.0/255.0, alpha: 1.0)
        } else {
            cell.backgroundColor = UIColor(red: 184.0/255.0, green: 242.0/255.0, blue: 155.0/255.0, alpha: 1.0)
        }
        
        cell.articleHeadingTitle.text = articles[indexPath.row].title ?? "No title"
        cell.articleHeadingSource.text = "Source: \(articles[indexPath.row].sourceName ?? "-")"
        cell.articleHeadingImage.image = articles[indexPath.row].image ?? #imageLiteral(resourceName: "newsImage") //without this line some images are duplicated and rendered in a wrong cell
        if let imgURL = articles[indexPath.row].urlToImage {
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
                            self.persistSaveArticle(self.articles[indexPath.row], imageData: data!)
                        }
                        print("Article has been saved to the device")
                        DispatchQueue.main.async {
                            cell.articleHeadingImage.image = downloadedImage
                            print("************** Set an image cell from web")
                        }
                    }
                }
                task.resume()
            }
        }
        return cell
    }
    
    func loadData(endpoint: RestCall.Endpoints, itemsCount: Int, additionalQueries: [URLQueryItem]) {
        RestCall.makeGetCall(endpoint: endpoint, itemsCount: itemsCount, additionalQueries: additionalQueries, apiKey: apiKey) { dane in
            self.articles = [Article]()
            for i in 0..<dane.articles.count {
                let article = Article(with: dane.articles[i])
                self.articles.append(article)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func persistSaveArticle(_ article: Article, imageData: Data){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let entity = CachedArticles(context: context)
        entity.author = article.author
        entity.articleDescription = article.description
        entity.publishedAt = article.publishedAt
        entity.sourceID = article.sourceID
        entity.sourceName = article.sourceName
        entity.title = article.title
        entity.url = article.url
        entity.urlToImage = article.urlToImage
        entity.image = imageData
        (UIApplication.shared.delegate as! AppDelegate).saveContext()

    }
    
    func persistLoadAtricle(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        var length: Int
        do {
            let articleCacheArray = try context.fetch(CachedArticles.fetchRequest())
            length = articleCacheArray.count
            articles = [Article]()
            for i in 0..<articleCacheArray.count {
                let entity: CachedArticles = articleCacheArray[i] as! CachedArticles
                let source = Source(id: entity.sourceID, name: entity.sourceName)
                let articleData = ArticleData(source: source, author: entity.author, title: entity.title, description: entity.description,
                                              url: entity.url, urlToImage: nil, publishedAt: entity.publishedAt)
                articles.append(Article(with: articleData, image: UIImage(data: entity.image!)!))
            }
            print("Persisted array count: \(length)")
        } catch {
            print("Fetching articles failed!")
        }
    }
    
    func persistDeleteData(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            let articleCacheArray = try context.fetch(CachedArticles.fetchRequest())
            articles = [Article]()
            for i in 0..<articleCacheArray.count {
                context.delete(articleCacheArray[i] as! NSManagedObject)
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
            }
        } catch {
            print("Deleting articles failed!")
        }
        
        do {
            let imageCacheArray = try context.fetch(CachedImages.fetchRequest())
            for i in 0..<imageCacheArray.count {
                context.delete(imageCacheArray[i] as! NSManagedObject)
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
            }
        } catch {
            print("Deletic images failed!")
        }
    }
    
}
