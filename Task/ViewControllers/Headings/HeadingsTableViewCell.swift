//
//  ArticlesHeadingTableViewCell.swift
//  Task
//
//  Created by Łukasz Sypniewski on 14/02/2018.
//  Copyright © 2018 Łukasz Sypniewski. All rights reserved.
//

import UIKit

class HeadingsTableViewCell: UITableViewCell {

    //MARK - outlets
    @IBOutlet weak var articleHeadingImage: UIImageView!
    @IBOutlet weak var articleHeadingTitle: UILabel!
    @IBOutlet weak var articleHeadingSource: UILabel!
    
    //MARK - properties
    var newsImage: UIImage? {
        didSet {
            articleHeadingImage.image = newsImage
        }
    }
    var title: String? {
        didSet {
            articleHeadingTitle.text = title
        }
    }
    var source: String? {
        didSet {
            articleHeadingSource.text = source
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
