//
//  ViewController4.swift
//  fyp
//
//  Created by Scarlet on 6/3/2019.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit

class Bookmarks: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //VARIABLE
    var isStatusBarHidden = false
    var yLoc: CGFloat = 0.0
    
    //IBOUTLET
    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var xBtn: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentImg: UIImageView!
    @IBOutlet weak var contentTxt: UITextView!
    
    //IBACTION
    @IBAction func leave(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func xLeave(_ sender: UIButton) {
        
        self.isStatusBarHidden = false
        
        UIView.animate(withDuration: 0.3) {
            self.contentTxt.alpha = 0
            self.xBtn.alpha = 0
        }
        
        UIView.animate(withDuration: 0.3) {
            self.contentImg.frame = CGRect(x: self.contentImg.frame.minX, y: self.yLoc, width: self.contentImg.frame.width, height: self.contentImg.frame.height)
        }
        
        UIView.animate(withDuration: 0.2) {
            self.contentImg.alpha = 0
            self.contentView.alpha = 0
            self.tabBarController?.tabBar.frame = CGRect(x: (self.tabBarController?.tabBar.frame.minX)!, y: (self.tabBarController?.tabBar.frame.minY)! - (self.tabBarController?.tabBar.frame.height)!, width: (self.tabBarController?.tabBar.frame.width)!, height: (self.tabBarController?.tabBar.frame.height)!)
            self.setNeedsStatusBarAppearanceUpdate()
        }
        
    }
    
    //DELEGATION
        //TABLE VIEW
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            return 3
        case 1:
            return 1
        default:
            return 0
        }
    }
    
        //COLLECTION VIEW
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! featuredCell
        
        cell.layer.masksToBounds = false
        cell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.layer.shadowOpacity = 0.1
        
        cell.view.layer.cornerRadius = 15
        
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind{
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath)
            
            header.frame = CGRect(x: 0 , y: 0, width: collectionView.frame.width, height: 50)
            
            return header
            
        default:
            return UICollectionReusableView()
            
        }
    }
    
    //OBJC FUNC
    @objc func tapFunc(_ sender: UITapGestureRecognizer){
        let location = sender.location(in: self.view)
        
        yLoc = location.y
        
        self.isStatusBarHidden = true
        
        contentImg.frame = CGRect(x: contentImg.frame.minX, y: self.yLoc, width: contentImg.frame.width, height: contentImg.frame.height)
        
        UIView.animate(withDuration: 0.4) {
            self.contentView.alpha = 1
            self.contentImg.alpha = 1
            self.contentImg.frame = CGRect(x: self.contentImg.frame.minX, y: 0, width: self.contentImg.frame.width, height: self.contentImg.frame.height)
            self.tabBarController?.tabBar.frame = CGRect(x: (self.tabBarController?.tabBar.frame.minX)!, y: (self.tabBarController?.tabBar.frame.minY)! + (self.tabBarController?.tabBar.frame.height)!, width: (self.tabBarController?.tabBar.frame.width)!, height: (self.tabBarController?.tabBar.frame.height)!)
            self.setNeedsStatusBarAppearanceUpdate()
            UIView.animate(withDuration: 0.5) {
                self.contentTxt.alpha = 1
                self.xBtn.alpha = 1
            }
        }
        
    }
    
    //FUNC
    
    
    //VIEW CONTROLLER
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        cv.dataSource = self
        cv.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapFunc(_:)))
        cv.addGestureRecognizer(tap)
        
        xBtn.layer.cornerRadius = 45/2
        
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation{
        return .slide
    }
    
    override var prefersStatusBarHidden: Bool{
        return isStatusBarHidden
    }
    
}
