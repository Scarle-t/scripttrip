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
            
            let imgTap = UITapGestureRecognizer(target: self, action: #selector(showImg(_:)))
            
            cell.img.image = UIImage()
            cell.img.frame = CGRect(x: 0, y: 0, width: cell.contentView.frame.width, height: cell.contentView.frame.width / 3 * 2)
            cell.img.contentMode = .scaleAspectFit
            cell.img.isUserInteractionEnabled = true
            cell.img.addGestureRecognizer(imgTap)
            
            cell.content.frame = CGRect(x: 0, y: cell.img.frame.maxY, width: cell.contentView.frame.width, height: heightForItem[indexPath.row - 1])
            cell.content.font = UIFont(name: "AnevirNext-Regular", size: 18)
            cell.content.numberOfLines = 0
            cell.content.text = displayTrip?.Items[indexPath.row - 1].I_Content
            
            cell.contentView.addSubview(cell.img)
            cell.contentView.addSubview(cell.content)
            if imgs[displayTrip!.Items[indexPath.row - 1]] == nil{
                group.enter()
                Network().getPhoto(url: "https://scripttrip.scarletsc.net/img/\(displayTrip!.Items[indexPath.row - 1].I_Image)") { (data, response, error) in
                    guard let data = data, error == nil else {
                        cell.img.image = UIImage()
                        self.group.leave()
                        return
                    }
                    self.imgs[self.displayTrip!.Items[indexPath.row - 1]] = UIImage(data: data)
                    self.group.leave()
                }
                group.notify(queue: .main) {
                    self.contents.reloadItems(at: [indexPath])
                }
            }
            
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2, animations: {
                    cell.img.image = self.imgs[self.displayTrip!.Items[indexPath.row - 1]]
                    self.tapImgs[imgTap] = self.imgs[self.displayTrip!.Items[indexPath.row - 1]]
                })
            }
            
            return cell
        }
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as! contentHeader
        
        let imgTap = UITapGestureRecognizer(target: self, action: #selector(showImg(_:)))
        
        tapImgs[imgTap] = headerImg
        
        header.close.frame = CGRect(x: 17, y: 17, width: 35, height: 35)
        header.close.layer.cornerRadius = 35 / 2
        header.close.setImage(#imageLiteral(resourceName: "cross"), for: .normal)
        header.close.addTarget(self, action: #selector(hide), for: .touchUpInside)
        header.close.backgroundColor = .init(white: 1, alpha: 0.9)
        
        header.img.frame = header.frame
        header.img.contentMode = .scaleAspectFill
        header.img.clipsToBounds = true
        header.img.image = headerImg
        header.img.isUserInteractionEnabled = true
        header.img.addGestureRecognizer(imgTap)
        
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
    var delegate: UIViewController?
    var displayTrip: Trip?
    var headerImg: UIImage?
    var imgs = [Item : UIImage]()
    var isShown = false
    var tapImgs = [UITapGestureRecognizer : UIImage]()
    let group = DispatchGroup()
    let network = Network()
    
    var window: UIWindow?
    var view: UIView!
    var contents: UICollectionView!
    var addBookmark: UIButton!
    var actionBtn: UIButton!
    var shareBtn: UIButton!
    var heightForItem = [CGFloat]()
    var dimBg: UIView!
    
    //INIT
    init(delegate: UIViewController, haveTabBar: Bool){
        super.init()
        DispatchQueue.main.async {
            self.delegate = delegate
            self.window = UIApplication.shared.keyWindow
            self.view = UIView()
            self.addBookmark = UIButton()
            self.actionBtn = UIButton()
            self.shareBtn = UIButton()
            self.dimBg = UIView()
            self.contents = UICollectionView(frame: CGRect.zero, collectionViewLayout: StretchyHeaderLayout())
            self.contents.delegate = self
            self.contents.dataSource = self
            if let layout = self.contents.collectionViewLayout as? StretchyHeaderLayout {
                layout.minimumLineSpacing = 50
                self.contents.collectionViewLayout = layout
            }
        
            self.displayTrip = nil
            self.contents.register(mainContent.self, forCellWithReuseIdentifier: "mainContent")
            self.contents.register(secondaryContent.self, forCellWithReuseIdentifier: "otherContent")
            self.contents.register(contentTitle.self, forCellWithReuseIdentifier: "contentTitle")
            self.contents.register(contentHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
            self.contents.backgroundColor = .white
            self.contents.alwaysBounceVertical = true
            
            self.view.frame = CGRect(x: 0, y: 75, width: (self.window?.frame.width)!, height: (self.window?.frame.height)! - 75)
            self.view.frame.origin.y = (self.window?.frame.height)!
            self.view.layer.cornerRadius = 17
            self.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            self.view.clipsToBounds = true
            
            self.contents.frame = self.view.frame
            
            self.addBookmark.setImage(#imageLiteral(resourceName: "plus"), for: .normal)
            self.addBookmark.backgroundColor = .init(white: 1, alpha: 0.9)
            self.addBookmark.frame = CGRect(x: self.view.frame.maxX - 17 - 35, y: 17, width: 45, height: 45)
            self.addBookmark.layer.cornerRadius = 35 / 2
            self.addBookmark.addTarget(self, action: #selector(self.addBk(_:)), for: .touchUpInside)
            self.addBookmark.alpha = 0
            
            self.actionBtn.setImage(#imageLiteral(resourceName: "action"), for: .normal)
            self.actionBtn.backgroundColor = .init(white: 1, alpha: 0.9)
            self.actionBtn.frame = CGRect(x: self.view.frame.maxX - 17 - 35, y: 17, width: 45, height: 45)
            self.actionBtn.layer.cornerRadius = 45 / 2
            self.actionBtn.addTarget(self, action: #selector(self.showAction(_:)), for: .touchUpInside)
            
            self.shareBtn.setImage(#imageLiteral(resourceName: "share"), for: .normal)
            self.shareBtn.backgroundColor = .init(white: 1, alpha: 0.9)
            self.shareBtn.frame = CGRect(x: self.view.frame.maxX - 17 - 35, y: 17, width: 45, height: 45)
            self.shareBtn.layer.cornerRadius = 35 / 2
            self.shareBtn.addTarget(self, action: #selector(self.share(_:)), for: .touchUpInside)
            self.shareBtn.alpha = 0
            
            self.dimBg.frame = (self.window?.frame)!
            self.dimBg.backgroundColor = .black
            self.dimBg.alpha = 0
            
            let tapDismiss = UITapGestureRecognizer(target: self, action: #selector(self.hide))
            self.dimBg.addGestureRecognizer(tapDismiss)
            
            self.view.addSubview(self.contents)
            self.view.addSubview(self.shareBtn)
            self.view.addSubview(self.addBookmark)
            self.view.addSubview(self.actionBtn)
            
            self.contents.fillSuperview()
            
            if haveTabBar{
                UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.view.addSubview(self.dimBg)
                UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.view.addSubview(self.view)
            }else{
                delegate.view.addSubview(self.dimBg)
                delegate.view.addSubview(self.view)
            }
            self.isShown = false
            self.contents.reloadData()
        }
        
    }
    
    //ACTION
    @objc func showAction(_ sender: UIButton){
        
        switch sender.tag{
        case 0:
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut, animations: {
                self.addBookmark.alpha = 1
                self.shareBtn.alpha = 1
                
                self.addBookmark.frame.origin.x -= 60
                self.addBookmark.frame.origin.y += 10
                
                self.shareBtn.frame.origin.x -= 25
                self.shareBtn.frame.origin.y += 60
                
                self.actionBtn.frame = CGRect(x: self.actionBtn.frame.minX, y: self.actionBtn.frame.minY, width: 35, height: 35)
                self.actionBtn.frame.origin.y += 10
                
                self.actionBtn.setImage(#imageLiteral(resourceName: "cross"), for: .normal)
                
                self.actionBtn.layer.cornerRadius = 35 / 2
                
            }, completion: nil)
            sender.tag = 1
        case 1:
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut, animations: {
                self.actionBtn.layer.cornerRadius = 45 / 2
                
                self.actionBtn.frame = CGRect(x: self.actionBtn.frame.minX, y: self.actionBtn.frame.minY, width: 45, height: 45)
                self.actionBtn.frame.origin.y -= 10
                
                self.actionBtn.setImage(#imageLiteral(resourceName: "action"), for: .normal)
                
                self.addBookmark.frame.origin.x += 60
                self.addBookmark.frame.origin.y -= 10
                
                self.shareBtn.frame.origin.x += 25
                self.shareBtn.frame.origin.y -= 60
                
                self.addBookmark.alpha = 0
                self.shareBtn.alpha = 0
            }, completion: nil)
            sender.tag = 0
        default:
            break
        }
        
        
        
    }
    @objc func addBk(_ sender: UIButton){
        network.send(url: "https://scripttrip.scarletsc.net/iOS/bookmark.php", method: "POST", query: "user=\(Session.user.UID)&trip=\(displayTrip!.TID)") { (data) in
            guard let result = Session.parser.parse(data!) else {return}
            for item in result{
                if (item["Result"] as! String) == "OK"{
                    SVProgressHUD.showSuccess(withStatus: nil)
                    SVProgressHUD.dismiss(withDelay: 1.5)
                    self.checkBookmark()
                }else{
                    SVProgressHUD.showInfo(withStatus: Localized.Fail.rawValue.localized() + "\n\(item["Reason"] as! String)")
                    SVProgressHUD.dismiss(withDelay: 1.5)
                }
            }
        }
    }
    @objc func share(_ sender: UIButton){
        let text = "Let's go together! - \(displayTrip!.T_Title)\nhttps://scripttrip.scarletsc.net"
        let textToShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.present(activityViewController, animated: true, completion: nil)
    }
    @objc func showImg(_ sender: UITapGestureRecognizer){
        let photo = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "imgZoom") as! Photo
        photo.img = tapImgs[sender]
        delegate?.present(photo, animated: true, completion: nil)
    }
    
    func calculateTextHeight(){
        heightForItem.removeAll()
        for item in displayTrip!.Items{
            heightForItem.append(item.I_Content.calculateHeight(width: contents.frame.width, font: UIFont(name: "AvenirNext-Regular", size: 18)!))
        }
    }
    
    func checkBookmark(){
        network.send(url: "https://scripttrip.scarletsc.net/iOS/bookmark.php?user=\(Session.user.UID)&trip=\(displayTrip!.TID)", method: "GET", query: nil) { (data) in
            guard let result = Session.parser.parse(data!) else {return}
            DispatchQueue.main.async {
                for item in result{
                    if (item["Result"] as! String) == "Exist"{
                        self.addBookmark.removeFromSuperview()
                    }else{
                        self.view.addSubview(self.addBookmark)
                    }
                }
            }
        }
    }
    
    func show(){
        isShown = true
        contents.setContentOffset(CGPoint(x: 0,y: 0), animated: false)
        calculateTextHeight()
        checkBookmark()
        if headerImg == nil {
            if Session.imgCache.object(forKey: displayTrip!) == nil{
                Network().getPhoto(url: "https://scripttrip.scarletasc.net/img/\(displayTrip!.Items[0].I_Image)") { (data, response, error) in
                    guard let imgData = data, error != nil else {return}
                    self.headerImg = UIImage(data: imgData)
                    Session.imgCache.setObject(UIImage(data: imgData)!, forKey: self.displayTrip!)
                    self.contents.reloadData()
                }
            }else{
                headerImg = Session.imgCache.object(forKey: displayTrip!)
            }
        }
        DispatchQueue.main.async {
            self.contents.reloadData()
        }
        
        if !UserDefaults.standard.bool(forKey: "reduceMotion"){
            self.view.alpha = 1
            UIView.animate(withDuration: slideAnimationTime, delay: 0, options: .curveEaseOut, animations: {
                self.view.frame.origin.y = 75
                self.dimBg.alpha = dimViewAlpha
            }, completion: nil)
        }else{
            self.view.frame.origin.y = 75
            self.view.alpha = 0
            UIView.animate(withDuration: slideAnimationTime, delay: 0, options: .curveEaseOut, animations: {
                self.view.alpha = 1
                self.dimBg.alpha = dimViewAlpha
            }, completion: nil)
        }
        
        
    }
    func shakeShow(){
        let originalAnchor = view.layer.anchorPoint
        let originalTransform = view.transform
        calculateTextHeight()
        checkBookmark()
        if !UserDefaults.standard.bool(forKey: "reduceMotion"){
            if isShown {
                view.layer.anchorPoint = CGPoint(x: window!.center.x, y: view.frame.maxY)
                UIView.animate(withDuration: 0.07) {
                    self.view.transform = CGAffineTransform(rotationAngle: -0.05)
                }
                UIView.animate(withDuration: 0.07, delay: 0.08, options: .curveLinear, animations: {
                    self.view.transform = CGAffineTransform(rotationAngle: 0.1)
                }, completion: nil)
                UIView.animate(withDuration: 0.07, delay: 0.16, options: .curveLinear, animations: {
                    self.view.transform = originalTransform
                }, completion: nil)
            }else{
                view.frame.origin.x = window!.frame.maxX
                view.frame.origin.y = 75
                UIView.animate(withDuration: 0.075, delay: 0, options: .curveEaseIn, animations: {
                    self.view.frame.origin.x = self.window!.frame.minY
                }, completion: nil)
                view.layer.anchorPoint = CGPoint(x: window!.center.x, y: view.frame.maxY)
                UIView.animate(withDuration: 0.07, delay: 0.08, options: .curveLinear, animations: {
                    self.view.transform = CGAffineTransform(rotationAngle: -0.03)
                }, completion: nil)
                UIView.animate(withDuration: 0.07, delay: 0.08, options: .curveLinear, animations: {
                    self.view.transform = CGAffineTransform(rotationAngle: 0.06)
                }, completion: nil)
                UIView.animate(withDuration: 0.07, delay: 0.16, options: .curveLinear, animations: {
                    self.view.transform = originalTransform
                    self.dimBg.alpha = 0.4
                }, completion: nil)
            }
        }
        
        contents.setContentOffset(CGPoint(x: 0,y: 0), animated: false)
        if headerImg == nil {
            if Session.imgCache.object(forKey: displayTrip!) == nil{
                Network().getPhoto(url: "https://scripttrip.scarletasc.net/img/\(displayTrip!.Items[0].I_Image)") { (data, response, error) in
                    guard let imgData = data, error != nil else {return}
                    self.headerImg = UIImage(data: imgData)
                    Session.imgCache.setObject(UIImage(data: imgData)!, forKey: self.displayTrip!)
                    self.contents.reloadData()
                }
            }else{
                headerImg = Session.imgCache.object(forKey: displayTrip!)
            }
        }
        DispatchQueue.main.async {
            
            if UserDefaults.standard.bool(forKey: "reduceMotion"){
                if self.isShown{
                    UIView.animate(withDuration: fadeAnimationTime, delay: 0, options: .curveEaseOut, animations: {
                        self.contents.alpha = 0
                    }, completion: nil)
                }
            }
            
            self.contents.reloadData()
            
            if UserDefaults.standard.bool(forKey: "reduceMotion"){
                if self.isShown{
                    UIView.animate(withDuration: fadeAnimationTime, delay: 0, options: .curveEaseOut, animations: {
                        self.contents.alpha = 1
                        self.dimBg.alpha = 0.4
                    }, completion: nil)
                }else{
                    self.view.alpha = 0
                    self.view.frame.origin.y = 75
                    self.view.frame.origin.x = 0
                    UIView.animate(withDuration: fadeAnimationTime, delay: 0.07, options: .curveEaseOut, animations: {
                        self.view.alpha = 1
                        self.dimBg.alpha = 0.4
                    }, completion: nil)
                }
            }
        }
        view.layer.anchorPoint = originalAnchor
        isShown = true
    }
    
    @objc func hide(){
        if !UserDefaults.standard.bool(forKey: "reduceMotion"){
            UIView.animate(withDuration: slideAnimationTime, delay: 0, options: .curveEaseOut, animations: {
                self.view.frame.origin.y = (self.window?.frame.height)!
                self.dimBg.alpha = 0
                self.isShown = false
            }, completion: nil)
        }else{
            UIView.animate(withDuration: slideAnimationTime, delay: 0, options: .curveEaseOut, animations: {
                self.view.alpha = 0
                self.dimBg.alpha = 0
                self.isShown = false
            }, completion: { _ in
                self.view.frame.origin.y = (self.window?.frame.height)!
            })
        }
        
        if actionBtn.tag == 1{
                
            actionBtn.frame = CGRect(x: self.actionBtn.frame.minX, y: self.actionBtn.frame.minY, width: 45, height: 45)
            actionBtn.frame.origin.y -= 10
            
            actionBtn.setImage(#imageLiteral(resourceName: "action"), for: .normal)
            
            addBookmark.frame.origin.x += 60
            addBookmark.frame.origin.y -= 10
            
            shareBtn.frame.origin.x += 25
            shareBtn.frame.origin.y -= 60
            
            addBookmark.alpha = 0
            shareBtn.alpha = 0
            actionBtn.tag = 0
        }
        headerImg = nil
    }
}
