//
//  TripView.swift
//  fyp
//
//  Created by Scarlet on 28/4/2019.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit

class TripView: NSObject, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource{
    
    //DELEGATE
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (displayTrip?.Items.count ?? -1) + 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "contentTitle", for: indexPath) as! contentTitle
            
            cell.title.frame = CGRect(x: 0, y: 0, width: cell.frame.width, height: 45)
            cell.title.font = UIFont(name: "AvenirNext-Heavy", size: 30)
            cell.title.adjustsFontSizeToFitWidth = true
            cell.title.textAlignment = .right
            cell.title.numberOfLines = 0
            cell.title.text = displayTrip?.T_Title
            cell.title.backgroundColor = .white
            
            cell.addSubview(cell.title)
            
            return cell
        }else if indexPath.row == 1{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mainContent", for: indexPath) as! mainContent
            
            cell.content.frame = cell.contentView.frame
            cell.content.font = UIFont(name: "AnevirNext-Regular", size: 18)
            cell.content.numberOfLines = 0
            cell.content.text = displayTrip?.Items[0].I_Content
            
            cell.contentView.addSubview(cell.content)
            cell.content.fillSuperview()
            
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "otherContent", for: indexPath) as! secondaryContent
            
            cell.img.frame = CGRect(x: 0, y: 0, width: cell.contentView.frame.width, height: cell.contentView.frame.width / 3 * 2)
            cell.img.contentMode = .scaleAspectFit
            cell.img.image = #imageLiteral(resourceName: "Image-1")
            
            cell.content.frame = CGRect(x: 0, y: cell.img.frame.maxY, width: cell.contentView.frame.width, height: cell.contentView.frame.height - cell.img.frame.height)
            cell.content.font = UIFont(name: "AnevirNext-Regular", size: 18)
            cell.content.numberOfLines = 0
            cell.content.text = displayTrip?.Items[indexPath.row - 1].I_Content
            
            cell.contentView.addSubview(cell.img)
            cell.contentView.addSubview(cell.content)
            
            return cell
        }
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as! contentHeader
        
        header.close.frame = CGRect(x: 17, y: 17, width: 35, height: 35)
        header.close.layer.cornerRadius = 35 / 2
        header.close.setImage(#imageLiteral(resourceName: "cross"), for: .normal)
        header.close.addTarget(self, action: #selector(hide), for: .touchUpInside)
        header.close.backgroundColor = .init(white: 1, alpha: 0.9)
        
        header.img.frame = header.frame
        header.img.contentMode = .scaleAspectFill
        header.img.clipsToBounds = true
        header.img.image = #imageLiteral(resourceName: "Image")
        
        header.addSubview(header.img)
        header.addSubview(header.close)
        
        header.img.fillSuperview()
        
        return header
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 0{
            return .init(width: collectionView.frame.width, height: 45)
        }else if indexPath.row == 1{
            return .init(width: collectionView.frame.width, height: heightForItem[0])
        }else{
            return .init(width: collectionView.frame.width, height: heightForItem[indexPath.row - 1] + (collectionView.frame.width / 3 * 2))
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: collectionView.frame.width, height: collectionView.frame.width / 3 * 2)
    }
    
    //ATTRIBUTE
    var displayTrip: Trip?
    
    var window: UIWindow?
    var view: UIView!
    var contents: UICollectionView!
    var addBookmark: UIButton!
    var heightForItem = [CGFloat]()
    var dimBg: UIView!
    
    //INIT
    override init(){
        super.init()
        DispatchQueue.main.async {
            self.window = UIApplication.shared.keyWindow
            self.view = UIView()
            self.addBookmark = UIButton()
            self.dimBg = UIView()
            self.contents = UICollectionView(frame: CGRect.zero, collectionViewLayout: StretchyHeaderLayout())
            self.contents.delegate = self
            self.contents.dataSource = self
        
            self.displayTrip = nil
            self.contents.register(mainContent.self, forCellWithReuseIdentifier: "mainContent")
            self.contents.register(secondaryContent.self, forCellWithReuseIdentifier: "otherContent")
            self.contents.register(contentTitle.self, forCellWithReuseIdentifier: "contentTitle")
            self.contents.register(contentHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
            self.contents.backgroundColor = .white
            
            self.view.frame = CGRect(x: 0, y: 75, width: (self.window?.frame.width)!, height: (self.window?.frame.height)! - 75)
            self.view.frame.origin.y = (self.window?.frame.height)!
            self.view.layer.cornerRadius = 17
            self.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            self.view.clipsToBounds = true
            
            self.contents.frame = self.view.frame
            self.addBookmark.setImage(#imageLiteral(resourceName: "plus"), for: .normal)
            self.addBookmark.backgroundColor = .init(white: 1, alpha: 0.9)
            self.addBookmark.frame = CGRect(x: self.view.frame.maxX - 17 - 35, y: 17, width: 35, height: 35)
            self.addBookmark.layer.cornerRadius = 35 / 2
            
            self.dimBg.frame = (self.window?.frame)!
            self.dimBg.backgroundColor = .black
            self.dimBg.alpha = 0
            
            let tapDismiss = UITapGestureRecognizer(target: self, action: #selector(self.hide))
            self.dimBg.addGestureRecognizer(tapDismiss)
            
            self.view.addSubview(self.contents)
            self.view.addSubview(self.addBookmark)
            
            self.contents.fillSuperview()
            
            UIApplication.shared.keyWindow?.addSubview(self.dimBg)
            UIApplication.shared.keyWindow?.addSubview(self.view)

            self.contents.reloadData()
        }
        
    }
    
    //ACTION
    func show(){
        for item in displayTrip!.Items{
            let height = Float(item.I_Content.count / 16)
            heightForItem.append(CGFloat(floor(height < 1 ? 1 : height) * 20))
        }
        DispatchQueue.main.async {
            self.contents.reloadData()
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            self.view.frame.origin.y = 75
            self.dimBg.alpha = 0.4
        }, completion: nil)
    }
    
    @objc func hide(){
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.view.frame.origin.y = (self.window?.frame.height)!
            self.dimBg.alpha = 0
        }, completion: nil)
    }
}
