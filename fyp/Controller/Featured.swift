//
//  ViewController4.swift
//  fyp
//
//  Created by Scarlet on 6/3/2019.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit

class Featured: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NetworkDelegate {
    
    //VARIABLE
    let session = Session.shared
    let parser = Session.parser
    let network = Network()
    var selectedItem = Trip()
    var imgs = [Item : UIImage]()
    var textHeight = [Item : CGFloat]()
    var yLoc: CGFloat = 0.0
    var timer = Timer()
    var added = false
    var initialTouchPointSE = CGPoint.zero
    var original: CGFloat = 0.0
    var feedItems = 3
    var state = ""
    
    //IBOUTLET
    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contents: UICollectionView!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var plusBtn: UIButton!
    
    //IBACTION
    @IBAction func userBtn(_ sender: UIButton) {
        session.showUserMenu()
    }
    
    @IBAction func plus(_ sender: UIButton){
        state = "addBookmark"
        network.send(url: "https://scripttrip.scarletsc.net/iOS/addBookmark.php?trip=\(selectedItem.TID)&user=93112488", method: "GET", query: nil)
    }
    
    //DELEGATION
        //COLLECTION VIEW
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag{
        case 0:
            return session.getTrips().count
        case 1:
            return selectedItem.Items.count
        default:
            return 0
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch collectionView.tag{
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! featuredCell
            
            cell.alpha = 0
            
            cell.layer.masksToBounds = false
            cell.layer.shadowColor = UIColor.lightGray.cgColor
            cell.layer.shadowOpacity = 0.1
            
            cell.title.text = session.getTrips()[indexPath.row].T_Title
            
//            cell.img.image = imgs[session.getTrips()[indexPath.row].Items[0]]
            
            cell.view.layer.cornerRadius = 15
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                cell.alpha = 1
            }, completion: nil)
            
            return cell
        case 1:
            
            if indexPath.row == 0{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "content", for: indexPath) as! contentViewCell
                
                cell.ctn.text = selectedItem.Items[0].I_Content
                
                return cell
            }else{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "otherContent", for: indexPath) as! otherContentViewCell
                
                cell.img.image = #imageLiteral(resourceName: "Image-1")
                cell.content.text = selectedItem.Items[indexPath.row].I_Content
                cell.content.sizeToFit()
                
                return cell
            }
            
            
        default:
            return UICollectionViewCell()
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.tag == 1{
            if indexPath.row == 0{
//                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "content", for: indexPath) as! contentViewCell
                
                return CGSize(width: collectionView.bounds.width, height: textHeight[selectedItem.Items[0]]!)
                
            }else{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "otherContent", for: indexPath) as! otherContentViewCell
                
                return CGSize(width: collectionView.bounds.width, height: textHeight[selectedItem.Items[indexPath.row]]! + cell.img.frame.height)
                
            }
        }else{
            return CGSize(width: 341, height: 338)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        switch collectionView.tag{
        case 0:
            return .init(width: self.view.frame.width, height: 50)
        case 1:
            return .init(width: view.frame.width, height: view.frame.width / 2 * 2.5)
        default:
            return CGSize()
        }
        
        
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch collectionView.tag{
        case 0:
            switch kind{
            case UICollectionView.elementKindSectionHeader:
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath)
                
                header.frame = CGRect(x: 0 , y: 0, width: collectionView.frame.width, height: 50)
                
                return header
                
            default:
                return UICollectionReusableView()
                
            }
            
        case 1:
            switch kind{
            case UICollectionView.elementKindSectionHeader:
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerId", for: indexPath) as! HeaderView
                
                header.frame = CGRect(x: 0 , y: 0, width: collectionView.frame.width, height: collectionView.frame.width / 2 * 2.5)
                
                header.headerImg.image = #imageLiteral(resourceName: "Image")
                header.headerImg.contentMode = .scaleAspectFill
                
                header.headerImg.layer.cornerRadius = 12
                header.headerImg.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                
                header.xBtn.layer.cornerRadius = header.xBtn.frame.width / 2
                
                header.xBtn.addTarget(self, action: #selector(xLeave(_:)), for: .touchUpInside)
                
                header.gradient.layer.cornerRadius = 12
                header.gradient.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                
                header.title.text = selectedItem.T_Title
                
                return header
                
            default:
                return UICollectionReusableView()
                
            }
        default:
            return UICollectionReusableView()
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView.tag == 0{
            
            state = "checkBookmark"
            network.send(url: "https://scripttrip.scarletsc.net/iOS/checkBookmark.php?trip=\(selectedItem.TID)&user=93112488", method: "GET", query: nil)
            
            selectedItem = session.getTrips()[indexPath.row]
            
            DispatchQueue.main.async {
                self.contents.reloadData()
                self.contents.layoutIfNeeded()
            }
            
            for item in selectedItem.Items{
                let height = Float(item.I_Content.count / 16)
                textHeight[item] = CGFloat(floor(height < 1 ? 1 : height) * 12)
            }
            
            contentView.frame = CGRect(x: self.contentView.frame.minX, y: self.view.frame.height, width: contentView.frame.width, height: contentView.frame.height)
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                self.tabBarController?.tabBar.frame = CGRect(x: (self.tabBarController?.tabBar.frame.minX)!, y: (self.tabBarController?.tabBar.frame.minY)! + (self.tabBarController?.tabBar.frame.height)!, width: (self.tabBarController?.tabBar.frame.width)!, height: (self.tabBarController?.tabBar.frame.height)!)
                
                self.contentView.frame = CGRect(x: self.contentView.frame.minX, y: self.original + self.view.frame.height * 0.075, width: self.contentView.frame.width, height: self.contentView.frame.height)
                self.contentView.alpha = 1
                self.blurView.alpha = 0.35
                
            }, completion: nil)
            
        }
        
    }
    
        //NETWORK
    func ResponseHandle(data: Data) {
        if state == "trip"{
            session.setTrips(session.parseTrip(parser.parseNested(data)))
            DispatchQueue.main.async {
                self.cv.reloadData()
            }
        }else if state == "addBookmark"{
            guard let result = parser.parse(data) else {return}
            for item in result{
                if (item["Result"] as! String) == "OK"{
                    let alert = UIAlertController(title: "Added to bookmarks.", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }else{
                    let alert = UIAlertController(title: "Error when adding bookmarks.", message: (item["Reason"] as? String), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }else if state == "checkBookmark"{
            guard let result = parser.parse(data) else {return}
            for item in result{
                if (item["Result"] as! String) == "Exist"{
                    DispatchQueue.main.async {
                        self.plusBtn.alpha = 0
                    }
                }else{
                    DispatchQueue.main.async {
                        self.plusBtn.alpha = 1
                    }
                    
                }
            }
            DispatchQueue.main.async {
                self.plusBtn.layoutIfNeeded()
            }
            
        }
        
        
    }
    
    //OBJC FUNC
    @objc func xLeave(_ sender: UIButton){
        
        UIView.animate(withDuration: 0.3) {
            self.contentView.frame = CGRect(x: self.contentView.frame.minX, y: self.view.frame.height, width: self.contentView.frame.width, height: self.contentView.frame.height)
            self.blurView.alpha = 0
            self.tabBarController?.tabBar.frame = CGRect(x: (self.tabBarController?.tabBar.frame.minX)!, y: (self.tabBarController?.tabBar.frame.minY)! - (self.tabBarController?.tabBar.frame.height)!, width: (self.tabBarController?.tabBar.frame.width)!, height: (self.tabBarController?.tabBar.frame.height)!)
        }
        
    }
    
    //FUNC
    func delegate(){
        cv.dataSource = self
        cv.delegate = self
        
        contents.delegate = self
        contents.dataSource = self
        
        network.delegate = self
    }
    
    func layout(){
        let layout = cv.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionHeadersPinToVisibleBounds = true
        cv.collectionViewLayout = layout
        
        contents.contentInsetAdjustmentBehavior = .always
        contents.collectionViewLayout = StretchyHeaderLayout()
        
        blurView.frame = UIApplication.shared.keyWindow!.frame
        
        original = contentView.frame.minY
        
        contentView.layer.cornerRadius = 12
        contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        plusBtn.layer.cornerRadius = plusBtn.frame.width / 2
        
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to: #selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = "42E89D".toUIColor
        }
        
    }
    
    func setup(){
        session.setupUserView()
    }
    
    //VIEW CONTROLLER
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        delegate()
        layout()
        setup()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        state = "trip"
        network.send(url: "https://scripttrip.scarletsc.net/iOS/getTrips.php", method: "GET", query: nil)
        
//        for trip in session.getTrips(){
//            for item in trip.Items{
//                //                imgs[item] = network.getPhoto(url: URL(string: "https://scripttrip.scarletsc.net/img/\(item.I_Image)")!)
//
//                URLSession.shared.dataTask(with: URL(string: "https://scripttrip.scarletsc.net/img/\(item.I_Image)")!) { data, response, error in
//                    guard let imgData = data, error == nil else {return}
//
//                    DispatchQueue.main.async(execute: {
//                        self.imgs[item] = UIImage(data: imgData)!
//                        self.cv.reloadData()
//                    })
//
//                    }.resume()
//
//            }
//        }
        
        DispatchQueue.main.async {
            self.cv.reloadData()
        }
        
    }

}
