//
//  CountryCellTableViewCell.swift
//  Task
//
//  Created by Łukasz Sypniewski on 01/03/2018.
//  Copyright © 2018 Łukasz Sypniewski. All rights reserved.
//

import UIKit

class SettingsCountryCellTableViewCell: UITableViewCell {
    
    // MARK - outlets
    @IBOutlet weak var labelName: UILabel!
    
    // MARK - properties
    var name: String? {
        didSet {
            labelName.text = name
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
