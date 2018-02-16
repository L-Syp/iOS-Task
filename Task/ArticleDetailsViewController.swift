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
    
    var article: Article? = nil
    var image: UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        //titleLabel.text = article!.title
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   

}

