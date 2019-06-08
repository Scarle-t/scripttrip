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
            
            cell.title.frame = CGRect(x: 0, y: 0, width: cell.frame.width - 15, height: 45)
            cell.title.font = UIFont(name: "AvenirNext-Heavy", size: 30)
            cell.title.adjustsFontSizeToFitWidth = true
            cell.title.textAlignment = .right
            cell.title.numberOfLines = 0
            cell.title.text = displayTrip?.T_Title
            cell.title.backgroundColor = .clear
            
            cell.addSubview(cell.title)
            
            return cell
        }else if indexPath.row == 1{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mainContent", for: indexPath) as! mainContent
            
            cell.content.frame = CGRect(x: 0, y: 0, width: cell.contentView.frame.width, height: cell.contentView.frame.height)
            cell.content.font = UIFont(name: "AvenirNext-Regular", size: 18)
            cell.content.dataDetectorTypes = [.address, .link, .calendarEvent, .flightNumber, .phoneNumber]
            cell.content.isEditable = false
            cell.content.isScrollEnabled = false
            cell.content.tintColor = darkGreen
            cell.content.text = displayTrip?.Items[0].I_Content
            
            cell.contentView.addSubview(cell.content)
            cell.content.fillSuperview(padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
            
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "otherContent", for: indexPath) as! secondaryContent
            
            let imgTap = UITapGestureRecognizer(target: self, action: #selector(showImg(_:)))
            
            cell.img.image = UIImage()
            cell.img.frame = CGRect(x: 0, y: 0, width: cell.contentView.frame.width, height: cell.contentView.frame.width / 3 * 2)
            cell.img.contentMode = .scaleAspectFill
            cell.img.clipsToBounds = true
            cell.img.isUserInteractionEnabled = true
            cell.img.layer.cornerRadius = 12
            if #available(iOS 11.0, *){
                cell.img.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            }else{
                
            }
            cell.img.addGestureRecognizer(imgTap)
            
            cell.content.frame = CGRect(x: 0, y: cell.img.frame.maxY, width: cell.contentView.frame.width - 20, height: heightForItem[indexPath.row - 1])
            cell.content.frame.origin.x += 10
            cell.content.font = UIFont(name: "AvenirNext-Regular", size: 18)
            cell.content.dataDetectorTypes = [.address, .link, .calendarEvent, .flightNumber, .phoneNumber]
            cell.content.isEditable = false
            cell.content.isScrollEnabled = false
            cell.content.tintColor = darkGreen
            cell.content.text = displayTrip?.Items[indexPath.row - 1].I_Content
            
            cell.contentView.addSubview(cell.img)
            cell.contentView.addSubview(cell.content)
            if displayTrip!.Items[indexPath.row - 1].I_Image != "0"{
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
            }else{
                if isCustomPlan{
                    cell.img.alpha = 0
                    cell.content.frame.origin.y -= (collectionView.frame.width / 3 * 2)
                }
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
        header.close.setImage(#imageLiteral(resourceName: "cross_tint"), for: .normal)
        header.close.addTarget(self, action: #selector(hide), for: .touchUpInside)
        
        if #available(iOS 13.0, *) {
            header.close.backgroundColor = .systemBackground
        } else {
            //fallback statements
            header.close.backgroundColor = .white
        }
        
        header.close.layer.shadowOpacity = 0.7
        header.close.layer.shadowColor = UIColor.lightGray.cgColor
        header.close.layer.shadowOffset = CGSize(width: 0, height: 1)
        
        header.img.frame = header.frame
        header.img.contentMode = .scaleAspectFill
        header.img.clipsToBounds = true
        header.img.image = headerImg
        header.img.isUserInteractionEnabled = true
        header.img.addGestureRecognizer(imgTap)
        
        header.addSubview(header.img)
        if !haveTabBar{
//            header.addSubview(header.close)
        }
        
        header.img.fillSuperview()
        
        if gradientMask != nil {
            header.img.layer.addSublayer(gradientMask!)
        }
        
        return header
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 0{
            return .init(width: collectionView.frame.width, height: 45)
        }else if indexPath.row == 1{
            return .init(width: collectionView.frame.width, height: heightForItem[0])
        }else{
            if isCustomPlan{
                return .init(width: collectionView.frame.width, height: heightForItem[indexPath.row - 1])
            }else{
                return .init(width: collectionView.frame.width, height: heightForItem[indexPath.row - 1] + (collectionView.frame.width / 3 * 2))
            }
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
    var gradientMask: CAGradientLayer?
    var isCustomPlan: Bool!
    var haveTabBar = false
    
    //INIT
    init(delegate: UIViewController, haveTabBar: Bool){
        super.init()
        DispatchQueue.main.async {
            self.haveTabBar = haveTabBar
            self.isCustomPlan = false
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
            if #available(iOS 13.0, *) {
                self.contents.backgroundColor = .systemBackground
            } else {
                // Fallback on earlier versions
                self.contents.backgroundColor = .white
            }
            self.contents.alwaysBounceVertical = true
            
            self.view.frame = CGRect(x: 0, y: 75, width: (self.window?.frame.width)!, height: (self.window?.frame.height)! - 75)
            self.view.frame.origin.y = (self.window?.frame.height)!
            self.view.layer.cornerRadius = 17
            if #available(iOS 11.0, *) {
                self.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            } else {
                // Fallback on earlier versions
            }
            self.view.clipsToBounds = true
            
            self.contents.frame = self.view.frame
            
            self.addBookmark.setImage(#imageLiteral(resourceName: "plus_tint"), for: .normal)
            self.addBookmark.frame = CGRect(x: self.view.frame.maxX - 17 - 35, y: 17, width: 35, height: 35)
            self.addBookmark.layer.cornerRadius = 35 / 2
            self.addBookmark.addTarget(self, action: #selector(self.addBk(_:)), for: .touchUpInside)
            self.addBookmark.alpha = 0
            self.addBookmark.layer.shadowOpacity = 0.7
            self.addBookmark.layer.shadowColor = UIColor.lightGray.cgColor
            self.addBookmark.layer.shadowOffset = CGSize(width: 0, height: 1)
            
            self.actionBtn.setImage(#imageLiteral(resourceName: "more_tint"), for: .normal)
            self.actionBtn.frame = CGRect(x: self.view.frame.maxX - 17 - 35, y: 17, width: 35, height: 35)
            self.actionBtn.layer.cornerRadius = 35 / 2
            self.actionBtn.addTarget(self, action: #selector(self.showAction(_:)), for: .touchUpInside)
            self.actionBtn.layer.shadowOpacity = 0.7
            self.actionBtn.layer.shadowColor = UIColor.lightGray.cgColor
            self.actionBtn.layer.shadowOffset = CGSize(width: 0, height: 1)
            
            self.shareBtn.setImage(#imageLiteral(resourceName: "action_tint"), for: .normal)
            self.shareBtn.frame = CGRect(x: self.view.frame.maxX - 17 - 35, y: 17, width: 35, height: 35)
            self.shareBtn.layer.cornerRadius = 35 / 2
            self.shareBtn.addTarget(self, action: #selector(self.share(_:)), for: .touchUpInside)
            self.shareBtn.alpha = 0
            self.shareBtn.layer.shadowOpacity = 0.7
            self.shareBtn.layer.shadowColor = UIColor.lightGray.cgColor
            self.shareBtn.layer.shadowOffset = CGSize(width: 0, height: 1)
            
            if #available(iOS 13.0, *) {
                self.addBookmark.backgroundColor = .systemBackground
                self.actionBtn.backgroundColor = .systemBackground
                self.shareBtn.backgroundColor = .systemBackground
            } else {
                //fallback statements
                self.addBookmark.backgroundColor = .white
                self.actionBtn.backgroundColor = .white
                self.shareBtn.backgroundColor = .white
            }
            
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
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                if !self.isCustomPlan{
                    self.addBookmark.alpha = 1
                }
                self.shareBtn.alpha = 1
                
                self.addBookmark.frame.origin.x -= 60
                self.addBookmark.frame.origin.y += 10
                
                self.shareBtn.frame.origin.x -= 25
                self.shareBtn.frame.origin.y += 60
                
                self.actionBtn.transform = CGAffineTransform(rotationAngle: 2 * CGFloat.pi / 4)
            }, completion: nil)
            sender.tag = 1
        case 1:
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.actionBtn.transform = CGAffineTransform(rotationAngle: 2 * CGFloat.pi / 2)
                
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
//        let text = "Let's go together! - \(displayTrip!.T_Title)\nhttps://scripttrip.scarletsc.net"
        
        SVProgressHUD.show()
        
        var totalHeight = CGFloat.zero
        for item in heightForItem{
            totalHeight += item + 10
        }
        let titleHeight = displayTrip!.T_Title.calculateHeight(width: contents.frame.width - 20, font: UIFont(name: "AvenirNext-heavy", size: 30)!)
        totalHeight += titleHeight + 10
        var offset = CGFloat.zero
        
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, CGRect(x: 0, y: 0, width: contents.frame.width, height: totalHeight), nil)
        let context = UIGraphicsGetCurrentContext()!
        
        let rendView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: totalHeight))
        if #available(iOS 13.0, *) {
            rendView.backgroundColor = .systemBackground
        } else {
            //fallback statements
        }
        let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: rendView.frame.width, height: titleHeight))
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        lbl.font = UIFont(name: "AnevirNext-Heavy", size: 30)
        lbl.text = displayTrip?.T_Title
        rendView.addSubview(lbl)
        
        offset = titleHeight + 10
        
        for i in 0..<displayTrip!.Items.count{
            let lbl2 = UILabel(frame: CGRect(x: 0, y: 0, width: rendView.frame.width, height: heightForItem[i]))
            lbl2.frame.origin.y = offset
            lbl2.numberOfLines = 0
            lbl2.font = UIFont(name: "AnevirNext-Regular", size: 18)
            lbl2.frame.origin.x += 10
            lbl2.text = displayTrip?.Items[i].I_Content
            rendView.addSubview(lbl2)
            offset += heightForItem[i] + 10
        }
        
        UIGraphicsBeginPDFPage()
        rendView.layer.render(in: context)
        UIGraphicsEndPDFContext()
        
        SVProgressHUD.dismiss()

        let textToShare = [pdfData]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        delegate?.present(activityViewController, animated: true, completion: nil)
    }
    @objc func showImg(_ sender: UITapGestureRecognizer){
        if !isCustomPlan{
            let photo = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "imgZoom") as! Photo
            photo.img = tapImgs[sender]
            delegate?.present(photo, animated: true, completion: nil)
        }
    }
    
    func calculateTextHeight(){
        heightForItem.removeAll()
        for item in displayTrip!.Items{
            heightForItem.append(item.I_Content.calculateHeight(width: contents.frame.width - 20, font: UIFont(name: "AvenirNext-Regular", size: 18)!) + 30)
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
                group.enter()
                Network().getPhoto(url: "https://scripttrip.scarletasc.net/img/\(displayTrip!.Items[0].I_Image)") { (data, response, error) in
                    guard let imgData = data, error != nil else {return}
                    self.headerImg = UIImage(data: imgData)
                    Session.imgCache.setObject(UIImage(data: imgData)!, forKey: self.displayTrip!)
                    self.group.leave()
                }
                group.notify(queue: .main) {
                    self.contents.reloadSections(IndexSet(arrayLiteral: 0))
                }
            }else{
                headerImg = Session.imgCache.object(forKey: displayTrip!)
            }
        }
        
        if isCustomPlan{
            addBookmark.alpha = 0
        }
        
        DispatchQueue.main.async {
            self.contents.reloadData()
        }
        
//        if !UserDefaults.standard.bool(forKey: "reduceMotion"){
//            self.view.alpha = 1
//            UIView.animate(withDuration: slideAnimationTime + 0.1, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
//                self.view.frame.origin.y = 65
//                self.dimBg.alpha = dimViewAlpha
//            }, completion: nil)
//        }else{
//            self.view.frame.origin.y = 65
//            self.view.alpha = 0
//            UIView.animate(withDuration: fadeAnimationTime, delay: 0, options: .curveEaseOut, animations: {
//                self.view.alpha = 1
//                self.dimBg.alpha = dimViewAlpha
//            }, completion: nil)
//        }
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
                
            self.actionBtn.transform = CGAffineTransform(rotationAngle: 2 * CGFloat.pi / 2)
            
            addBookmark.frame.origin.x += 60
            addBookmark.frame.origin.y -= 10
            
            shareBtn.frame.origin.x += 25
            shareBtn.frame.origin.y -= 60
            
            addBookmark.alpha = 0
            shareBtn.alpha = 0
            actionBtn.tag = 0
        }
        headerImg = nil
        gradientMask = nil
        isCustomPlan = false
    }
}
