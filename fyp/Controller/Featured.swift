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
    var feedItems = 3
    var state = ""
    var mainRefresh: UIRefreshControl?
    let tripView = TripView()
    
    //IBOUTLET
    @IBOutlet weak var cv: UICollectionView!
    
    //IBACTION
    @IBAction func userBtn(_ sender: UIButton) {
        session.showUserMenu()
    }
    
    //DELEGATION
        //COLLECTION VIEW
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return session.getTrips().count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: self.view.frame.width, height: 62)

    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind{
            case UICollectionView.elementKindSectionHeader:
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath)
                
                header.frame = CGRect(x: 0 , y: 0, width: collectionView.frame.width, height: 62)
                
                return header
            
            default:
                return UICollectionReusableView()
        }

    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        tripView.displayTrip = session.getTrips()[indexPath.row]
        tripView.show()
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
//        }else if state == "addBookmark"{
//            guard let result = parser.parse(data) else {return}
//            for item in result{
//                if (item["Result"] as! String) == "OK"{
//                    let alert = UIAlertController(title: "Added to bookmarks.", message: nil, preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
//                    self.present(alert, animated: true, completion: nil)
//                    DispatchQueue.main.async {
//                        self.plusBtn.alpha = 0
//                    }
//                }else{
//                    let alert = UIAlertController(title: "Error when adding bookmarks.", message: (item["Reason"] as? String), preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
//                    self.present(alert, animated: true, completion: nil)
//                }
//            }
//        }else if state == "checkBookmark"{
//            guard let result = parser.parse(data) else {return}
//            for item in result{
//                if (item["Result"] as! String) == "Exist"{
//                    DispatchQueue.main.async {
//                        self.plusBtn.alpha = 0
//                    }
//                }else{
//                    DispatchQueue.main.async {
//                        self.plusBtn.alpha = 1
//                    }
//
//                }
//            }
//            DispatchQueue.main.async {
//                self.plusBtn.layoutIfNeeded()
//            }
//
//        }
        
        
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
        let layout = cv.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionHeadersPinToVisibleBounds = true
        cv.collectionViewLayout = layout

//        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
//        if statusBar.responds(to: #selector(setter: UIView.backgroundColor)) {
//            statusBar.backgroundColor = "42E89D".toUIColor
//        }
        
    }
    
    func setup(){
        session.setupUserView()
        DispatchQueue.main.async {
            self.mainRefresh = UIRefreshControl()
            self.mainRefresh!.addTarget(self, action: #selector(self.refreshFeatured(_:)), for: .valueChanged)
            self.mainRefresh!.tintColor = "42C89D".toUIColor
            self.cv.refreshControl = self.mainRefresh
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        state = "trip"
        network.send(url: "https://scripttrip.scarletsc.net/iOS/getTrips.php", method: "GET", query: nil)
        
        DispatchQueue.main.async {
            self.cv.reloadData()
        }
        
    }

}
