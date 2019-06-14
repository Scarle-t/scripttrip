//
//  History.swift
//  fyp
//
//  Created by Scarlet on 5/7/31 H.
//  Copyright © 31 Scarlet. All rights reserved.
//

import UIKit

class History: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NetworkDelegate{
    //VARIABLE
    let network = Network()
    let group = DispatchGroup()
    var selectedCategory: Category?
    var trips: [Trip]?
    var groupedTrip = [[Trip]]()
    var imgs = [Trip : UIImage]()
    var tripView: TripView!
    var mainRefresh: UIRefreshControl?
    @IBOutlet weak var closeBtn: UIButton!
    
    //IBOUTLET
    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var heading: UILabel!
    
    //IBACTION
    @IBAction func back(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //DELEGATION
    //COLLECTION VIEW
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groupedTrip[section].count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return groupedTrip.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! featuredCell
        
        cell.alpha = 0
        if !UserDefaults.standard.bool(forKey: "reduceMotion"){
            cell.contentView.frame.origin.x += 500
        }
        
        let trip = groupedTrip[indexPath.section][indexPath.row]
        
        if trip.TID == 0{
            return cell
        }
        
        cell.layer.masksToBounds = false
        cell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.layer.shadowOpacity = 0.1
        
        cell.title.text = trip.T_Title
        
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
            
            header.title.text = groupedTrip[indexPath.section][0].ts
            
            return header
            
        default:
            return UICollectionReusableView()
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: collectionView.frame.width, height: 62)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let trip = groupedTrip[indexPath.section][indexPath.row]
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
        var prevTS = ""
        var curIndex = -1
        groupedTrip.removeAll()
        if trips?[0].TID != 0{
            for i in 0..<trips!.count{
                if trips?[i].ts != prevTS{
                    groupedTrip.append([trips![i]])
                    curIndex += 1
                }else{
                    groupedTrip[curIndex].append(trips![i])
                }
                prevTS = (trips?[i].ts)!
            }
            DispatchQueue.main.async {
                if self.mainRefresh!.isRefreshing{
                    self.mainRefresh?.endRefreshing()
                }
                self.cv.reloadData()
            }
        }
    }
    
    //OBJC FUNC
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
        if #available(iOS 13.0, *){
        }else{
            closeBtn.setImage(#imageLiteral(resourceName: "cross_tint"), for: .normal)
        }
        let layout = cv.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionHeadersPinToVisibleBounds = true
        layout.headerReferenceSize = .init(width: self.view.frame.width, height: 62)
        cv.collectionViewLayout = layout
        heading.text = Localized.history.rawValue.localized()
        DispatchQueue.main.async {
            self.mainRefresh = UIRefreshControl()
            self.mainRefresh!.addTarget(self, action: #selector(self.refreshFeatured(_:)), for: .valueChanged)
            self.mainRefresh!.tintColor = darkGreen
            self.cv.refreshControl = self.mainRefresh
        }
    }
    
    func setup(){
        network.send(url: "https://scripttrip.scarletsc.net/iOS/getTrips.php?user=\(Session.user.UID)&history=1", method: "GET", query: nil)
    }
    
    //VIEW CONTROLLER
    override func viewDidLoad(){
        super.viewDidLoad()
        
        delegate()
        
        layout()
        
        setup()
        
    }
    
}
