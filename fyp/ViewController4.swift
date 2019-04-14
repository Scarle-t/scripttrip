//
//  ViewController4.swift
//  fyp
//
//  Created by Scarlet on 6/3/2019.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit

class ViewController4: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout {
    
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        switch indexPath.section{
        case 0:
            switch indexPath.row{
            case 0:
                cell.textLabel?.text = "Bookmarks"
            case 1:
                cell.textLabel?.text = "History"
            case 2:
                cell.textLabel?.text = "Settings"
            default:
                break
            }
            
        case 1:
            cell.textLabel?.text = "Logout"
            cell.textLabel?.textColor = "FF4740".toUIColor
        default:
            break
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section{
        case 0:
            switch indexPath.row{
            case 0, 1:
                let vc = storyboard?.instantiateViewController(withIdentifier: "vc7") as! ViewController7
                
                self.present(vc, animated: true, completion: nil)
            case 2:
                let vc = storyboard?.instantiateViewController(withIdentifier: "vc8") as! UITableViewController
                
                self.present(vc, animated: true, completion: nil)
            default:
                break
            }
            let vc = storyboard?.instantiateViewController(withIdentifier: "vc7") as! ViewController7
            
            self.present(vc, animated: true, completion: nil)
        case 1:
            let vc = storyboard?.instantiateViewController(withIdentifier: "vc") as! ViewController

            self.present(vc, animated: false, completion: nil)
//            self.tabBarController?.dismiss(animated: false, completion: nil)
        default:
            break
        }
    }
    
    @IBOutlet weak var cv: UICollectionView!
    
    var yLoc: CGFloat = 0.0
    
    var timer = Timer()
    
    var added = false

    @IBOutlet weak var contentView: UIView!

    @IBOutlet weak var contents: UICollectionView!
    @IBOutlet weak var userTable: UITableView!
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var userView: UIView!
    @IBOutlet weak var blurView: UIView!
    
    var userMenu = false
    
    @IBAction func userBtn(_ sender: UIButton) {
        userMenu = true
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            self.userView.frame = CGRect(x: 0, y: 0, width: self.userView.frame.width, height: self.userView.frame.height)
            self.blurView.alpha = 0.35
        }, completion: nil)
    }
    @IBAction @objc func userLeave(_ sender: Any) {
        if userMenu{
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                self.userView.frame = CGRect(x: 0 - self.userView.frame.width, y: 0, width: self.userView.frame.width, height: self.userView.frame.height)
                self.blurView.alpha = 0
            }, completion: nil)
            userMenu = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag{
        case 0:
            return 5
        case 1:
            return 1
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch collectionView.tag{
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
            
            cell.layer.masksToBounds = false
            cell.layer.shadowColor = UIColor.lightGray.cgColor
            cell.layer.shadowOpacity = 0.1
            
            cell.view.layer.cornerRadius = 15
            
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "content", for: indexPath) as! contentViewCell
            
            collectionView.layoutIfNeeded()
            
            let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
            layout.itemSize = CGSize(width: collectionView.bounds.width, height: cell.ctn.frame.height)
            
            return cell
        default:
            return UICollectionViewCell()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        switch collectionView.tag{
        case 0:
            return CGSize()
        case 1:
            return .init(width: view.frame.width, height: view.frame.width / 3 * 2)
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
                
                header.frame = CGRect(x: 0 , y: 0, width: collectionView.frame.width, height: collectionView.frame.width / 3 * 2)
                
                header.headerImg.image = #imageLiteral(resourceName: "Image")
                header.headerImg.contentMode = .scaleAspectFill
                
                header.headerImg.layer.cornerRadius = 12
                header.headerImg.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                
                header.xBtn.layer.cornerRadius = header.xBtn.frame.width / 2
                
                header.xBtn.addTarget(self, action: #selector(xLeave(_:)), for: .touchUpInside)
                
                header.plus.layer.cornerRadius = header.plus.frame.width / 2
                
                header.plus.addTarget(self, action: #selector(plus(_:)), for: .touchUpInside)
                
                return header
                
            default:
                return UICollectionReusableView()
                
            }
        default:
            return UICollectionReusableView()
        }
        
    }
    
    @objc func xLeave(_ sender: UIButton){
        
        added = false
        UIView.animate(withDuration: 0.3) {
            self.contentView.frame = CGRect(x: self.contentView.frame.minX, y: self.view.frame.height, width: self.contentView.frame.width, height: self.contentView.frame.height)
            self.blurView.alpha = 0
            self.tabBarController?.tabBar.frame = CGRect(x: (self.tabBarController?.tabBar.frame.minX)!, y: (self.tabBarController?.tabBar.frame.minY)! - (self.tabBarController?.tabBar.frame.height)!, width: (self.tabBarController?.tabBar.frame.width)!, height: (self.tabBarController?.tabBar.frame.height)!)
        }
    
    }
    @objc func plus(_ sender: UIButton){
        
    }
    
    var original: CGFloat = 0.0
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView.tag == 0{
            
            contentView.frame = CGRect(x: self.contentView.frame.minX, y: self.view.frame.height, width: contentView.frame.width, height: contentView.frame.height)
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                self.tabBarController?.tabBar.frame = CGRect(x: (self.tabBarController?.tabBar.frame.minX)!, y: (self.tabBarController?.tabBar.frame.minY)! + (self.tabBarController?.tabBar.frame.height)!, width: (self.tabBarController?.tabBar.frame.width)!, height: (self.tabBarController?.tabBar.frame.height)!)
                
                self.contentView.frame = CGRect(x: self.contentView.frame.minX, y: self.original + self.view.frame.height * 0.075, width: self.contentView.frame.width, height: self.contentView.frame.height)
                self.contentView.alpha = 1
                self.blurView.alpha = 0.35
                
            }, completion: nil)
            
        }
        
    }
    
    @objc func tapFunc(_ sender: UITapGestureRecognizer){
//        let location = sender.location(in: self.view)
//
//        yLoc = location.y
//
//        self.isStatusBarHidden = true
//
//        contentImg.frame = CGRect(x: contentImg.frame.minX, y: self.yLoc, width: contentImg.frame.width, height: contentImg.frame.height)
//
//        UIView.animate(withDuration: 0.4) {
//            self.contentView.alpha = 1
//            self.contentImg.alpha = 1
//            self.contentImg.frame = CGRect(x: self.contentImg.frame.minX, y: 0, width: self.contentImg.frame.width, height: self.contentImg.frame.height)
//            self.tabBarController?.tabBar.frame = CGRect(x: (self.tabBarController?.tabBar.frame.minX)!, y: (self.tabBarController?.tabBar.frame.minY)! + (self.tabBarController?.tabBar.frame.height)!, width: (self.tabBarController?.tabBar.frame.width)!, height: (self.tabBarController?.tabBar.frame.height)!)
//            self.setNeedsStatusBarAppearanceUpdate()
//            UIView.animate(withDuration: 0.5) {
//                self.contentTxt.alpha = 1
//                self.xBtn.alpha = 1
//            }
//        }
        
    }
    
    var initialTouchPoint = CGPoint.zero
    
    @IBAction func panGestureRecognizerHandler(_ sender: UIPanGestureRecognizer) {
//        let touchPoint = sender.location(in: contentView.window)
//
//        switch sender.state {
//        case .began:
//            initialTouchPoint = touchPoint
//        case .changed:
//            if touchPoint.y > initialTouchPoint.y {
//                contentView.frame.origin.y = touchPoint.y - initialTouchPoint.y
//            }
//        case .ended, .cancelled:
//            if touchPoint.y - initialTouchPoint.y > 200 {
//                added = false
//                contentView.alpha = 0
//                UIView.animate(withDuration: 0.3) {
//                    self.blurView.alpha = 0
//                    self.tabBarController?.tabBar.frame = CGRect(x: (self.tabBarController?.tabBar.frame.minX)!, y: (self.tabBarController?.tabBar.frame.minY)! - (self.tabBarController?.tabBar.frame.height)!, width: (self.tabBarController?.tabBar.frame.width)!, height: (self.tabBarController?.tabBar.frame.height)!)
//                }
//            } else {
//                UIView.animate(withDuration: 0.2, animations: {
//                    self.contentView.frame = CGRect(x: self.contentView.frame.minX,
//                                             y: self.original,
//                                             width: self.contentView.frame.size.width,
//                                             height: self.contentView.frame.size.height)
//                })
//            }
//        case .failed, .possible:
//            break
//        }
    }
    
    var initialTouchPointSE = CGPoint.zero
    
    @IBAction func screenEdge(_ sender: UIScreenEdgePanGestureRecognizer) {
        
        if !userMenu{
            let touchPoint = sender.location(in: self.view.window)
            
            switch sender.state {
            case .began:
                initialTouchPointSE = touchPoint
            case .changed:
                if touchPoint.x > initialTouchPointSE.x && touchPoint.x <= userView.frame.width {
                    userView.frame.origin.x = (touchPoint.x - initialTouchPointSE.x) - userView.frame.width
//                    blurView.alpha = touchPoint.x / (self.view.frame.width / 3)
                }
            case .ended, .cancelled:
                if touchPoint.x - initialTouchPointSE.x > self.view.frame.width / 3 {
                    userMenu = true
                    UIView.animate(withDuration: 0.3) {
                        self.blurView.alpha = 0.35
                        self.userView.frame = CGRect(x: 0, y: 0, width: self.userView.frame.width, height: self.userView.frame.height)
                    }
                } else {
                    UIView.animate(withDuration: 0.2, animations: {
                        self.blurView.alpha = 0
                        self.userView.frame = CGRect(x: self.orignialUser,
                                                     y: self.userView.frame.minY,
                                                     width: self.userView.frame.size.width,
                                                     height: self.userView.frame.size.height)
                    })
                }
            case .failed, .possible:
                break
            }
        }
    }
    
    var initialUserPan = CGPoint.zero
    
    @objc func userPan(_ sender: UIPanGestureRecognizer){
        if userMenu{
            let touchPoint = sender.location(in: self.view.window)
            
            switch sender.state {
            case .began:
                initialUserPan = touchPoint
            case .changed:
                if initialUserPan.x > touchPoint.x {
                    userView.frame.origin.x = 0 - (initialUserPan.x - touchPoint.x)
                    blurView.alpha = touchPoint.x / (self.view.frame.width / 3)
                }
            case .ended, .cancelled:
                if initialUserPan.x - touchPoint.x > self.view.frame.width / 3 {
                    userMenu = false
                    UIView.animate(withDuration: 0.3) {
                        self.blurView.alpha = 0
                        self.userView.frame = CGRect(x: self.orignialUser,
                                                     y: self.userView.frame.minY,
                                                     width: self.userView.frame.size.width,
                                                     height: self.userView.frame.size.height)
                    }
                } else {
                    UIView.animate(withDuration: 0.2, animations: {
                        self.blurView.alpha = 1
                        self.userView.frame = CGRect(x: 0, y: 0, width: self.userView.frame.width, height: self.userView.frame.height)
                        
                    })
                }
            case .failed, .possible:
                break
            }
        }
    }
    
    var orignialUser: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        cv.dataSource = self
        cv.delegate = self
        
        let layout = cv.collectionViewLayout as! UICollectionViewFlowLayout
        
        layout.sectionHeadersPinToVisibleBounds = true
        
        cv.collectionViewLayout = layout
        
        userTable.dataSource = self
        userTable.delegate = self
        
        contents.delegate = self
        contents.dataSource = self
        
        contents.contentInsetAdjustmentBehavior = .always
        contents.collectionViewLayout = StretchyHeaderLayout()
        
        blurView.frame = UIApplication.shared.keyWindow!.frame
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(tapFunc(_:)))
//        cv.addGestureRecognizer(tap)
        
        orignialUser = userView.frame.minX
        original = contentView.frame.minY
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(userLeave(_:)))
        blurView.addGestureRecognizer(tap2)
        
        userIcon.layer.cornerRadius = userIcon.frame.width / 2
        userIcon.layer.borderColor = UIColor.lightGray.cgColor
        userIcon.layer.borderWidth = 1
        
        userView.frame = CGRect(x: 0 - userView.frame.width, y: 0, width: userView.frame.width, height: self.view.frame.height)
        
        orignialUser = userView.frame.minX
        
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to: #selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = "42E89D".toUIColor
        }
        
        let direction = PanDirectionGestureRecognizer(direction: .horizontal, target: self, action: #selector(userPan(_:)))
        
        userView.addGestureRecognizer(direction)
        
        
    }

}
