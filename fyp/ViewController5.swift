//
//  ViewController5.swift
//  fyp
//
//  Created by Scarlet on 7/3/2019.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit

class ViewController5: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
        cell.view.layer.cornerRadius = 15
        
//        cell.catImg.image = cat[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppDelegate().catTxt.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        
        cell.items.dataSource = self
        
        cell.catName.text = AppDelegate().catTxt[indexPath.row]
        cell.catImg.image = AppDelegate().cat[indexPath.row]
        
        return cell
    }
    
    @objc func userMenu(_ sender: UIButton){
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        
        let menu = UIButton(frame: CGRect(x: 10, y: 10, width: 45, height: 30))
        
        menu.setImage(#imageLiteral(resourceName: "menu"), for: .normal)
        
        menu.addTarget(self, action: #selector(userMenu(_:)), for: .touchUpInside)
        
        header.backgroundColor = "42E89D".toUIColor
        
        header.addSubview(menu)
        
        return header
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

    @IBOutlet weak var category: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        category.dataSource = self
        category.delegate = self
        
        category.sectionHeaderHeight = 50
        
    }

}
