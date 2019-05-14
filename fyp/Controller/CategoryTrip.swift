//
//  CategoryTrip.swift
//  fyp
//
//  Created by Scarlet on 5/6/31 H.
//  Copyright © 31 Scarlet. All rights reserved.
//

import UIKit

class CategoryTrip: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NetworkDelegate{
    //VARIABLE
    let network = Network()
    let group = DispatchGroup()
    var selectedCategory: Category?
    var trips: [Trip]?
    var imgs = [Trip : UIImage]()
    var tripView: TripView!
    
    //IBOUTLET
    @IBOutlet weak var cv: UICollectionView!
    
    //IBACTION
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //DELEGATION
    	//COLLECTION VIEW
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trips?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! featuredCell
        
        cell.alpha = 0
        
        guard let trip = trips?[indexPath.row], trip.TID != 0 else {return cell}
        
        cell.layer.masksToBounds = false
        cell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.layer.shadowOpacity = 0.1
        
        cell.title.text = trips?[indexPath.row].T_Title
        
        cell.view.layer.cornerRadius = 15
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            cell.alpha = 1
        }, completion: nil)
        
        if imgs[trip] == nil{
            group.enter()
            network.getPhoto(url: "https://scripttrip.scarletsc.net/img/\(trip.Items[0].I_Image)") { (data, response, error) in
                guard let data = data, error == nil else {return}
                self.imgs[trip] = UIImage(data: data)!
                self.group.leave()
            }
            group.notify(queue: .main) {
                self.cv.reloadItems(at: [indexPath])
            }
        }
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2, animations: {
                cell.img.image = self.imgs[trip]
            })
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind{
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as! categoryTripsHeader
            
            header.frame = CGRect(x: 0 , y: 0, width: collectionView.frame.width, height: 62)
            
            header.title.text = "\(cateEnum.init(rawValue: selectedCategory!.CID)!)".localized()
            
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
        if UserDefaults.standard.bool(forKey: "history") {
            network.send(url: "https://scripttrip.scarletsc.net/iOS/history.php", method: "POST", query: "user=\(Session.user.UID)&trip=\(trip.TID)") { (_) in
            }
        }
        tripView.displayTrip = trip
        tripView.headerImg = imgs[trip]
        tripView.show()
    }
    
    	//NETWORK
    func ResponseHandle(data: Data) {
        trips = Session.shared.parseTrip(Session.parser.parseNested(data))
        DispatchQueue.main.async {
            self.cv.reloadData()
        }
    }
    
    //OBJC FUNC
    
    
    //FUNC
    func delegate(){
        cv.delegate = self
        cv.dataSource = self
        
        network.delegate = self
        
        tripView = TripView(delegate: self, haveTabBar: true)
    }
    
    func layout(){
        let layout = cv.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionHeadersPinToVisibleBounds = true
        cv.collectionViewLayout = layout
    }
    
    func setup(){
        network.send(url: "https://scripttrip.scarletsc.net/iOS/getTrips.php?category=\(selectedCategory!.CID)", method: "GET", query: nil)
    }
    
    //VIEW CONTROLLER
    override func viewDidLoad(){
        super.viewDidLoad()
        
        delegate()
        
        layout()
        
        setup()
        
    }
    
}
