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
        
        let trip = groupedTrip[indexPath.section][indexPath.row]
        
        if trip.TID == 0{
            return cell
        }
        
        cell.layer.masksToBounds = false
        cell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.layer.shadowOpacity = 0.1
        
        cell.title.text = trip.T_Title
        
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
                self.cv.reloadData()
            }
        }
    }
    
    //OBJC FUNC
    
    
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
        layout.headerReferenceSize = .init(width: self.view.frame.width, height: 62)
        cv.collectionViewLayout = layout
        heading.text = Localized.history.rawValue.localized()
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
