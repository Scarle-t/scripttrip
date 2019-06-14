//
//  ViewController6.swift
//  fyp
//
//  Created by Scarlet on 8/3/2019.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit

class Search: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, NetworkDelegate {
    
    //VARIABLE
    let session = Session.shared
    let network = Network()
    var results: [Trip]?
    var searchBar: UISearchBar!
    var tripView: TripView!
    
    //IBOUTLET
    @IBOutlet weak var searchResult: UITableView!
    
    //IBACTION
    
    
    //DELEGATION
    	//TABLE VIEW
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        guard let trip = results?[indexPath.row] else {return cell}
        
        cell.textLabel?.text = trip.T_Title
        cell.textLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 22)
        
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 162))
        
        let menu = UIButton(frame: CGRect(x: 306, y: 9, width: 45, height: 45))
        menu.setImage(session.usr.iconImage, for: .normal)
        menu.addTarget(self, action: #selector(userMenu(_:)), for: .touchUpInside)
        menu.clipsToBounds = true
        menu.layer.cornerRadius = 45 / 2
        menu.backgroundColor = .white
        menu.frame.origin.x = self.view.bounds.width - 75
        
        let text = UILabel(frame: CGRect(x: 0, y: 0, width: header.frame.width, height: 63))
        text.text = Localized.search.rawValue.localized()
        text.textColor = "42C89D".uiColor
        text.font = UIFont(name: "AvenirNext-Heavy", size: 30)
        text.frame.origin.x = 23
        
        searchBar.frame = CGRect(x: 0, y: 62, width: header.frame.width, height: 100)
        searchBar.isTranslucent = false
        searchBar.showsScopeBar = true
        searchBar.tintColor = darkGreen
        if #available(iOS 13.0, *) {
            searchBar.barTintColor = .systemBackground
        } else {
            // Fallback on earlier versions
            searchBar.barTintColor = .white
        }
        searchBar.searchBarStyle = .minimal
        searchBar.scopeButtonTitles = [Localized.searchTrip.rawValue.localized(), Localized.searchLocation.rawValue.localized()]
        searchBar.placeholder = Localized.searchPH.rawValue.localized()
        searchBar.setScopeBarButtonTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "AvenirNext-Regular", size: 15)!], for: .normal)
        searchBar.setScopeBarButtonTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "AvenirNext-Regular", size: 15)!], for: .selected)
        
        for view : UIView in (searchBar.subviews[0]).subviews {
            
            if let textField = view as? UITextField {
                textField.font = UIFont(name: "AvenirNext-Medium", size: 15)
            }
        }
        
        if #available(iOS 13.0, *) {
            header.backgroundColor = .systemBackground
        } else {
            // Fallback on earlier versions
            header.backgroundColor = .white
        }
        
        header.addSubview(text)
        header.addSubview(menu)
        header.addSubview(searchBar)
        
        return header
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 162
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
        if UserDefaults.standard.bool(forKey: "history") {
            network.send(url: "https://scripttrip.scarletsc.net/iOS/history.php", method: "POST", query: "user=\(Session.user.UID)&trip=\(results![indexPath.row].TID)") { (_) in
            }
        }
        tripView.displayTrip = results?[indexPath.row]
        tripView.show()
        DispatchQueue.main.async {
            let postview = self.storyboard?.instantiateViewController(withIdentifier: "postView") as! postView
            postview.tripView = self.tripView
            self.present(postview, animated: true, completion: nil)
        }
    }
    
        //NETWORK
    func ResponseHandle(data: Data) {
        results = session.parseTrip(Session.parser.parseNested(data))
        DispatchQueue.main.async {
            self.searchResult.reloadData()
        }
    }
        //SEARCH
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        search(searchBar)
    }
    
    //OBJC FUNC
    @objc func userMenu(_ sender: UIButton){
        DispatchQueue.main.async {
            let userview = self.storyboard?.instantiateViewController(withIdentifier: "userView") as! userView
            userview.logout = {
                userview.dismiss(animated: false) {
                    self.navigationController?.popViewController(animated: false)
                }
            }
            self.present(userview, animated: true, completion: nil)
        }
    }
    @objc func dismissKb(){
        view.endEditing(true)
    }
    
    //FUNC
    func search(_ sender: UISearchBar){
        view.endEditing(true)
        results?.removeAll()
        guard let text = sender.text, text != "" else {
            searchResult.reloadData()
            return
        }
        
        var query = "query=\(text)"
        
        switch sender.selectedScopeButtonIndex{
        case 0:
            query += "&trip=1"
//        case 1:
//            query += "&category=1"
        case 1:
            query += "&location=1"
        default:
            break
        }
        
        query = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        network.send(url: "https://scripttrip.scarletsc.net/iOS/search.php?\(query)", method: "GET", query: nil)
    }
    
    func delegate(){
        searchBar = UISearchBar()
        searchBar.delegate = self
        
        searchResult.delegate = self
        searchResult.dataSource = self
        
        network.delegate = self
        
        tripView = TripView(delegate: self, haveTabBar: true)
    }
    
    func layout(){
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
        searchBar.inputAccessoryView = toolBar
    }
    
    func setup(){
        
    }
    
    //VIEW CONTROLLER
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate()
        
        layout()
        
        setup()
        
    }
    
}
