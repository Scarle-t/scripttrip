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
    let group = DispatchGroup()
    var originalFilterMenuY: CGFloat = 0.0
    var original: CGFloat = 0.0
    var initialTouchPoint = CGPoint.zero
    var locNames = [String]()
    var selectedTrips = [Trip]()
    var imgs = [Trip : UIImage]()
    var trips = [MKPointAnnotation : Trip]()
    var pins = [UITapGestureRecognizer : MKPointAnnotation]()
    var taps = 0
    var tripView: TripView!
    var filters = Set<Category>()
    
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
    @IBOutlet weak var clearBtn: UIButton!
    @IBOutlet weak var filterText: UILabel!
    
    //IBACTION
    @IBAction func refreshLoc(_ sender: UIButton) {
        
        UIView.animate(withDuration: 0.3) {
            sender.alpha = 0
            self.refresh.alpha = 1
        }
        
        locationManager.startUpdatingLocation()
        
    }
    
    @IBAction func closeFilter(_ sender: UIButton) {
        UIView.animate(withDuration: slideAnimationTime, delay: 0, options: .curveEaseOut, animations: {
            self.filterMenu.frame = CGRect(x: self.filterMenu.frame.minX, y: self.view.frame.maxY + 100, width: self.filterMenu.frame.width, height: self.filterMenu.frame.height)
        }, completion: nil)
    }
    
    @IBAction func openFilter(_ sender: UIButton) {
        UIView.animate(withDuration: slideAnimationTime, delay: 0, options: .curveEaseOut, animations: {
            self.filterMenu.frame = CGRect(x: self.filterMenu.frame.minX, y: self.originalFilterMenuY, width: self.filterMenu.frame.width, height: self.filterMenu.frame.height)
        }, completion: nil)
    }
    
    @IBAction func xClose(_ sender: UIButton) {
        UIView.animate(withDuration: slideAnimationTime, delay: 0, options: .curveEaseOut, animations: {
            self.blurView.alpha = 0
            self.planView.frame = CGRect(x: self.planView.frame.minX,
                                         y: self.view.frame.maxY,
                                         width: self.planView.frame.size.width,
                                         height: self.planView.frame.size.height)
            self.tabBarController?.tabBar.frame = CGRect(x: (self.tabBarController?.tabBar.frame.minX)!, y: (self.tabBarController?.tabBar.frame.minY)! - (self.tabBarController?.tabBar.frame.height)!, width: (self.tabBarController?.tabBar.frame.width)!, height: (self.tabBarController?.tabBar.frame.height)!)
            self.planView.alpha = 0
        }, completion: nil)
        
    }
    @IBAction func clearFliters(_ sender: UIButton) {
        filters.removeAll()
        filterList.reloadData()
        mkAnnos()
    }
    
    //DELEGATION
        //TABLE VIEW
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return session.getCategories().count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        cell?.textLabel?.text = "\(cateEnum.init(rawValue: session.getCategories()[indexPath.row].CID)!)".localized()
        
        let img = UIImageView(image: session.cate_icons[session.getCategories()[indexPath.row].CID - 1])
        img.frame = CGRect(x: 0, y: 0, width: 55, height: 55)
        
        let tick = UIImageView(image: #imageLiteral(resourceName: "small_tick_tint"))
        tick.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        
        if filters.contains(session.getCategories()[indexPath.row]){
            let tick = UIImageView(image: #imageLiteral(resourceName: "small_tick_tint"))
            tick.frame = CGRect(x: 0, y: 0, width: 55, height: 55)
            cell?.accessoryView = tick
        }else{
            let img = UIImageView(image: session.cate_icons[session.getCategories()[indexPath.row].CID - 1])
            img.frame = CGRect(x: 0, y: 0, width: 55, height: 55)
            cell?.accessoryView = img
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let id = session.getCategories()[indexPath.row]
        
        cell?.setSelected(false, animated: true)
        
        if filters.contains(id){
            let img = UIImageView(image: session.cate_icons[id.CID - 1])
            img.frame = CGRect(x: 0, y: 0, width: 55, height: 55)
            filters.remove(id)
            cell?.accessoryView = img
        }else{
            let tick = UIImageView(image: #imageLiteral(resourceName: "small_tick_tint"))
            tick.frame = CGRect(x: 0, y: 0, width: 55, height: 55)
            filters.insert(id)
            cell?.accessoryView = tick
        }
        mkAnnos()
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
        
        if imgs[selectedTrips[indexPath.row]] == nil{
            if Session.imgCache.object(forKey: selectedTrips[indexPath.row]) == nil{
                group.enter()
                network.getPhoto(url: "https://scripttrip.scarletsc.net/img/\(selectedTrips[indexPath.row].Items[0].I_Image)") { (data, response, error) in
                    guard let data = data, error == nil else {return}
                    self.imgs[self.selectedTrips[indexPath.row]] = UIImage(data: data)!
                    Session.imgCache.setObject(UIImage(data: data)!, forKey: self.selectedTrips[indexPath.row])
                    self.group.leave()
                }
                group.notify(queue: .main) {
                    self.cv.reloadItems(at: [indexPath])
                }
            }else{
                self.imgs[selectedTrips[indexPath.row]] = Session.imgCache.object(forKey: selectedTrips[indexPath.row])
            }
        }
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2, animations: {
                cell.img.image = self.imgs[self.selectedTrips[indexPath.row]]
            })
        }
        
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        tripView.displayTrip = selectedTrips[indexPath.row]
        tripView.show()
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
            
            if UserDefaults.standard.bool(forKey: "reduceMotion"){
                self.tabBarController?.tabBar.frame = CGRect(x: (self.tabBarController?.tabBar.frame.minX)!, y: (self.tabBarController?.tabBar.frame.minY)! + (self.tabBarController?.tabBar.frame.height)!, width: (self.tabBarController?.tabBar.frame.width)!, height: (self.tabBarController?.tabBar.frame.height)!)
                self.planView.frame = CGRect(x: self.planView.frame.minX, y: self.original, width: self.planView.frame.width, height: self.planView.frame.height)
                self.planView.alpha = 0
                UIView.animate(withDuration: fadeAnimationTime, delay: 0, options: .curveEaseOut, animations: {
                    self.planView.alpha = 1
                    self.blurView.alpha = 1
                }, completion: nil)
            }else{
                UIView.animate(withDuration: slideAnimationTime, delay: 0, options: .curveEaseOut, animations: {
                    self.tabBarController?.tabBar.frame = CGRect(x: (self.tabBarController?.tabBar.frame.minX)!, y: (self.tabBarController?.tabBar.frame.minY)! + (self.tabBarController?.tabBar.frame.height)!, width: (self.tabBarController?.tabBar.frame.width)!, height: (self.tabBarController?.tabBar.frame.height)!)
                    self.planView.frame = CGRect(x: self.planView.frame.minX, y: self.original, width: self.planView.frame.width, height: self.planView.frame.height)
                    self.planView.alpha = 1
                    self.blurView.alpha = 1
                }, completion: nil)
            }
            
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
                blurView.alpha = 1 - (touchPoint.y / blurView.frame.maxY)
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
                    self.blurView.alpha = 1
                    self.planView.frame = CGRect(x: self.planView.frame.minX,
                                                 y: self.original,
                                                 width: self.planView.frame.size.width,
                                                 height: self.planView.frame.size.height)
                })
            }
        case .failed, .possible:
            break
        @unknown default:
            break
        }
    }
    
    @objc func userMenu(_ sender: UIButton){
        session.showUserMenu()
    }
    
    //FUNC
    fileprivate func mkAnnos() {
        DispatchQueue.main.async {
            self.mk.removeAnnotations(self.mk.annotations)
        }
        
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
            
            if filters.count != 0{
                for item in filters{
                    if trip.Category == item.C_Name{
                        DispatchQueue.main.async {
                            self.mk.addAnnotation(anno)
                        }
                    }
                }
            }else{
                DispatchQueue.main.async {
                    self.mk.addAnnotation(anno)
                }
            }
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
        if #available(iOS 11.0, *) {
            navBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            // Fallback on earlier versions
        }
        
        refreshView.layer.cornerRadius = 7
        refreshView.layer.shadowOpacity = 0.7
        refreshView.layer.shadowColor = UIColor.lightGray.cgColor
        refreshView.layer.shadowOffset = CGSize(width: 0, height: 0)
        if #available(iOS 11.0, *) {
            refreshView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            // Fallback on earlier versions
        }
        
        filterView.layer.cornerRadius = 7
        filterView.layer.shadowOpacity = 0.7
        filterView.layer.shadowColor = UIColor.lightGray.cgColor
        filterView.layer.shadowOffset = CGSize(width: 0, height: 0)
        if #available(iOS 11.0, *) {
            filterView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            // Fallback on earlier versions
        }
        
        filterMenu.layer.cornerRadius = 23
        if #available(iOS 11.0, *) {
            filterMenu.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            // Fallback on earlier versions
        }
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
        text.text = Localized.explore.rawValue.localized()
        text.textColor = "42C89D".uiColor
        text.font = UIFont(name: "AvenirNext-Heavy", size: 30)
        
        text.frame.origin.x = 63
        
        header.addSubview(text)
        header.addSubview(menu)
        
        mk.addSubview(header)
        
        let coordinate:CLLocationCoordinate2D = locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 22.401321, longitude: 114.108396)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mk.setRegion(region, animated: true)
        filterText.text = Localized.Filter.rawValue.localized()
        clearBtn.setTitle(Localized.Clear.rawValue.localized(), for: .normal)
    }
    
    func setup(){
        let pan = UIPanGestureRecognizer(target: self, action: #selector(dismissPlan(_:)))
        navBar.addGestureRecognizer(pan)
        if #available(iOS 11.0, *) {
            mk.register(AnnotationView.self, forAnnotationViewWithReuseIdentifier: "AnnotationIdentifier")
        } else {
            // Fallback on earlier versions
            
        }
        tripView = TripView(delegate: self, haveTabBar: true)
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
