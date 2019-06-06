//
//  ViewController4.swift
//  fyp
//
//  Created by Scarlet on 6/3/2019.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit

class Featured: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, NetworkDelegate {
    
    //VARIABLE
    let session = Session.shared
    let parser = Session.parser
    let network = Network()
    var selectedItem = Trip()
    var imgs = [Trip : UIImage]()
    var textHeight = [Item : CGFloat]()
    var yLoc: CGFloat = 0.0
    var timer = Timer()
    var added = false
    var feedItems = 3
    var state = ""
    var mainRefresh: UIRefreshControl?
    var tripView: TripView!
    let group = DispatchGroup()
    var lastOffset: CGFloat = 0.0
    
    //IBOUTLET
    @IBOutlet weak var cv: UICollectionView!
    
    //IBACTION
    @IBAction func userBtn(_ sender: UIButton) {
        DispatchQueue.main.async {
            if #available(iOS 13.0, *) {
                let userview = self.storyboard?.instantiateViewController(identifier: "userView") as! userView
                userview.logout = {
                    self.navigationController?.popViewController(animated: false)
                }
                self.present(userview, animated: true, completion: nil)
            } else {
                // Fallback on earlier versions
                self.session.showUserMenu()
            }
            
        }
    }
    
    //DELEGATION
        //COLLECTION VIEW
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return session.getTrips().count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! featuredCell
        
        cell.alpha = 0
        if !UserDefaults.standard.bool(forKey: "reduceMotion"){
            cell.contentView.frame.origin.x += 500
        }
        
        cell.layer.masksToBounds = false
        cell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.layer.shadowOpacity = 0.1
        
        cell.title.text = session.getTrips()[indexPath.row].T_Title

        cell.view.layer.cornerRadius = 15
        
        if imgs[self.session.getTrips()[indexPath.row]] == nil{
            
            if Session.imgCache.object(forKey: self.session.getTrips()[indexPath.row]) == nil{
                group.enter()
                network.getPhoto(url: "https://scripttrip.scarletsc.net/img/\(session.getTrips()[indexPath.row].Items[0].I_Image)") { (data, response, error) in
                    guard let data = data, error == nil else {return}
                    self.imgs[self.session.getTrips()[indexPath.row]] = UIImage(data: data)!
                    Session.imgCache.setObject(UIImage(data: data)!, forKey: self.session.getTrips()[indexPath.row])
                    self.group.leave()
                }
                group.notify(queue: .main) {
                    self.cv.reloadItems(at: [indexPath])
                }
            }else{
                self.imgs[self.session.getTrips()[indexPath.row]] = Session.imgCache.object(forKey: self.session.getTrips()[indexPath.row])
            }
            
        }
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2, animations: {
                cell.img.image = self.imgs[self.session.getTrips()[indexPath.row]]
            })
        }
        
        if !UserDefaults.standard.bool(forKey: "reduceMotion"){
            UIView.animate(withDuration: slideAnimationTime, delay: slideAnimationDelay, options: .curveEaseOut, animations: {
                cell.alpha = 1
                cell.contentView.frame.origin.x -= 500
            }, completion: nil)
        }else{
            UIView.animate(withDuration: fadeAnimationTime, delay: 0, options: .curveEaseOut, animations: {
                cell.alpha = 1
            }, completion: nil)
        }
        
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: self.view.frame.width, height: 62)

    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind{
            case UICollectionView.elementKindSectionHeader:
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as! HeaderView
                
                header.frame = CGRect(x: 0 , y: 0, width: collectionView.frame.width, height: 62)
                
                header.userIcon.setImage(session.usr.iconImage, for: .normal)
                header.userIcon.contentMode = .scaleAspectFill
                header.userIcon.clipsToBounds = true
                header.userIcon.layer.cornerRadius = header.userIcon.frame.width / 2
                
                return header
            
            default:
                return UICollectionReusableView()
        }

    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if UserDefaults.standard.bool(forKey: "history") {
            network.send(url: "https://scripttrip.scarletsc.net/iOS/history.php", method: "POST", query: "user=\(session.usr.UID)&trip=\(session.getTrips()[indexPath.row].TID)") { (_) in
            }
        }
        
        tripView.displayTrip = session.getTrips()[indexPath.row]
        tripView.headerImg = imgs[session.getTrips()[indexPath.row]]
        tripView.show()
        DispatchQueue.main.async {
            if #available(iOS 13.0, *) {
                let postview = self.storyboard?.instantiateViewController(identifier: "postView") as! postView
                postview.tripView = self.tripView
                self.present(postview, animated: true, completion: nil)
            } else {
                // Fallback on earlier versions
            }
        }
    }
    @available(iOS 11.0, *)
    func collectionView(_ collectionView: UICollectionView, shouldSpringLoadItemAt indexPath: IndexPath, with context: UISpringLoadedInteractionContext) -> Bool {
        return true
    }
    
        //NETWORK
    func ResponseHandle(data: Data) {
        DispatchQueue.main.async {
            if self.mainRefresh!.isRefreshing{
                self.mainRefresh!.endRefreshing()
            }
        }
        
        if state == "trip"{
            session.setTrips(session.parseTrip(parser.parseNested(data)))
            DispatchQueue.main.async {
                self.cv.reloadData()
            }
        }
    }
    func httpErrorHandle(httpStatus: HTTPURLResponse) {
        SVProgressHUD.showInfo(withStatus: "\(Localized.httpErrorMsg.rawValue.localized())\n\(httpStatus.statusCode)")
        SVProgressHUD.dismiss(withDelay: 1.5)
        DispatchQueue.main.async {
            self.cv.refreshControl?.endRefreshing()
        }
    }
    func reachabilityError() {
        SVProgressHUD.showError(withStatus: Localized.networkErrorMsg.rawValue.localized())
        SVProgressHUD.dismiss(withDelay: 1.5)
        DispatchQueue.main.async {
            self.cv.refreshControl?.endRefreshing()
        }
    }
    func URLSessionError(error: Error?) {
        SVProgressHUD.showInfo(withStatus: "\(Localized.urlSessionErrorMsg.rawValue.localized())\n\(error ?? Error.self as! Error)")
        SVProgressHUD.dismiss(withDelay: 1.5)
        DispatchQueue.main.async {
            self.cv.refreshControl?.endRefreshing()
        }
    }
    
        //SCROLL VIEW
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.lastOffset > scrollView.contentOffset.y) {
            // move up
            let layout = cv.collectionViewLayout as! UICollectionViewFlowLayout
            layout.sectionHeadersPinToVisibleBounds = true
            cv.collectionViewLayout = layout
        }
        else if (self.lastOffset < scrollView.contentOffset.y) {
            // move down
            let layout = cv.collectionViewLayout as! UICollectionViewFlowLayout
            layout.sectionHeadersPinToVisibleBounds = false
            cv.collectionViewLayout = layout
        }
        
        // update the new position acquired
        self.lastOffset = scrollView.contentOffset.y
    }
    
    //OBJC FUNC
    @objc func refreshFeatured(_ sender: UIRefreshControl){
        state = "trip"
        network.send(url: "https://scripttrip.scarletsc.net/iOS/getTrips.php", method: "GET", query: nil)
    }
    
    //FUNC
    func delegate(){
        cv.dataSource = self
        cv.delegate = self
        network.delegate = self
    }
    
    func layout(){
        SVProgressHUD.dismiss()
    }
    
    func setup(){
        session.setupUserView()
        tripView = TripView(delegate: self, haveTabBar: true)
        DispatchQueue.main.async {
            self.mainRefresh = UIRefreshControl()
            self.mainRefresh!.addTarget(self, action: #selector(self.refreshFeatured(_:)), for: .valueChanged)
            self.mainRefresh!.tintColor = "42DA9D".uiColor
            self.cv.refreshControl = self.mainRefresh
        }
        self.becomeFirstResponder()
        state = "trip"
        network.send(url: "https://scripttrip.scarletsc.net/iOS/getTrips.php", method: "GET", query: nil)
        
        DispatchQueue.main.async {
            self.cv.reloadData()
        }
    }
    
    //VIEW CONTROLLER
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        delegate()
        layout()
        setup()

    }
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if UserDefaults.standard.bool(forKey: "shake") {
            if motion == .motionShake{
                let trip = session.getTrips().randomElement()!
                if UserDefaults.standard.bool(forKey: "history") {
                    network.send(url: "https://scripttrip.scarletsc.net/iOS/history.php", method: "POST", query: "user=\(session.usr.UID)&trip=\(trip.TID)") { (_) in
                    }
                }
                
                tripView.displayTrip = trip
                tripView.headerImg = imgs[trip]
                tripView.show()
                DispatchQueue.main.async {
                    if #available(iOS 13.0, *) {
                        let postview = self.storyboard?.instantiateViewController(identifier: "postView") as! postView
                        postview.tripView = self.tripView
                        self.present(postview, animated: true, completion: nil)
                    } else {
                        // Fallback on earlier versions
                    }
                }
            }
        }
        
    }

}
