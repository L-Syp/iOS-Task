//
//  ArticlesHeadingTableViewCell.swift
//  Task
//
//  Created by Łukasz Sypniewski on 14/02/2018.
//  Copyright © 2018 Łukasz Sypniewski. All rights reserved.
//

import UIKit

class ArticleHeadingTableViewCell: UITableViewCell {

    @IBOutlet weak var articleHeadingImage: UIImageView!
    @IBOutlet weak var articleHeadingTitle: UILabel!
    @IBOutlet weak var articleHeadingSource: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
