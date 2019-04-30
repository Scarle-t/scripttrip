//
//  Session.swift
//  fyp
//
//  Created by Scarlet on 16/4/2019.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit

class Session: NSObject, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    static let shared = Session()
    static let parser = JSONParser()
    
    //REGISTER INFO
    var regFname = String()
    var regLname = String()
    var regEmail = String()
    var regPass = String()
    
    //USER INFO
    static let user = User()
    fileprivate let usr = Session.user
    fileprivate var usrMap = NSDictionary()
    fileprivate let userDefault = UserDefaults.standard
    func parseUser(_ data: [NSDictionary]){
        for item in data{
            guard let uid = item["UID"] as? String else {return}
            guard let email = item["email"] as? String else {return}
            guard let lname = item["Lname"] as? String else {return}
            guard let fname = item["Fname"] as? String else {return}
            guard let type = item["type"] as? String else {return}
            
            usr.UID = Int(uid)!
            usr.email = email
            usr.Lname = lname
            usr.Fname = fname
            usr.type = type
            
            usr.Sess_ID = (item["Sess_ID"] as? String) ?? nil
            usr.icon = (item["icon"] as? String) ?? nil
            
            let uuid = UIDevice.current.identifierForVendor?.uuidString
            let date = Date()
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: date)
            let minutes = calendar.component(.minute, from: date)
            let sec = calendar.component(.second, from: date)
            let month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)
            let str = "\(day)" + "\(month)" + "\(hour)" + "\(minutes)" + "\(sec)"
            let sessID = uuid![..<(uuid!.index(uuid!.startIndex, offsetBy: 5))] + "-" + str
            
            userDefault.set(uuid, forKey: "uuid")
            userDefault.set(sessID, forKey: "sessid")
            userDefault.set(true, forKey: "isLoggedIn")
            
            Network().send(url: "https://scripttrip.scarletsc.net/iOS/session.php", method: "POST", query: "user=\(usr.UID)&uuid=\(uuid!.sha1())&sessID=\(sessID.sha1())")
            
        }
    }
    func updateUser(key: String, value: String){
        if key == "UID"{
            usrMap.setValue(Int(value), forKey: key)
        }else{
            usrMap.setValue(value, forKey: key)
        }
        parseUser([usrMap])
    }
    
    //USER MENU
    fileprivate var window: UIWindow?
    fileprivate var userView = UIView()
    fileprivate var userTable = UITableView(frame: CGRect(origin: CGPoint.zero, size: CGSize.zero), style: .grouped)
    fileprivate let userIcon = UIImageView()
    fileprivate var iconImg: UIImage?
    fileprivate let closeUser = UIButton()
    fileprivate let dimView = UIView()
    fileprivate var mainCollectionView: UICollectionView!
    fileprivate let blurBg = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
    fileprivate var settings = ["", "Bookmarks", "History", "Account Settings", "About"]
    fileprivate let group = DispatchGroup()
    func setupUserView(){
        settings[0] = usr.Fname + " " + usr.Lname
        window = UIApplication.shared.keyWindow
        mainCollectionView = UICollectionView(frame: userView.frame, collectionViewLayout: StretchyHeaderLayout())
        let dimTap = UITapGestureRecognizer(target: self, action: #selector(closeMenu))
        
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        userTable.delegate = self
        userTable.dataSource = self
        
        mainCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        mainCollectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        mainCollectionView.contentInsetAdjustmentBehavior = .always
//        let layout = mainCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
//        layout.sectionHeadersPinToVisibleBounds = true
//        mainCollectionView.collectionViewLayout = layout
        userTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        userIcon.image = #imageLiteral(resourceName: "user")
        userIcon.contentMode = .scaleAspectFill
        closeUser.setImage(#imageLiteral(resourceName: "left_tint"), for: .normal)
        closeUser.contentMode = .scaleAspectFill
        closeUser.titleLabel?.text = nil
        closeUser.addTarget(self, action: #selector(closeMenu), for: .touchUpInside)
        dimView.addGestureRecognizer(dimTap)
        
        dimView.frame = window!.frame
        dimView.backgroundColor = UIColor.black
        dimView.alpha = 0
        userView.frame = CGRect(x: 0, y: 0, width: (window?.frame.width)! / 3 * 2, height: (window?.frame.height)!)
        userView.layer.cornerRadius = 25
        userView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        userView.clipsToBounds = true
        userView.backgroundColor = UIColor.clear
        userIcon.frame = CGRect(x: 0, y: 0, width: userView.frame.width, height: userView.frame.width)
        mainCollectionView.clipsToBounds = true
        mainCollectionView.showsVerticalScrollIndicator = false
        mainCollectionView.showsHorizontalScrollIndicator = false
        mainCollectionView.frame = userView.frame
        mainCollectionView.backgroundColor = UIColor.clear
        closeUser.frame = CGRect(x: 5, y: 53, width: 50, height: 50)
        closeUser.backgroundColor = UIColor.clear
        
        blurBg.frame = userView.frame
        userView.addSubview(blurBg)
        
        userView.frame.origin.x = -((window?.frame.width)! / 3 * 2)
        
        userView.addSubview(mainCollectionView)
        mainCollectionView.reloadData()
        UIApplication.shared.keyWindow?.addSubview(dimView)
        UIApplication.shared.keyWindow?.addSubview(userView)
        
    }
    internal func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 3
        }else if section == 1{
            return 2
        }else if section == 2{
            return 1
        }
        return 0
    }
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        switch indexPath.section{
        case 0:
            cell.textLabel?.text = settings[indexPath.row]
            if indexPath.row == 0{
                cell.textLabel?.font = UIFont(name: "AvenirNext-Heavy", size: 27)
                cell.textLabel?.textAlignment = .center
                cell.accessoryType = .none
                
            }else{
                cell.textLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 17)
                cell.textLabel?.textAlignment = .left
                cell.accessoryType = .disclosureIndicator
            }
            cell.backgroundColor = UIColor.clear
            if indexPath.row == 1{
                cell.accessoryView = UIImageView(image: #imageLiteral(resourceName: "bookmark_pdf"))
            }else if indexPath.row == 2{
                cell.accessoryView = UIImageView(image: #imageLiteral(resourceName: "history_pdf"))
            }
            
            return cell
        case 1:
            cell.textLabel?.text = settings[indexPath.row + 3]
            cell.textLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 17)
            cell.textLabel?.textAlignment = .left
            cell.accessoryType = .disclosureIndicator
            cell.backgroundColor = UIColor.clear
            
            return cell
        case 2:
            cell.textLabel?.text = "Logout"
            cell.textLabel?.font = UIFont(name: "AvenirNext-Regular", size: 17)
            cell.textLabel?.textColor = "FF697B".toUIColor
            cell.textLabel?.textAlignment = .left
            cell.backgroundColor = UIColor.clear
            
            return cell
        default:
            return UITableViewCell()
        }
        
    }
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 && indexPath.row == 0{
            iconImg = nil
            userView.removeFromSuperview()
            dimView.removeFromSuperview()
            userDefault.set(false, forKey: "isLoggedIn")
            UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: false, completion: nil)
        }
    }
    
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    internal func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        userTable.frame = cell.contentView.frame
        userTable.contentInset = UIEdgeInsets(top: -35, left: 0, bottom: 0, right: 0)
        userTable.backgroundColor = UIColor.clear
        
        cell.contentView.addSubview(userTable)
        
        return cell
        
    }
    internal func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind{
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath)
            
            header.backgroundColor = UIColor.clear
            
            if usr.icon != nil{
                if iconImg == nil{
                    group.enter()
                    Network().getPhoto(url: "https://scripttrip.scarletsc.net/img/icon/\(usr.icon!)") { (data, response, error) in
                        guard let data = data, error == nil else {return}
                        self.iconImg = UIImage(data: data)
                        self.group.leave()
                    }
                }
                
                userIcon.image = iconImg
            }
            
            header.addSubview(userIcon)
//            header.addSubview(blur)
            header.addSubview(closeUser)
            
            userIcon.fillSuperview()
//            blur.bottomSuperview()
            
            return header
            
        default:
            return UICollectionReusableView()
        }
    }
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: userView.frame.width, height: userView.frame.width)
    }
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: userView.frame.width, height: userView.frame.height - userView.frame.width)
    }
    @objc func closeMenu(){
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.dimView.alpha = 0
            self.userView.frame.origin.x -= self.userView.frame.width
        }, completion: nil)
        
    }
    func showUserMenu(){
        DispatchQueue.main.async {
            self.mainCollectionView.reloadData()
            self.userTable.reloadData()
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            self.userView.frame.origin.x = 0
            self.dimView.alpha = 0.3
        }, completion: nil)
    }
    
    //CATEGORY
    fileprivate var categories = [Category]()
    func getCategories()->[Category]{
        return categories
    }
    func setCategories(_ item: [Category]?){
        guard let data = item else {print("data is null"); return}
        self.categories = data
    }
    func parseCategory(_ item: [NSDictionary]?)->[Category]?{
        guard let data = item else {print("data is null"); return nil}
        
        var returnItem = [Category]()
        for item in data{
            guard let cid = item["CID"] as? Int else {print("cid is null"); return nil}
            guard let c_name = item["C_Name"] as? String else {print("c_name is null"); return nil}
            
            returnItem.append(Category(CID: cid, C_Name: c_name))
            
        }
        return returnItem
    }
    
    //TRIP
    fileprivate var trips = [Trip]()
    func getTrips()->[Trip]{
        return trips
    }
    func setTrips(_ item: [Trip]?){
        guard let data = item else {print("data is null"); return}
        self.trips = data
    }
    func parseTrip(_ item: [[NSDictionary]]?)->[Trip]?{
        guard let data = item else {print("data is null"); return nil}
        
        var returnItem = [Trip]()
        
        for item in data{
            let trip = Trip()
            for i in item{
                let itm = Item()
                guard let tid = i["TID"] as? Int else {print("tid is null");return nil}
                guard let t_title = i["T_Title"] as? String else {print("t_title is null");return nil}
                guard let cateogry = i["Category"] as? String else {print("category is null");return nil}
                guard let i_content = i["I_Content"] as? String else {print("i_content is null");return nil}
                guard let i_image = i["I_Image"] as? String else {print("i_image is null");return nil}
                guard let i_lat = i["I_Lat"] as? Double else {print("i_lat is null");return nil}
                guard let i_longt = i["I_Longt"] as? Double else {print("i_longt is null");return nil}
                guard let item_order = i["Item_order"] as? Int else {print("item_order is null");return nil}
                guard let trends = i["trends"] as? Int else {print("trends is null");return nil}
                
                trip.TID = tid
                trip.T_Title = t_title
                trip.Category = cateogry
                itm.I_Content = i_content
                itm.I_Image = i_image
                itm.I_Lat = i_lat
                itm.I_Longt = i_longt
                itm.Item_order = item_order
                trip.trends = trends
                trip.naturalLanguage = (i["naturalLanguage"] as? String) ?? nil
                
                trip.Items.append(itm)
                
            }
            returnItem.append(trip)
        }
        return returnItem
    }
    
}
