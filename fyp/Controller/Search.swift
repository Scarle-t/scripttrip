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
        
        let menu = UIButton(frame: CGRect(x: 10, y: 16, width: 45, height: 30))
        menu.setImage(#imageLiteral(resourceName: "menu_tint"), for: .normal)
        menu.addTarget(self, action: #selector(userMenu(_:)), for: .touchUpInside)
        
        let text = UILabel(frame: CGRect(x: 0, y: 0, width: header.frame.width, height: 63))
        text.text = "Search"
        text.textColor = "42C89D".toUIColor
        text.font = UIFont(name: "AvenirNext-Heavy", size: 30)
        text.frame.origin.x = 63
        
        searchBar.frame = CGRect(x: 0, y: 62, width: header.frame.width, height: 100)
        searchBar.isTranslucent = false
        searchBar.showsScopeBar = true
        searchBar.tintColor = "42D89D".toUIColor
        searchBar.barTintColor = .white
        searchBar.searchBarStyle = .minimal
        searchBar.scopeButtonTitles = ["Trip", "Category", "Location"]
        searchBar.placeholder = "Search for ..."
        
        header.backgroundColor = .white
        
        header.addSubview(text)
        header.addSubview(menu)
        header.addSubview(searchBar)
        
        return header
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 162
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tripView.displayTrip = results?[indexPath.row]
        tripView.show()
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
        session.showUserMenu()
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
        case 1:
            query += "&category=1"
        case 2:
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
