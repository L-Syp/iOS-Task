//
//  ArticleDetailsViewController.swift
//  Task
//
//  Created by Łukasz Sypniewski on 14/02/2018.
//  Copyright © 2018 Łukasz Sypniewski. All rights reserved.
//

import UIKit

class ArticleDetailsViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var pubishedAtLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var URLLabel: UILabel!
    
    var article: Article? = nil
    var image: UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        if image == #imageLiteral(resourceName: "newsImage"){
            imageView.contentMode = .scaleAspectFit
        }
        titleLabel.text = article!.title
        pubishedAtLabel.text = "Published at: \(article!.publishedAt ?? "-")"
        descriptionLabel.text = article!.description ?? "No description available"
        authorLabel.text = "Author: \(article!.author ?? "-")"
        URLLabel.text = "URL: \(article!.url?.absoluteString ?? "No url available")"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

