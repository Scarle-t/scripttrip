//
//  postMap.swift
//  fyp
//
//  Created by Scarlet on A2019/J/16.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit
import MapKit

class postMap: UIViewController, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource{
    
    //VARIABLE
    var trip: Trip?
    var displayLoc = [Item]()
    let cellSize: CGFloat = 60
    var menuHeight: CGFloat = 0.0
    
    //IBOUTLET
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var locMenu: UITableView!
    
    //IBACTION
    @IBAction func close(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //DELEGATION
        //MAP VIEW
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
        } else {
            annotationView!.annotation = annotation
            annotationView!.canShowCallout = true
        }
        
        let pinImage = #imageLiteral(resourceName: "mapView")
        annotationView!.image = pinImage
        annotationView?.layer.masksToBounds = false
        
        return annotationView
    }
    
        //TABLE VIEW
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayLoc.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        cell?.textLabel?.text = "\(indexPath.row + 1)"
        cell?.textLabel?.textAlignment = .center
        cell?.textLabel?.font = UIFont(name: "AvenirNext-Regular", size: 14)
        cell?.textLabel?.textColor = darkGreen
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        focusMap(item: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellSize
    }
    
    //OBJC FUNC
    @objc func locMenuToggle(_ sender: UIButton){
        switch sender.tag{
        case 0:
            UIView.animate(withDuration: slideAnimationTime, delay: slideAnimationDelay, options: .curveEaseOut, animations: {
                self.locMenu.frame = CGRect(x: self.locMenu.frame.minX, y: self.locMenu.frame.minY, width: self.locMenu.frame.width, height: 0)
            }, completion: nil)
            if #available(iOS 11.0, *) {
                sender.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            } else {
                // Fallback on earlier versions
            }
            sender.tag = 1
        case 1:
            UIView.animate(withDuration: slideAnimationTime, delay: slideAnimationDelay, options: .curveEaseOut, animations: {
                self.locMenu.frame = CGRect(x: self.locMenu.frame.minX, y: self.locMenu.frame.minY, width: self.locMenu.frame.width, height: self.menuHeight)
                if #available(iOS 11.0, *) {
                    sender.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                } else {
                    // Fallback on earlier versions
                }
            }, completion: nil)
            sender.tag = 0
        default:
            break
        }
    }
    
    //FUNC
    func mkAnnos() {
        if #available(iOS 11.0, *) {
            map.register(AnnotationView.self, forAnnotationViewWithReuseIdentifier: "AnnotationIdentifier")
        } else {
            // Fallback on earlier versions
        }
        DispatchQueue.main.async {
            self.map.removeAnnotations(self.map.annotations)
        }
        
        for item in trip!.Items{
            if let lat = item.I_Lat, let longt = item.I_Longt {
                let anno = MKPointAnnotation()
                anno.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: longt)
                let localSearch = MKLocalSearch.Request()
                localSearch.naturalLanguageQuery = "\(anno.coordinate.latitude), \(anno.coordinate.longitude)"
                let search = MKLocalSearch(request: localSearch)
                search.start { (response, error) in
                    guard let res = response, error == nil else {return}
                    anno.title = res.mapItems.first?.name
                }
                DispatchQueue.main.async {
                    self.map.addAnnotation(anno)
                }
            }
        }
    }
    
    func focusMap(item: Int){
        let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: (displayLoc[item].I_Lat) ?? 22.401321, longitude: (displayLoc[item].I_Longt) ?? 114.108396)
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        map.setRegion(region, animated: true)
    }
    
    func delegate(){
        map.delegate = self
        locMenu.delegate = self
        locMenu.dataSource = self
    }
    
    func layout(){
        map.fillSuperview()
        closeBtn.layer.cornerRadius = 30 / 2
        mkAnnos()
        locMenu.layer.cornerRadius = 7
        if #available(iOS 11.0, *) {
            locMenu.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            // Fallback on earlier versions
        }
    }
    
    func setup(){
        if #available(iOS 11.0, *) {
            map.register(AnnotationView.self, forAnnotationViewWithReuseIdentifier: "anno")
        } else {
            // Fallback on earlier versions
        }
        displayLoc.removeAll()
        for item in trip!.Items{
            if item.I_Lat != nil || item.I_Longt != nil{
                displayLoc.append(item)
            }
        }
        
        if CGFloat(displayLoc.count) * cellSize > (view.bounds.height - 130){
            locMenu.frame = CGRect(x: view.bounds.width - 75, y: 45, width: cellSize, height: view.bounds.height - 130)
        }else{
            locMenu.frame = CGRect(x: view.bounds.width - 75, y: 45, width: cellSize, height: CGFloat(displayLoc.count) * cellSize)
        }
        
        menuHeight = locMenu.frame.height
        
        DispatchQueue.main.async {
            self.locMenu.alpha = 1
            self.locMenu.reloadData()
        }
        
        let menu = UIButton(frame: CGRect(x: view.bounds.width - 75, y: 15, width: cellSize, height: 30))
        menu.addTarget(self, action: #selector(locMenuToggle(_:)), for: .touchUpInside)
        menu.layer.cornerRadius = 7
        if #available(iOS 11.0, *) {
            menu.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 13.0, *){
            menu.tintColor = darkGreen
            menu.setImage(UIImage(systemName: "line.horizontal.3"), for: .normal)
            menu.backgroundColor = .systemBackground
        }else{
            menu.setImage(#imageLiteral(resourceName: "more_tint.pdf"), for: .normal)
            menu.backgroundColor = .white
        }
        view.addSubview(menu)
        
        locMenu.cellForRow(at: IndexPath(row: 0, section: 0))?.setSelected(true, animated: false)
    }
    
    //VIEW CONTROLLER
    override func viewDidLoad(){
        super.viewDidLoad()
        
        delegate()
        
        layout()
        
        setup()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if displayLoc.count == 0{
            SVProgressHUD.showInfo(withStatus: Localized.noLocMsg.rawValue.localized())
            SVProgressHUD.dismiss(withDelay: 1.5)
            self.navigationController?.popViewController(animated: true)
        }else{
            focusMap(item: 0)
        }
    }
    
}
