//
//  ViewController5.swift
//  fyp
//
//  Created by Scarlet on 7/3/2019.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit

class CategoryView: UIViewController, UITableViewDataSource, UITableViewDelegate, NetworkDelegate {
    
    //VARIABLE
    let network = Network()
    let session = Session.shared
    
    //IBOUTLET
    @IBOutlet weak var category: UITableView!
    
    //IBACTION
    
    
    //DELEGATION
        //TABLE VIEW
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return session.getCategories().count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! categoryCell
        
        cell.alpha = 0
        
        cell.catName.text = session.getCategories()[indexPath.row].C_Name
        cell.catImg.image = session.cate_icons[session.getCategories()[indexPath.row].CID -  1]
        
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
        text.text = NSLocalizedString("category", comment: "")
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ct = storyboard?.instantiateViewController(withIdentifier: "catTrip") as! CategoryTrip
        
        ct.selectedCategory = session.getCategories()[indexPath.row]
        
        self.navigationController?.pushViewController(ct, animated: true)
        
    }
        //NETWORK
    func ResponseHandle(data: Data) {
        session.setCategories(session.parseCategory(Session.parser.parse(data)))
        DispatchQueue.main.async {
            self.category.reloadData()
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
        category.sectionHeaderHeight = 62
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
        network.send(url: "https://scripttrip.scarletsc.net/iOS/getCategory.php", method: "GET", query: nil)
    }

}
