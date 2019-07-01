//
//  addMap.swift
//  fyp
//
//  Created by Scarlet on A2019/J/16.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class addMap: UIViewController, MKMapViewDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, NetworkDelegate{
    
    //VARIABLE
    let network = Network()
    var mode = ""
    var item: Item?
    var planID: Int?
    var coordinate: CLLocationCoordinate2D?
    var feedItems: [MKMapItem]?
    var order: Int?
    
    //IBOUTLET
    @IBOutlet weak var map: MKMapView!
    @IBOutlet var mapPinLPR: UILongPressGestureRecognizer!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchViewBtn: UIButton!
    @IBOutlet weak var search: UISearchBar!
    @IBOutlet weak var resultList: UITableView!
    @IBOutlet weak var searchBg: UIVisualEffectView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var closeCancel: UIButton!
    
    //IBACTION
    @IBAction func longPressMap(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began{
            let point = sender.location(in: map)
            mkAnno(location: map.convert(point, toCoordinateFrom: map))
        }
    }
    @IBAction func close(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func save(_ sender: UIButton) {
        guard let coor = coordinate else {return}
        sender.isEnabled = false
        closeCancel.isEnabled = false
        let t = "STINTERNAL_LOCATIONDATA_STINTERNAL"
        if mode == "add"{
            network.send(url: "https://scripttrip.scarletsc.net/iOS/plan.php?user=\(Session.user.UID)&PID=\(planID!)&image=0&i_lat=\(coor.latitude)&i_longt=\(coor.longitude)&publicity=0&content=\(t)&order=\(order!)&mode=item", method: "POST", query: nil)
        }else if mode == "edit"{
            network.send(url: "https://scripttrip.scarletsc.net/iOS/plan.php?user=\(Session.user.UID)&id=\(item!.IID)&i_lat=\(coor.latitude)&i_longt=\(coor.longitude)&field=location&mode=item", method: "UPDATE", query: nil)
        }
        
    }
    @IBAction func showMenu(_ sender: UIButton) {
        switch sender.tag{
        case 0:
            if #available(iOS 13.0, *) {
                sender.setImage(UIImage(systemName: "chevron.down.square.fill"), for: .normal)
            } else {
                // Fallback on earlier versions
                sender.setImage(#imageLiteral(resourceName: "down_tint.png"), for: .normal)
            }
            UIView.animate(withDuration: slideAnimationTime, delay: slideAnimationDelay, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.searchView.frame.origin.y = self.view.bounds.height - self.searchView.frame.height
            }, completion: nil)
            sender.tag = 1
            search.becomeFirstResponder()
        case 1:
            if #available(iOS 13.0, *) {
                sender.setImage(UIImage(systemName: "chevron.up.square.fill"), for: .normal)
            } else {
                // Fallback on earlier versions
                sender.setImage(#imageLiteral(resourceName: "down_tint.png"), for: .normal)
            }
            UIView.animate(withDuration: slideAnimationTime, delay: slideAnimationDelay, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.searchView.frame.origin.y = self.view.bounds.height - 150
            }, completion: nil)
            sender.tag = 0
            dismissKb()
        default:
            break
        }
    }
    
    //DELEGATION
        //TABLE VIEW
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedItems?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        cell?.textLabel?.text = feedItems![indexPath.row].name
        cell?.textLabel?.numberOfLines = 0
        cell?.textLabel?.minimumScaleFactor = 0.5
        cell?.textLabel?.font = UIFont(name: "AvenirNext-Regular", size: 18)
        
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: false)
        if #available(iOS 13.0, *) {
            searchViewBtn.setImage(UIImage(systemName: "chevron.up.square.fill"), for: .normal)
            UIView.animate(withDuration: slideAnimationTime, delay: slideAnimationDelay, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.searchView.frame.origin.y = self.view.bounds.height - 150
            }, completion: nil)
        } else {
            // Fallback on earlier versions
        }
        searchViewBtn.tag = 0
        dismissKb()
        mkAnno(location: feedItems![indexPath.row].placemark.coordinate)
    }
    
        //MAP VIEW
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var pin = mapView.dequeueReusableAnnotationView(withIdentifier: "anno") as? MKPinAnnotationView
        
        if pin == nil{
            pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "anno")
        }
        
        pin!.canShowCallout = true
        pin!.animatesDrop = true
        pin!.pinTintColor = darkGreen
        
        let cancelBtn = UIButton()
        let confirmBtn = UIButton()
        
        cancelBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        confirmBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        
        if #available(iOS 13.0, *){
            confirmBtn.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
            cancelBtn.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
            confirmBtn.tintColor = darkGreen
            cancelBtn.tintColor = darkGreen
        }else{
            confirmBtn.setImage(#imageLiteral(resourceName: "small_tick_tint"), for: .normal)
            cancelBtn.setImage(#imageLiteral(resourceName: "cross_tint.png"), for: .normal)
        }
        
        confirmBtn.addTarget(self, action: #selector(confirmPin(_:)), for: .touchUpInside)
        cancelBtn.addTarget(self, action: #selector(cancelPin(_:)), for: .touchUpInside)
        
        pin!.leftCalloutAccessoryView = cancelBtn
        pin!.rightCalloutAccessoryView = confirmBtn
        
        pin!.setSelected(true, animated: true)
        
        return pin
    }
    
        //NETWORK
    func ResponseHandle(data: Data) {
        guard let result = Session.parser.parse(data) else {
            SVProgressHUD.showError(withStatus: nil)
            SVProgressHUD.dismiss(withDelay: 1.5)
            return
        }
        DispatchQueue.main.async {
            self.saveBtn.isEnabled = true
            self.closeCancel.isEnabled = true
        }
        for item in result{
            if (item["Result"] as! String) == "OK"{
                SVProgressHUD.showSuccess(withStatus: nil)
                SVProgressHUD.dismiss(withDelay: 1.5)
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }else{
                SVProgressHUD.showError(withStatus: nil)
                SVProgressHUD.dismiss(withDelay: 1.5)
            }
        }
    }
    
        //SEARCH BAR
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKb()
        let localSearch = MKLocalSearch.Request()
        localSearch.naturalLanguageQuery = searchBar.text
        let search = MKLocalSearch(request: localSearch)
        search.start { (response, error) in
            guard let res = response, error == nil else {return}
            self.feedItems = res.mapItems
            DispatchQueue.main.async {
                self.resultList.reloadData()
            }
        }
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if searchViewBtn.tag == 0{
            searchViewBtn.tag = 1
            if #available(iOS 13.0, *) {
                searchViewBtn.setImage(UIImage(systemName: "chevron.down.square.fill"), for: .normal)
                UIView.animate(withDuration: slideAnimationTime, delay: slideAnimationDelay, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.searchView.frame.origin.y = self.view.bounds.height - self.searchView.frame.height
                }, completion: nil)
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    //OBJC FUNC
    @objc func confirmPin(_ sender: UIButton){
        mapPinLPR.isEnabled = false
        sender.alpha = 0
    }
    @objc func cancelPin(_ sender: UIButton){
        mapPinLPR.isEnabled = true
        map.removeAnnotations(map.annotations)
        coordinate = nil
    }
    @objc func dismissKb(){
        view.endEditing(true)
    }
    
    //FUNC
    func mkAnno(location: CLLocationCoordinate2D){
        coordinate = location
        map.removeAnnotations(map.annotations)
        let anno = MKPointAnnotation()
        anno.coordinate = location
        let localSearch = MKLocalSearch.Request()
        localSearch.naturalLanguageQuery = "\(anno.coordinate.latitude), \(anno.coordinate.longitude)"
        let search = MKLocalSearch(request: localSearch)
        search.start { (response, error) in
            guard let res = response, error == nil else {return}
            anno.title = res.mapItems.first?.name
        }
        map.addAnnotation(anno)
    }
    
    func delegate(){
        map.delegate = self
        network.delegate = self
        search.delegate = self
        resultList.delegate = self
        resultList.dataSource = self
    }
    
    func layout(){
        searchView.frame.origin.y = view.bounds.height - 150
        searchView.layer.cornerRadius = 12
        if #available(iOS 11.0, *) {
            searchView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            // Fallback on earlier versions
        }
        
        searchView.layer.shadowOpacity = 0.7
        searchView.layer.shadowColor = UIColor.lightGray.cgColor
        searchView.layer.shadowOffset = CGSize(width: 0, height: -1)
        
        if #available(iOS 12.0, *){
            switch view.traitCollection.userInterfaceStyle{
            case .light:
                searchBg.effect = UIBlurEffect(style: .extraLight)
            case .dark:
                searchBg.effect = UIBlurEffect(style: .dark)
            default:
                break
            }
        }
        
        if #available(iOS 13.0, *){
        }else{
            saveBtn.setImage(#imageLiteral(resourceName: "small_tick_tint"), for: .normal)
            closeCancel.setImage(#imageLiteral(resourceName: "cross_tint"), for: .normal)
            searchViewBtn.setImage(#imageLiteral(resourceName: "down_tint.png"), for: .normal)
        }
        
        map.fillSuperview()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    func setup(){
        let toolBar = UIToolbar()
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: Localized.hideKB.rawValue.localized(), style: .plain, target: self, action: #selector(dismissKb))
        toolBar.barStyle = .default
        toolBar.tintColor = "42C89D".uiColor
        toolBar.isTranslucent = false
        toolBar.sizeToFit()
        toolBar.setItems([spaceButton, cancelButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        cancelButton.setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "AvenirNext-DemiBold", size: 17)!], for: .normal)
        
        search.inputAccessoryView = toolBar
        
        if mode == "edit"{
            mkAnno(location: CLLocationCoordinate2D(latitude: item!.I_Lat!, longitude: item!.I_Longt!))
        }
    }
    
    //VIEW CONTROLLER
    override func viewDidLoad(){
        super.viewDidLoad()
        
        delegate()
        
        layout()
        
        setup()
        
    }
    
}
