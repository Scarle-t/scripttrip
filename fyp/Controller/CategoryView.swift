//
//  ViewController5.swift
//  fyp
//
//  Created by Scarlet on 7/3/2019.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit

class CategoryView: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, NetworkDelegate {
    
    //VARIABLE
    let network = Network()
    let session = Session.shared
    var state = ""
    var trips = [[Trip]]()
    
    //IBOUTLET
    @IBOutlet weak var category: UITableView!
    
    //IBACTION
    
    
    //DELEGATION
        //COLLECTION VIEW
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !(trips.count == 0){
            return trips[collectionView.tag].count
        }else{
            return 0
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! featuredCell
        
        cell.view.layer.cornerRadius = 15
        
        //        cell.catImg.image = cat[indexPath.row]
//        cell.title.text = trips[collectionView.tag][indexPath.row].T_Title
        
        return cell
    }
    
        //TABLE VIEW
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return session.getCategories().count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! categoryCell
        
        cell.alpha = 0
        
        cell.items.delegate = self
        cell.items.dataSource = self
        
        cell.items.tag = indexPath.row
        
        cell.catName.text = session.getCategories()[indexPath.row].C_Name
//        cell.catImg.image = AppDelegate().cat[indexPath.row]
        
        state = "trip"
//        network.send(url: "https://scripttrip.scarletsc.net/iOS/getTrips.php?category=\(session.getCategories()[indexPath.row].CID)", method: "GET", query: nil)
//        cell.items.reloadData()
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            cell.alpha = 1
        }, completion: nil)
        
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 62))
        
        let menu = UIButton(frame: CGRect(x: 10, y: 16, width: 45, height: 30))
        menu.setImage(#imageLiteral(resourceName: "menu_tint"), for: .normal)
        menu.addTarget(self, action: #selector(userMenu(_:)), for: .touchUpInside)
        
        let text = UILabel(frame: header.frame)
        text.text = "Category"
        text.textColor = "42C89D".toUIColor
        text.font = UIFont(name: "AvenirNext-Heavy", size: 30)
        
        text.frame.origin.x = 63
        
        header.backgroundColor = .white
        
        header.addSubview(text)
        header.addSubview(menu)
        
        return header
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 62
    }
        //NETWORK
    func ResponseHandle(data: Data) {
        if state == "category"{
            session.setCategories(session.parseCategory(Session.parser.parse(data)))
            DispatchQueue.main.async {
                self.category.reloadData()
            }
        }else if state == "trip"{
            trips.append(session.parseTrip(Session.parser.parseNested(data)) ?? [Trip]())
        }
        
    }
    
    //OBJC FUNC
    @objc func userMenu(_ sender: UIButton){
        session.showUserMenu()
    }
    
    //FUNC
    func delegate(){
        category.dataSource = self
        category.delegate = self
        
        network.delegate = self
    }
    
    func layout(){
        category.sectionHeaderHeight = 50
    }
    
    func setup(){
        
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
        state = "category"
        network.send(url: "https://scripttrip.scarletsc.net/iOS/getCategory.php", method: "GET", query: nil)
    }

}
