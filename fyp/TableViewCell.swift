//
//  TableViewCell.swift
//  fyp
//
//  Created by Scarlet on 7/3/2019.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var items: UICollectionView!
    @IBOutlet weak var catImg: UIImageView!
    @IBOutlet weak var catName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
