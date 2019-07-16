//
//  searchShare.swift
//  fyp
//
//  Created by Scarlet on R1/M/28.
//  Copyright © 1 Scarlet. All rights reserved.
//

import UIKit

class searchShare: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, NetworkDelegate {
    
    //VARIABLE
    let session = Session.shared
    let network = Network()
    var results: [ShareUser]?
    var searchBar: UISearchBar!
    var postID: Int?
    var isSharing: Bool?
    
    //IBOUTLET
    @IBOutlet weak var searchResult: UITableView!
    
    //IBACTION
    
    
    //DELEGATION
        //TABLE VIEW
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        
        guard let user = results?[indexPath.row] else {return cell}
        
        cell.textLabel?.text = user.FullName
        cell.detailTextLabel?.text = nil
        cell.detailTextLabel?.font = UIFont(name: "AvenirNext-Regular", size: 16)
        cell.textLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 22)
        
        self.network.send(url: "https://scripttrip.scarletsc.net/iOS/share.php?user=\(self.results![indexPath.row].UID)&post=\(self.postID!)", method: "CHECK", query: nil, completion: { (data) in
            guard let result = Session.parser.parse(data!) else {return}
            DispatchQueue.main.async {
                for item in result{
                    if (item["Result"] as! String) == "Exist"{
                        cell.detailTextLabel?.text = Localized.Sharing.rawValue.localized()
                    }else if (item["Result"] as! String) == "Non exist"{
                        cell.detailTextLabel?.text = nil
                    }
                }
            }
        })
        
        if let icon = user.icon{
            network.getPhoto(url: "\(icon)") { (data, response, error) in
                guard let data = data, error == nil else {return}
                DispatchQueue.main.async {
                    let img = UIImageView(image: UIImage(data: data))
                    img.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
                    img.layer.cornerRadius = 60/2
                    img.clipsToBounds = true
                    cell.accessoryView = img
                }
            }
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 112))
        
        let menu = UIButton(frame: CGRect(x: 18, y: 16, width: 30, height: 30))
//        if #available(iOS 13.0, *){
//            menu.setImage(UIImage(systemName: "chevron.left"), for: .normal)
//            menu.tintColor = darkGreen
//        }else{
//            menu.setImage(#imageLiteral(resourceName: "left_tint"), for: .normal)
//        }
        menu.setImage(#imageLiteral(resourceName: "left_tint"), for: .normal)
        menu.addTarget(self, action: #selector(userMenu(_:)), for: .touchUpInside)
        
        let text = UILabel(frame: CGRect(x: 0, y: 0, width: header.frame.width, height: 63))
        text.text = Localized.shareTo.rawValue.localized()
        text.textColor = "42C89D".uiColor
        text.font = UIFont(name: "AvenirNext-Heavy", size: 30)
        text.frame.origin.x = 63
        
        if isSharing ?? false{
            let stopSharingBtn = UIButton()
            stopSharingBtn.setAttributedTitle(NSAttributedString(string: Localized.stopSharing.rawValue.localized(), attributes: [NSAttributedString.Key.font : UIFont(name: "AvenirNext-Medium", size: 16)!,
                                                                                                                                  NSAttributedString.Key.foregroundColor : darkGreen]), for: .normal)
            stopSharingBtn.addTarget(self, action: #selector(stopSharing(_:)), for: .touchUpInside)
            stopSharingBtn.frame = CGRect(x: 0, y: 0, width: 100, height: 45)
            stopSharingBtn.frame.origin.y = 10
            stopSharingBtn.frame.origin.x = header.frame.width - 100
            stopSharingBtn.tintColor = darkGreen
            header.addSubview(stopSharingBtn)
        }
        
        searchBar.frame = CGRect(x: 0, y: 62, width: header.frame.width, height: 50)
        searchBar.isTranslucent = false
        searchBar.tintColor = darkGreen
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = Localized.email.rawValue.localized()
        searchBar.showsCancelButton = true
        
        for view : UIView in (searchBar.subviews[0]).subviews {
            if let textField = view as? UITextField {
                textField.font = UIFont(name: "AvenirNext-Medium", size: 15)
            }
            if let cancel = view as? UIButton {
                cancel.setTitle(Localized.Cancel.rawValue.localized(), for: .normal)
            }
        }
        
//        if #available(iOS 13.0, *) {
//            header.backgroundColor = .systemBackground
//        } else {
//            // Fallback on earlier versions
//            header.backgroundColor = .white
//        }
        header.backgroundColor = .white
        
        header.addSubview(text)
        header.addSubview(menu)
        header.addSubview(searchBar)
        
        return header
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 112
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
        let alert = UIAlertController(title: Localized.shareTo.rawValue.localized() + " " + (results?[indexPath.row].FullName)!, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Localized.Yes.rawValue.localized(), style: .default, handler: { (_) in
            self.network.send(url: "https://scripttrip.scarletsc.net/iOS/share.php?user=\(self.results![indexPath.row].UID)&post=\(self.postID!)", method: "CHECK", query: nil, completion: { (data) in
                guard let result = Session.parser.parse(data!) else {return}
                for item in result{
                    if (item["Result"] as! String) == "Exist"{
                        SVProgressHUD.showInfo(withStatus: Localized.Shared.rawValue.localized())
                        SVProgressHUD.dismiss(withDelay: 1.5)
                    }else if (item["Result"] as! String) == "Non exist"{
                        self.network.send(url: "https://scripttrip.scarletsc.net/iOS/share.php", method: "POST", query: "shareFrom=\(self.session.usr.UID)&shareTo=\(self.results![indexPath.row].UID)&post=\(self.postID!)", completion: { (d) in
                            guard let result = Session.parser.parse(d!) else {return}
                            for item in result{
                                if (item["Result"] as! String) == "OK"{
                                    SVProgressHUD.showSuccess(withStatus: Localized.Shared.rawValue.localized())
                                    SVProgressHUD.dismiss(withDelay: 1.5)
                                }else{
                                    SVProgressHUD.showError(withStatus: item["Reason"] as? String)
                                    SVProgressHUD.dismiss(withDelay: 1.5)
                                }
                            }
                        })
                    }
                }
            })
        }))
        alert.addAction(UIAlertAction(title: Localized.Cancel.rawValue.localized(), style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
        //NETWORK
    func ResponseHandle(data: Data) {
        results = session.parseShareUser(Session.parser.parse(data))
        DispatchQueue.main.async {
            self.searchResult.reloadData()
        }
    }
        //SEARCH
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        search(searchBar)
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        setup()
    }
    
    //OBJC FUNC
    @objc func userMenu(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    @objc func dismissKb(){
        view.endEditing(true)
    }
    @objc func stopSharing(_ sender: UIButton){
        let alert = UIAlertController(title: Localized.stopSharingMsg.rawValue.localized(), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Localized.Yes.rawValue.localized(), style: .default, handler: { (_) in
            self.network.send(url: "https://scripttrip.scarletsc.net/iOS/share.php?user=\(Session.user.UID)&post=\(self.postID!)", method: "DELEtE", query: nil, completion: { (data) in
                guard let result = Session.parser.parse(data!) else {return}
                for item in result{
                    if (item["Result"] as! String) == "OK"{
                        SVProgressHUD.showSuccess(withStatus: nil)
                        SVProgressHUD.dismiss(withDelay: 1.5)
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }else{
                        SVProgressHUD.showError(withStatus: item["Reason"] as? String)
                        SVProgressHUD.dismiss(withDelay: 1.5)
                    }
                }
            })
        }))
        alert.addAction(UIAlertAction(title: Localized.Cancel.rawValue.localized(), style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //FUNC
    func search(_ sender: UISearchBar){
        view.endEditing(true)
        results?.removeAll()
        guard let text = sender.text, !text.isEmpty else {
            searchResult.reloadData()
            SVProgressHUD.showInfo(withStatus: nil)
            SVProgressHUD.dismiss(withDelay: 1.5)
            return
        }
        
        var query = "query=\(text)"
        
        query = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        network.send(url: "https://scripttrip.scarletsc.net/iOS/searchShareUser.php?\(query)", method: "POST", query: nil)
    }
    
    func delegate(){
        searchBar = UISearchBar()
        searchBar.delegate = self
        
        searchResult.delegate = self
        searchResult.dataSource = self
        
        network.delegate = self
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
        searchBar.becomeFirstResponder()
        network.send(url: "https://scripttrip.scarletsc.net/iOS/searchShareUser.php?user=\(session.usr.UID)&post=\(postID!)", method: "CHECK", query: nil)
    }
    
    //VIEW CONTROLLER
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate()
        
        layout()
        
        setup()
        
    }
    
}
