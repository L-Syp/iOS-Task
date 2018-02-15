//
//  ArticleHeadingTableViewController.swift
//  Task
//
//  Created by Łukasz Sypniewski on 14/02/2018.
//  Copyright © 2018 Łukasz Sypniewski. All rights reserved.
//

import UIKit

class ArticleHeadingTableViewController: UITableViewController {
    let apiKey = "2beb5953fd92424983abae1dc1c7d58c"
    var articles = [Article]()
    var cachedImages = [UIImage?]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData()
        
        //self.tableView.reloadData()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
        cell.articleHeadingImage.image = #imageLiteral(resourceName: "newsImage") //without this line some images are duplicated
        
        if let imgURL = articles[indexPath.row].urlToImage {
            if let cachedImage = cachedImages[indexPath.row] {
                cell.articleHeadingImage.image = cachedImage
                print("************** Set an image cell from cache")
            } else {
                let session = URLSession.shared
                let task = session.dataTask(with: imgURL) { (data, response, error) in
                    if error == nil {
                        let downloadedImage = UIImage(data: data!)
                        print("************** Downloaded an image cell")
                        self.cachedImages[indexPath.row] = downloadedImage
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
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func loadData() {
        RestCall.makeGetCall(endpoint: RestCall.Endpoints.topHeadlines, itemsCount: 30, additionalQueries: [URLQueryItem(name: "country", value: "us")], apiKey: apiKey) { dane in
            for i in 0..<dane.articles.count {
                self.articles.append(Article(with: dane.articles[i]))
                self.cachedImages.append(nil)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    
}
