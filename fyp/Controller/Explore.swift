//
//  ViewController9.swift
//  fyp
//
//  Created by Scarlet on 10/3/2019.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class Explore: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDelegate, UITableViewDataSource, NetworkDelegate {
    
    //VARIABLE
    let locationManager = CLLocationManager()
    let network = Network()
    let session = Session.shared
    var originalFilterMenuY: CGFloat = 0.0
    var original: CGFloat = 0.0
    var initialTouchPoint = CGPoint.zero
    var locNames = [String]()
    var selectedTrips = [Trip]()
    var trips = [MKPointAnnotation : Trip]()
    var pins = [UITapGestureRecognizer : MKPointAnnotation]()
    var taps = 0
    
    //IBOUTLET
    @IBOutlet weak var mk: MKMapView!
    @IBOutlet weak var navBar: UIView!
    @IBOutlet weak var refresh: UIActivityIndicatorView!
    @IBOutlet weak var filterList: UITableView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var planView: UIView!
    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var refreshView: UIView!
    @IBOutlet weak var refreshBtn: UIButton!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var filterMenu: UIVisualEffectView!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    
    //IBACTION
    @IBAction func refreshLoc(_ sender: UIButton) {
        
        UIView.animate(withDuration: 0.3) {
            sender.alpha = 0
            self.refresh.alpha = 1
        }
        
        locationManager.startUpdatingLocation()
        
    }
    
    @IBAction func closeFilter(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.filterMenu.frame = CGRect(x: self.filterMenu.frame.minX, y: self.view.frame.maxY + 100, width: self.filterMenu.frame.width, height: self.filterMenu.frame.height)
        }, completion: nil)
    }
    
    @IBAction func openFilter(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            self.filterMenu.frame = CGRect(x: self.filterMenu.frame.minX, y: self.originalFilterMenuY, width: self.filterMenu.frame.width, height: self.filterMenu.frame.height)
        }, completion: nil)
    }
    
    @IBAction func xClose(_ sender: UIButton) {
        
        UIView.animate(withDuration: 0.3) {
            self.blurView.alpha = 0
            self.planView.frame = CGRect(x: self.planView.frame.minX,
                                         y: self.view.frame.maxY,
                                         width: self.planView.frame.size.width,
                                         height: self.planView.frame.size.height)
            self.tabBarController?.tabBar.frame = CGRect(x: (self.tabBarController?.tabBar.frame.minX)!, y: (self.tabBarController?.tabBar.frame.minY)! - (self.tabBarController?.tabBar.frame.height)!, width: (self.tabBarController?.tabBar.frame.width)!, height: (self.tabBarController?.tabBar.frame.height)!)
            self.planView.alpha = 0
        }
        
    }
    
    //DELEGATION
        //TABLE VIEW
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return session.getCategories().count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        cell?.textLabel?.text = session.getCategories()[indexPath.row].C_Name
        
        let img = UIImageView(image: session.cate_icons[session.getCategories()[indexPath.row].CID - 1])
        
        img.frame = CGRect(x: 0, y: 0, width: 55, height: 55)
        
        cell?.accessoryView = img
        
        return cell!
    }
    
        //COLLECTION VIEW
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedTrips.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! featuredCell
        
        cell.layer.masksToBounds = false
        cell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.layer.shadowOpacity = 0.1
        
        cell.view.layer.cornerRadius = 15
        
        cell.title.text = selectedTrips[indexPath.row].T_Title
        
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dest = storyboard?.instantiateViewController(withIdentifier: "tripDetail") as! tripDetail
        
        dest.selectedTrip = selectedTrips[indexPath.row]
        
        self.present(dest, animated: true, completion: {
            if UserDefaults.standard.bool(forKey: "history") {
                self.network.send(url: "https://scripttrip.scarletsc.net/iOS/history.php", method: "POST", query: "user=\(Session.user.UID)&trip=\(self.selectedTrips[indexPath.row].TID)") { (_) in
                }
            }
        })
        
    }
        //LOCATION MANAGER
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        let span = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        let region = MKCoordinateRegion(center: locValue, span: span)
        mk.setRegion(region, animated: true)
        manager.stopUpdatingLocation()
        UIView.animate(withDuration: 0.3) {
            self.refresh.alpha = 0
            self.refreshBtn.alpha = 1
        }
    }
    
        //MAP VIEW
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView!.canShowCallout = true
        }
        else {
            annotationView!.annotation = annotation
            annotationView!.canShowCallout = true
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        let pinImage = #imageLiteral(resourceName: "mapView")
        annotationView!.image = pinImage
        annotationView?.layer.masksToBounds = false
        //        annotationView?.layer.shadowColor = UIColor.darkGray.cgColor
        //        annotationView?.layer.shadowOpacity = 0.7
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapPin(_:)))
        
        pins[tap] = annotation as? MKPointAnnotation
        
        annotationView?.addGestureRecognizer(tap)
        
        return annotationView
    }
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        taps = 0
    }
    
        //NETWORK
    func ResponseHandle(data: Data) {
        session.setTrips(session.parseTrip(Session.parser.parseNested(data)))
        mkAnnos()
    }
    
    //OBJC FUNC
    @objc func tapPin(_ sender: UITapGestureRecognizer){
        
        if taps == 0 {
            taps = 1
        }else if taps == 1{
            selectedTrips.removeAll()
            
            selectedTrips.append(trips[pins[sender]!]!)
            
            locationLabel.text = pins[sender]?.title
            
            cv.reloadData()
            
            planView.frame = CGRect(x: planView.frame.minX, y: self.view.frame.height, width: planView.frame.width, height: planView.frame.height)
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                self.tabBarController?.tabBar.frame = CGRect(x: (self.tabBarController?.tabBar.frame.minX)!, y: (self.tabBarController?.tabBar.frame.minY)! + (self.tabBarController?.tabBar.frame.height)!, width: (self.tabBarController?.tabBar.frame.width)!, height: (self.tabBarController?.tabBar.frame.height)!)
                self.planView.frame = CGRect(x: self.planView.frame.minX, y: self.original, width: self.planView.frame.width, height: self.planView.frame.height)
                self.planView.alpha = 1
                self.blurView.alpha = 1
                
            }, completion: nil)
        }
        
        
    }
    
    @objc func dismissPlan(_ sender: UIPanGestureRecognizer){
        let touchPoint = sender.location(in: planView.window)
        
        switch sender.state {
        case .began:
            initialTouchPoint = touchPoint
        case .changed:
            if touchPoint.y > initialTouchPoint.y {
                planView.frame.origin.y = touchPoint.y - initialTouchPoint.y
            }
        case .ended, .cancelled:
            if touchPoint.y - initialTouchPoint.y > self.view.frame.width {
                planView.alpha = 0
                UIView.animate(withDuration: 0.3) {
                    self.blurView.alpha = 0
                    self.tabBarController?.tabBar.frame = CGRect(x: (self.tabBarController?.tabBar.frame.minX)!, y: (self.tabBarController?.tabBar.frame.minY)! - (self.tabBarController?.tabBar.frame.height)!, width: (self.tabBarController?.tabBar.frame.width)!, height: (self.tabBarController?.tabBar.frame.height)!)
                }
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.planView.frame = CGRect(x: self.planView.frame.minX,
                                                 y: self.original,
                                                 width: self.planView.frame.size.width,
                                                 height: self.planView.frame.size.height)
                })
            }
        case .failed, .possible:
            break
        }
    }
    
    @objc func userMenu(_ sender: UIButton){
        session.showUserMenu()
    }
    
    //FUNC
    fileprivate func mkAnnos() {
        
        for trip in session.getTrips(){
            let anno = MKPointAnnotation()
            anno.coordinate = CLLocationCoordinate2D(latitude: trip.Items[0].I_Lat, longitude: trip.Items[0].I_Longt)
            let localSearch = MKLocalSearch.Request()
//            localSearch.region = .init(center: anno.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
            localSearch.naturalLanguageQuery = trip.naturalLanguage ?? "\(anno.coordinate.latitude), \(anno.coordinate.longitude)"
            let search = MKLocalSearch(request: localSearch)
            search.start { (response, error) in
                guard let res = response, error == nil else {return}
                
               anno.title = res.mapItems.first?.name
                
            }
            
            self.mk.addAnnotation(anno)
            trips[anno] = trip
        }
        
    }
    
    func delegate(){
        mk.delegate = self
        
        cv.delegate = self
        cv.dataSource = self
        
        filterList.delegate = self
        filterList.dataSource = self
        
        network.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            locationManager.startUpdatingLocation()
        }
        
    }
    
    func layout(){
        closeBtn.layer.cornerRadius = closeBtn.frame.width / 2
        
        navBar.layer.cornerRadius = 12
        navBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        refreshView.layer.cornerRadius = 7
        refreshView.layer.shadowOpacity = 0.7
        refreshView.layer.shadowColor = UIColor.lightGray.cgColor
        refreshView.layer.shadowOffset = CGSize(width: 0, height: 0)
        refreshView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        filterView.layer.cornerRadius = 7
        filterView.layer.shadowOpacity = 0.7
        filterView.layer.shadowColor = UIColor.lightGray.cgColor
        filterView.layer.shadowOffset = CGSize(width: 0, height: 0)
        filterView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        filterMenu.layer.cornerRadius = 23
        filterMenu.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        filterMenu.layer.shadowOpacity = 0.7
        filterMenu.layer.shadowColor = UIColor.lightGray.cgColor
        filterMenu.layer.shadowOffset = CGSize(width: 0, height: 0)
        filterMenu.layer.shadowRadius = 7
        filterMenu.frame = CGRect(x: filterMenu.frame.minX, y: self.view.frame.maxY + 100, width: filterMenu.frame.width, height: self.view.frame.height / 2)
        
        original = planView.frame.minY
        originalFilterMenuY = self.view.frame.maxY - filterMenu.frame.height
        
        let header = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 62))
        header.backgroundColor = .white
        
        let menu = UIButton(frame: CGRect(x: 10, y: 16, width: 45, height: 30))
        menu.setImage(#imageLiteral(resourceName: "menu_tint"), for: .normal)
        menu.addTarget(self, action: #selector(userMenu(_:)), for: .touchUpInside)
        
        let text = UILabel(frame: header.frame)
        text.text = NSLocalizedString("explore", comment: "")
        text.textColor = "42C89D".toUIColor
        text.font = UIFont(name: "AvenirNext-Heavy", size: 30)
        
        text.frame.origin.x = 63
        
        header.addSubview(text)
        header.addSubview(menu)
        
        mk.addSubview(header)
        
        let coordinate:CLLocationCoordinate2D = locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 22.401321, longitude: 114.108396)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mk.setRegion(region, animated: true)
    }
    
    func setup(){
        let pan = UIPanGestureRecognizer(target: self, action: #selector(dismissPlan(_:)))
        navBar.addGestureRecognizer(pan)
        mk.register(AnnotationView.self, forAnnotationViewWithReuseIdentifier: "AnnotationIdentifier")
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
        
        network.send(url: "https://scripttrip.scarletsc.net/iOS/getTrips.php", method: "GET", query: nil)
        
        network.send(url: "https://scripttrip.scarletsc.net/iOS/getCategory.php", method: "GET", query: nil) { (data) in
            guard let data = data else {return}
            self.session.setCategories(self.session.parseCategory(Session.parser.parse(data)))
            DispatchQueue.main.async {
                self.filterList.reloadData()
            }
        }
        
    }

}
