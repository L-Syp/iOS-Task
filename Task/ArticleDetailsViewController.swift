//
//  ArticleDetailsViewController.swift
//  Task
//
//  Created by Łukasz Sypniewski on 14/02/2018.
//  Copyright © 2018 Łukasz Sypniewski. All rights reserved.
//

import UIKit

class ArticleDetailsViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    var testValue = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = testValue
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   

}

