//
//  Bookmarks.swift
//  fyp
//
//  Created by Scarlet on 5/7/31 H.
//  Copyright © 31 Scarlet. All rights reserved.
//

import UIKit

class Bookmarks: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NetworkDelegate{
    //VARIABLE
    let network = Network()
    let group = DispatchGroup()
    var selectedCategory: Category?
    var trips: [Trip]?
    var imgs = [Trip : UIImage]()
    var tripView: TripView!
    var btnTrip = [UIButton : Trip]()
    var mainRefresh: UIRefreshControl?
    
    //IBOUTLET
    @IBOutlet weak var cv: UICollectionView!
    
    //IBACTION
    @IBAction func back(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //DELEGATION
        //COLLECTION VIEW
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trips?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! featuredCell
        
        cell.alpha = 0
        if !UserDefaults.standard.bool(forKey: "reduceMotion"){
            cell.contentView.frame.origin.x += 500
        }
        
        guard let trip = trips?[indexPath.row], trip.TID != 0 else {return cell}
        
        cell.layer.masksToBounds = false
        cell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.layer.shadowOpacity = 0.1
        
        cell.removeBK.layer.shadowOpacity = 0.7
        cell.removeBK.layer.shadowColor = UIColor.lightGray.cgColor
        cell.removeBK.layer.shadowOffset = CGSize(width: 0, height: 1)
        cell.removeBK.layer.cornerRadius = 35 / 2
        btnTrip[cell.removeBK] = trip
        cell.removeBK.addTarget(self, action: #selector(removeBk(_:)), for: .touchUpInside)
        
        cell.title.text = trips?[indexPath.row].T_Title
        
        cell.view.layer.cornerRadius = 15
        
        if imgs[trip] == nil{
            if Session.imgCache.object(forKey: trip) == nil{
                group.enter()
                network.getPhoto(url: "https://scripttrip.scarletsc.net/img/\(trip.Items[0].I_Image)") { (data, response, error) in
                    guard let data = data, error == nil else {return}
                    self.imgs[trip] = UIImage(data: data)!
                    Session.imgCache.setObject(UIImage(data: data)!, forKey: trip)
                    self.group.leave()
                }
                group.notify(queue: .main) {
                    self.cv.reloadItems(at: [indexPath])
                }
            }else{
                self.imgs[trip] = Session.imgCache.object(forKey: trip)
            }
        }
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2, animations: {
                cell.img.image = self.imgs[trip]
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
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind{
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as! categoryTripsHeader

            header.frame = CGRect(x: 0 , y: 0, width: collectionView.frame.width, height: 62)
            
            header.title.text = Localized.bookmarks.rawValue.localized()
            
            return header

        default:
            return UICollectionReusableView()
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: collectionView.frame.width, height: 62)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let trip = trips?[indexPath.row] else {return}
        tripView.displayTrip = trip
        tripView.headerImg = imgs[trip]
        tripView.show()
        DispatchQueue.main.async {
            let postview = self.storyboard?.instantiateViewController(withIdentifier: "postView") as! postView
            postview.tripView = self.tripView
            self.present(postview, animated: true, completion: nil)
        }
    }
    
        //NETWORK
    func ResponseHandle(data: Data) {
        trips = Session.shared.parseTrip(Session.parser.parseNested(data))
        DispatchQueue.main.async {
            if self.mainRefresh!.isRefreshing{
                self.mainRefresh?.endRefreshing()
            }
            self.cv.reloadData()
        }
    }
    
    //OBJC FUNC
    @objc func removeBk(_ sender: UIButton){
        let alert = UIAlertController(title: Localized.removeBKMsg.rawValue.localized(), message: btnTrip[sender]?.T_Title, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Localized.Yes.rawValue.localized(), style: .default, handler: { _ in
            self.network.send(url: "https://scripttrip.scarletsc.net/iOS/bookmark.php?user=\(Session.user.UID)&trip=\(self.btnTrip[sender]!.TID)", method: "DELETE", query: nil) { (data) in
                guard let result = Session.parser.parse(data!) else {return}
                for item in result{
                    if (item["Result"] as! String) == "OK"{
                        self.setup()
                    }else{
                        SVProgressHUD.showInfo(withStatus: Localized.Fail.rawValue.localized() + "\n\(item["Reason"] as! String)")
                        SVProgressHUD.dismiss(withDelay: 1.5)
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: Localized.Cancel.rawValue.localized(), style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    @objc func refreshFeatured(_ sender: UIRefreshControl){
        setup()
    }
    
    //FUNC
    func delegate(){
        cv.delegate = self
        cv.dataSource = self
        
        network.delegate = self
        
        tripView = TripView(delegate: self, haveTabBar: false)
    }
    
    func layout(){
        let layout = cv.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionHeadersPinToVisibleBounds = true
        cv.collectionViewLayout = layout
        DispatchQueue.main.async {
            self.mainRefresh = UIRefreshControl()
            self.mainRefresh!.addTarget(self, action: #selector(self.refreshFeatured(_:)), for: .valueChanged)
            self.mainRefresh!.tintColor = darkGreen
            self.cv.refreshControl = self.mainRefresh
        }
    }
    
    func setup(){
        network.send(url: "https://scripttrip.scarletsc.net/iOS/getTrips.php?user=\(Session.user.UID)", method: "GET", query: nil)
    }
    
    //VIEW CONTROLLER
    override func viewDidLoad(){
        super.viewDidLoad()
        
        delegate()
        
        layout()
        
        setup()
        
    }
    
}
