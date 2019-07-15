//
//  Session.swift
//  fyp
//
//  Created by Scarlet on 16/4/2019.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit

class Session: NSObject, UITableViewDelegate, UITableViewDataSource, FBSDKLoginButtonDelegate{
    
    static let shared = Session()
    static let parser = JSONParser()
    static var imgCache = NSCache<AnyObject, UIImage>()
    
    //ROOT VIEW
    var rootNavigationController: UINavigationController?
    
    //REGISTER INFO
    var regFname = String()
    var regLname = String()
    var regEmail = String()
    var regPass = String()
    var regFbId = String()
    var regState = String()
    var regInterest : Set<Category> = []
    
    //USER INFO
    static let user = User()
    let usr = Session.user
    fileprivate var usrMap = NSDictionary()
    fileprivate let userDefault = UserDefaults.standard
    var loginState = ""
    func parseUser(_ data: [NSDictionary]){
        for item in data{
            guard let uid = item["UID"] as? String else {return}
            guard let email = item["email"] as? String else {return}
            guard let lname = item["Lname"] as? String else {return}
            guard let fname = item["Fname"] as? String else {return}
            guard let type = item["type"] as? String else {return}
            if let icon = item["icon"] as? String{
                usr.icon = icon
                Network().getPhoto(url: "\(icon)") { (data, response, error) in
                    guard let data = data, error == nil else {return}
                    self.iconImg = UIImage(data: data)
                    self.usr.iconImage = UIImage(data: data)
                }
            }else{
                self.usr.iconImage = #imageLiteral(resourceName: "user")
            }
            
            usr.UID = Int(uid)!
            usr.email = email
            usr.Lname = lname
            usr.Fname = fname
            usr.type = type
            
            usr.Sess_ID = (item["Sess_ID"] as? String) ?? nil
            
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
            
            reloadUserTable()
            
            Network().send(url: "https://scripttrip.scarletsc.net/iOS/session.php", method: "POST", query: "user=\(usr.UID)&uuid=\(uuid!.sha1())&sessID=\(sessID.sha1())")
            
        }
    }
    
    //USER MENU
    fileprivate var window: UIWindow?
    var userTable = UITableView(frame: CGRect(origin: CGPoint.zero, size: CGSize.zero), style: .grouped)
    var delegate: UIViewController?
    fileprivate let userIcon = UIImageView()
    fileprivate var iconImg: UIImage?
    fileprivate var settings = ["", Localized.bookmarks.rawValue.localized(), Localized.history.rawValue.localized(), Localized.plans.rawValue.localized(), Localized.Settings.rawValue.localized(), Localized.about.rawValue.localized(), Localized.Licence.rawValue.localized(), Localized.Disclaimer.rawValue.localized()]
    fileprivate let group = DispatchGroup()
    fileprivate let loginButton = FBSDKLoginButton()
    fileprivate var isUserMenuShown = false
    func setupUserView(){
        settings[0] = usr.Fname + " " + usr.Lname
        window = UIApplication.shared.keyWindow
        
        userTable.delegate = self
        userTable.dataSource = self
        
        userTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        userIcon.image = #imageLiteral(resourceName: "user")
        userIcon.contentMode = .scaleAspectFill
    }
    internal func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            return 4
        case 1:
            return 1
        case 2:
            return 3
        case 3, 4:
            return 1
        default:
            return 0
        }
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
                cell.accessoryView = userIcon
                userIcon.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
                userIcon.image = usr.iconImage
                userIcon.clipsToBounds = true
                userIcon.layer.cornerRadius = userIcon.frame.width / 2
                userIcon.backgroundColor = .white
            }else{
                cell.textLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 17)
                cell.textLabel?.textAlignment = .left
                cell.accessoryView = nil
                cell.accessoryType = .disclosureIndicator
            }
            cell.backgroundColor = UIColor.clear
            
            if #available(iOS 13.0, *) {
                if indexPath.row == 1{
                    cell.tintColor = darkGreen
                    cell.accessoryView = UIImageView(image: UIImage(systemName: "bookmark"))
                }else if indexPath.row == 2{
                    cell.accessoryView = UIImageView(image: UIImage(systemName: "clock"))
                    cell.tintColor = darkGreen
                }else if indexPath.row == 3{
                    cell.accessoryView = UIImageView(image: UIImage(systemName: "doc.richtext"))
                    cell.tintColor = darkGreen
                }
            } else {
                // Fallback on earlier versions
                if indexPath.row == 1{
                    cell.accessoryView = UIImageView(image: #imageLiteral(resourceName: "bookmark_pdf"))
                }else if indexPath.row == 2{
                    cell.accessoryView = UIImageView(image: #imageLiteral(resourceName: "history_pdf"))
                }else if indexPath.row == 3{
                    cell.accessoryView = UIImageView(image: #imageLiteral(resourceName: "plan.png"))
                }
            }
            
            return cell
        case 1:
            cell.textLabel?.text = settings[indexPath.row + 4]
            cell.textLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 17)
            cell.textLabel?.textAlignment = .left
            cell.accessoryType = .disclosureIndicator
            cell.backgroundColor = UIColor.clear
            
            return cell
        case 2:
            cell.textLabel?.text = settings[indexPath.row + 5]
            cell.textLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 17)
            cell.textLabel?.textAlignment = .left
            cell.accessoryType = .disclosureIndicator
            cell.backgroundColor = UIColor.clear
            
            return cell
        case 3:
            if loginState == "fb"{
                loginButton.removeFromSuperview()
                cell.backgroundColor = .clear
                cell.textLabel?.text = nil
                loginButton.readPermissions = ["email"]
                loginButton.delegate = self
                cell.contentView.addSubview(loginButton)
                loginButton.center = cell.contentView.center
                loginButton.frame.origin.x -= 5
                loginButton.alpha = 1
                return cell
            }else{
                loginButton.removeFromSuperview()
                loginButton.alpha = 0
                cell.textLabel?.text = Localized.Logout.rawValue.localized()
                cell.textLabel?.font = UIFont(name: "AvenirNext-Medium", size: 17)
                cell.textLabel?.textColor = "FF697B".uiColor
                cell.textLabel?.textAlignment = .center
                cell.backgroundColor = UIColor.clear
                
                return cell
            }
        case 4:
            cell.backgroundColor = .clear
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.font = UIFont(name: "AvenirNext-Medium", size: 12)
            if #available(iOS 13.0, *) {
                cell.textLabel?.textColor = .systemGray
            } else {
                // Fallback on earlier versions
                cell.textLabel?.textColor = .darkGray
            }
            cell.textLabel?.text = "Version " + (Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String) + " (" + (Bundle.main.infoDictionary!["CFBundleVersion"] as! String) + ")"
            
            return cell
        default:
            return UITableViewCell()
        }
        
    }
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
        
        if indexPath.section == 0 && indexPath.row == 0 {
            let profileView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profile") as! UINavigationController
            UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.present(profileView, animated: true, completion: nil)
        }
        
        if indexPath.section == 0 && indexPath.row == 1{
            let bookmarkView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "bookmarks") as! Bookmarks
            UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.present(bookmarkView, animated: true, completion: nil)
        }
        
        if indexPath.section == 0 && indexPath.row == 2{
            if !UserDefaults.standard.bool(forKey: "history"){
                SVProgressHUD.showInfo(withStatus: Localized.historyError.rawValue.localized())
                SVProgressHUD.dismiss(withDelay: 1.5)
            }else{
                let historyView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "history") as! History
                UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.present(historyView, animated: true, completion: nil)
            }
        }
        
        if indexPath.section == 0 && indexPath.row == 3{
            let planView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "planNav") as! UINavigationController
            UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.present(planView, animated: true, completion: nil)
        }
        
        if indexPath.section == 1 && indexPath.row == 0 {
            let deviceSetting = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "deviceSetting") as! DeviceSettings
            UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.present(deviceSetting, animated: true, completion: nil)
        }
        
        if indexPath.section == 2 && indexPath.row == 0 {
            let aboutView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "about") as! About
            UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.present(aboutView, animated: true, completion: nil)
        }
        
        if indexPath.section == 2 && indexPath.row == 1 {
            let creditView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "licence") as! Credit
            UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.present(creditView, animated: true, completion: nil)
        }
        
        if indexPath.section == 2 && indexPath.row == 2 {
            let creditView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "disclaimer") as! Credit
            UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.present(creditView, animated: true, completion: nil)
        }
        
        if loginState == ""{
            if indexPath.section == 3 && indexPath.row == 0{
                iconImg = nil
                settings[0] = ""
                userDefault.set(true, forKey: "shake")
                userDefault.set(true, forKey: "history")
                userDefault.set(false, forKey: "isLoggedIn")
                userDefault.set(false, forKey: "reduceMotion")
                userDefault.set(true, forKey: "quickAccess")
//                UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: false, completion: nil)
                let userView = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController as! userView
                userView.logout()
                return
            }
        }
    }
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        return
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        loginButton.removeFromSuperview()
        iconImg = nil
        loginState = ""
        settings[0] = ""
        userDefault.set(false, forKey: "isLoggedIn")
        userDefault.set(true, forKey: "shake")
        userDefault.set(true, forKey: "history")
        userDefault.set(false, forKey: "reduceMotion")
        userDefault.set(true, forKey: "quickAccess")
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: false, completion: nil)
    }
    func reloadLocale(){
        settings[1] = Localized.bookmarks.rawValue.localized()
        settings[2] = Localized.history.rawValue.localized()
        settings[3] = Localized.plans.rawValue.localized()
        settings[4] = Localized.accountSettings.rawValue.localized()
        settings[5] = Localized.deviceSettings.rawValue.localized()
        settings[6] = Localized.about.rawValue.localized()
        DispatchQueue.main.async {
            self.userTable.reloadData()
        }
    }
    func reloadUserTable(){
        settings[0] = usr.Fname + " " + usr.Lname
        guard let img = usr.icon else{
            iconImg = #imageLiteral(resourceName: "user")
            usr.iconImage = #imageLiteral(resourceName: "user")
            DispatchQueue.main.async {
                self.userTable.reloadData()
            }
            return
        }
        Network().getPhoto(url: img) { (data, response, error) in
            guard let data = data, error == nil else {return}
            self.iconImg = UIImage(data: data)
            self.usr.iconImage = UIImage(data: data)
        }
        DispatchQueue.main.async {
            self.userTable.reloadData()
        }
    }
    func updateFrame(){
        userTable.frame = CGRect(x: 0, y: 0, width: (self.delegate?.view.bounds.width)!, height: (self.delegate?.view.bounds.height)!)
    }
    
    //CATEGORY
    let cate_icons: [UIImage] = [#imageLiteral(resourceName: "fun.pdf"), #imageLiteral(resourceName: "dining.pdf"), #imageLiteral(resourceName: "relax.pdf"), #imageLiteral(resourceName: "Sightseeing.pdf"), #imageLiteral(resourceName: "art_culture.pdf"), #imageLiteral(resourceName: "gathering.pdf"), #imageLiteral(resourceName: "hiking.pdf"), #imageLiteral(resourceName: "workout.pdf"), #imageLiteral(resourceName: "handicraft.pdf"), #imageLiteral(resourceName: "Hobby.pdf"), #imageLiteral(resourceName: "landscape.pdf")]
    fileprivate var categories = [Category]()
    func getCategories()->[Category]{
        return categories
    }
    func setCategories(_ item: [Category]?){
        guard let data = item else {return}
        self.categories = data
    }
    func parseCategory(_ item: [NSDictionary]?)->[Category]?{
        guard let data = item else {return nil}
        var returnItem = [Category]()
        for item in data{
            guard let cid = item["CID"] as? Int else {return nil}
            guard let c_name = item["C_Name"] as? String else {return nil}
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
        guard let data = item else {return}
        self.trips = data
    }
    func parseTrip(_ item: [[NSDictionary]]?)->[Trip]?{
        guard let data = item else {return nil}
        
        var returnItem = [Trip]()
        
        for item in data{
            let trip = Trip()
            for i in item{
                let itm = Item()
                guard let tid = i["TID"] as? Int else {return nil}
                guard let t_title = i["T_Title"] as? String else {return nil}
                guard let cateogry = i["Category"] as? String else {return nil}
                guard let i_content = i["I_Content"] as? String else {return nil}
                guard let i_image = i["I_Image"] as? String else {return nil}
                guard let i_lat = i["I_Lat"] as? Double else {return nil}
                guard let i_longt = i["I_Longt"] as? Double else {return nil}
                guard let item_order = i["Item_order"] as? Int else {return nil}
                guard let trends = i["trends"] as? Int else {return nil}
                
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
                trip.ts = (i["ts"] as? String) ?? nil
                
                trip.Items.append(itm)
                
            }
            returnItem.append(trip)
        }
        return returnItem
    }
    func clearTrips(){
        trips.removeAll()
    }
    
    //PLAN PARSER
    func parsePlan(_ item: [NSDictionary]?)->[Trip]?{
        guard let data = item else {return nil}
        
        var returnItem = [Trip]()
        
        for item in data{
            let trip = Trip()
            
            guard let pid = item["PID"] as? Int else {return nil}
            guard let p_title = item["P_Title"] as? String else {return nil}
            
            trip.TID = pid
            trip.T_Title = p_title
            trip.sharer = (item["sharer"] as? String) ?? nil
            
            returnItem.append(trip)
        }
        return returnItem
    }
    func parsePlanItem(_ item: [NSDictionary]?)->[Item]?{
        guard let data = item else {return nil}
        
        var returnItem = [Item]()
        
        for item in data{
            let itm = Item()
            
            guard let iid = item["IID"] as? Int else {return nil}
            guard let i_content = item["I_Content"] as? String else {return nil}
            guard let i_image = item["I_Image"] as? String else {return nil}
            
            itm.IID = iid
            itm.I_Content = i_content
            itm.I_Image = i_image
            itm.I_Lat = item["I_Lat"] as? Double ?? nil
            itm.I_Longt = item["I_Longt"] as? Double ?? nil
            
            returnItem.append(itm)
        }
        return returnItem
    }
    
    func parseShareUser(_ item: [NSDictionary]?)->[ShareUser]?{
        guard let data = item else {return nil}
        
        var returnItem = [ShareUser]()
        
        for item in data{
            let shareuser = ShareUser()
            
            guard let uid = item["UID"] as? Int else {return nil}
            guard let email = item["email"] as? String else {return nil}
            guard let fullname = item["FullName"] as? String else {return nil}
            
            shareuser.UID = uid
            shareuser.email = email
            shareuser.FullName = fullname
            shareuser.icon = (item["icon"] as? String) ?? nil
            
            returnItem.append(shareuser)
        }
        return returnItem
    }
    
}
