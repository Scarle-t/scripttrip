//
//  CollectionViewCell.swift
//  fyp
//
//  Created by Scarlet on 6/3/2019.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit
import MapKit

class AnnotationView: MKAnnotationView {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}

class categoryCell: UITableViewCell {
    
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

class featuredCell: UICollectionViewCell {
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var title: UILabel!
    
}

class contentViewCell: UICollectionViewCell{
    
    @IBOutlet weak var ctn: UILabel!
    
}

class otherContentViewCell: UICollectionViewCell{
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var content: UILabel!
    
}

class HeaderView: UICollectionReusableView {
    
    @IBOutlet weak var headerImg: UIImageView!
    @IBOutlet weak var xBtn: UIButton!
    @IBOutlet weak var plus: UIButton!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var gradient: UIView!
    
}

class contentHeader: UICollectionReusableView{
    var img = UIImageView()
    var close = UIButton()
}

class contentTitle: UICollectionViewCell{
    var title = UILabel()
}

class mainContent: UICollectionViewCell{
    var content = UILabel()
}

class secondaryContent: UICollectionViewCell{
    var img = UIImageView()
    var content = UILabel()
}

class cateChoiceCell: UICollectionViewCell{
    
    @IBOutlet weak var catImg: UIImageView!
    @IBOutlet weak var catName: UILabel!
    
}

class StretchyHeaderLayout: UICollectionViewFlowLayout {
    
    // we want to modify the attributes of our header component somehow
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        let layoutAttributes = super.layoutAttributesForElements(in: rect)
        
        layoutAttributes?.forEach({ (attributes) in
            
            if attributes.representedElementKind == UICollectionView.elementKindSectionHeader && attributes.indexPath.section == 0 {
                
                guard let collectionView = collectionView else { return }
                
                let contentOffsetY = collectionView.contentOffset.y
                
                if contentOffsetY > 0 {
                    return
                }
                
                let width = collectionView.frame.width
                
                let height = attributes.frame.height - contentOffsetY
                
                // header
                attributes.frame = CGRect(x: 0, y: contentOffsetY, width: width, height: height)
                
            }
            
        })
        
        return layoutAttributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
}
