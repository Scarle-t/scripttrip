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

class ViewController9: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    let catTxt: [String] = ["Arts and Culture", "Dining", "Relax", "Fun", "Landscape"]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return catTxt.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        cell?.textLabel?.text = catTxt[indexPath.row]
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
        cell.layer.masksToBounds = false
        cell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.layer.shadowOpacity = 0.1
        
        cell.view.layer.cornerRadius = 15
        
        return cell
        
    }
    
    @IBOutlet weak var mk: MKMapView!
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var grabber: UIVisualEffectView!
    @IBOutlet weak var refresh: UIActivityIndicatorView!
    @IBOutlet weak var filterList: UITableView!
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var planView: UIView!
    @IBOutlet weak var cv: UICollectionView!
    
    @IBOutlet weak var refreshView: UIView!
    @IBOutlet weak var refreshBtn: UIButton!
    @IBAction func refreshLoc(_ sender: UIButton) {
        
        UIView.animate(withDuration: 0.3) {
            sender.alpha = 0
            self.refresh.alpha = 1
        }
        
        locationManager.startUpdatingLocation()
        
    }
    
    
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
    }
    
    @objc func tapPin(_ sender: UITapGestureRecognizer){
        planView.frame = CGRect(x: planView.frame.minX, y: self.view.frame.height, width: planView.frame.width, height: planView.frame.height)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            self.tabBarController?.tabBar.frame = CGRect(x: (self.tabBarController?.tabBar.frame.minX)!, y: (self.tabBarController?.tabBar.frame.minY)! + (self.tabBarController?.tabBar.frame.height)!, width: (self.tabBarController?.tabBar.frame.width)!, height: (self.tabBarController?.tabBar.frame.height)!)
            self.planView.frame = CGRect(x: self.planView.frame.minX, y: self.original, width: self.planView.frame.width, height: self.planView.frame.height)
            self.planView.alpha = 1
            self.blurView.alpha = 1
            
        }, completion: nil)
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
        }
        
        let pinImage = #imageLiteral(resourceName: "mapView")
        annotationView!.image = pinImage
        annotationView?.layer.masksToBounds = false
//        annotationView?.layer.shadowColor = UIColor.darkGray.cgColor
//        annotationView?.layer.shadowOpacity = 0.7
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapPin(_:)))
        
        annotationView?.addGestureRecognizer(tap)
        
        return annotationView
    }
    
    var original: CGFloat = 0.0
    var initialTouchPoint = CGPoint.zero
    
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
            if touchPoint.y - initialTouchPoint.y > 200 {
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
        
    }
    
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var filterMenu: UIVisualEffectView!
    @IBAction func closeFilter(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.filterMenu.frame = CGRect(x: self.filterMenu.frame.minX, y: self.view.frame.maxY, width: self.filterMenu.frame.width, height: self.filterMenu.frame.height)
        }, completion: nil)
    }
    @IBOutlet weak var closeBtn: UIButton!
    @IBAction func openFilter(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            self.filterMenu.frame = CGRect(x: self.filterMenu.frame.minX, y: self.originalFilterMenuY, width: self.filterMenu.frame.width, height: self.filterMenu.frame.height)
        }, completion: nil)
    }
    
    fileprivate func mkAnnos() {
        let a1 = MKPointAnnotation(), a2 = MKPointAnnotation(), a3 = MKPointAnnotation(), a4 = MKPointAnnotation(), a5 = MKPointAnnotation(), a6 = MKPointAnnotation(), a7 = MKPointAnnotation(), a8 = MKPointAnnotation(), a9 = MKPointAnnotation(), a10 = MKPointAnnotation(), a11 = MKPointAnnotation(), a12 = MKPointAnnotation()
        
        a1.coordinate = CLLocationCoordinate2D(latitude: 22.276705, longitude: 114.174998)
        
        a2.coordinate = CLLocationCoordinate2D(latitude: 22.292170, longitude: 114.203642)
        
        a3.coordinate = CLLocationCoordinate2D(latitude: 22.284632, longitude: 114.191802)
        
        a4.coordinate = CLLocationCoordinate2D(latitude: 22.281323, longitude: 114.189402)
        
        a5.coordinate = CLLocationCoordinate2D(latitude: 22.266986, longitude: 114.249084)
        
        a6.coordinate = CLLocationCoordinate2D(latitude: 22.265045, longitude: 114.252257)
        
        a7.coordinate = CLLocationCoordinate2D(latitude: 22.264226, longitude: 114.246236)
        
        a8.coordinate = CLLocationCoordinate2D(latitude: 22.321152, longitude: 114.213028)
        
        a9.coordinate = CLLocationCoordinate2D(latitude: 22.323020, longitude: 114.212182)
        
        a10.coordinate = CLLocationCoordinate2D(latitude: 22.322872, longitude: 114.214903)
        
        a11.coordinate = CLLocationCoordinate2D(latitude: 22.320827, longitude: 114.208486)
        
        a12.coordinate = CLLocationCoordinate2D(latitude: 22.319805, longitude: 114.208501)
        
        mk.addAnnotation(a1)
        mk.addAnnotation(a2)
        mk.addAnnotation(a3)
        mk.addAnnotation(a4)
        mk.addAnnotation(a5)
        mk.addAnnotation(a6)
        mk.addAnnotation(a7)
        mk.addAnnotation(a8)
        mk.addAnnotation(a9)
        mk.addAnnotation(a10)
        mk.addAnnotation(a11)
        mk.addAnnotation(a12)
    }
    
    var originalFilterMenuY: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        mk.delegate = self
        
        cv.delegate = self
        cv.dataSource = self
        
        filterList.delegate = self
        filterList.dataSource = self
        
        filterMenu.layer.cornerRadius = 23
        filterMenu.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        closeBtn.layer.cornerRadius = closeBtn.frame.width / 2
        
        original = planView.frame.minY
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(dismissPlan(_:)))
        planView.addGestureRecognizer(pan)
        
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            locationManager.startUpdatingLocation()
        }
        
        let coordinate:CLLocationCoordinate2D = locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 22.401321, longitude: 114.108396)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mk.setRegion(region, animated: true)
        
        mkAnnos()
        
        mk.register(AnnotationView.self, forAnnotationViewWithReuseIdentifier: "AnnotationIdentifier")
        
        grabber.layer.cornerRadius = 3
        
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
        
        filterMenu.layer.shadowOpacity = 0.7
        filterMenu.layer.shadowColor = UIColor.lightGray.cgColor
        filterMenu.layer.shadowOffset = CGSize(width: 0, height: 0)
        filterMenu.layer.shadowRadius = 7
        
        filterMenu.frame = CGRect(x: filterMenu.frame.minX, y: self.view.frame.maxY, width: filterMenu.frame.width, height: self.view.frame.height / 2)
        
        originalFilterMenuY = self.view.frame.maxY - filterMenu.frame.height
        
        let header = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        
        let menu = UIButton(frame: CGRect(x: 10, y: 10, width: 45, height: 30))
        
        menu.setImage(#imageLiteral(resourceName: "menu"), for: .normal)
        
        menu.addTarget(self, action: #selector(userMenu(_:)), for: .touchUpInside)
        
        header.backgroundColor = "42E89D".toUIColor
        
        header.addSubview(menu)
        
        mk.addSubview(header)
        
    }

}
