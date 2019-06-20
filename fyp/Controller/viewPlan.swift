//
//  viewPlan.swift
//  fyp
//
//  Created by Scarlet on R1/M/25.
//  Copyright © 1 Scarlet. All rights reserved.
//

import UIKit

class viewPlan: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, NetworkDelegate{
    
    //VARIABLE
    let network = Network()
    let session = Session.shared
    var selectedPlan: Trip!
    var refreshControl: UIRefreshControl?
    
    //IBOUTLET
    @IBOutlet weak var itemList: UITableView!
    
    //IBACTION
    
    
    //DELEGATION
        //TABLE VIEW
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedPlan.Items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        if selectedPlan.Items[indexPath.row].I_Content == "STINERNAL_IMG_STINTERNAL"{
            cell?.textLabel?.text = Localized.imageWithCaption.rawValue.localized()
            if selectedPlan.Items[indexPath.row].I_Image != "0"{
                network.getPhoto(url: "https://scripttrip.scarletsc.net/img/\(selectedPlan.Items[indexPath.row].I_Image)") { (data, response, error) in
                    guard let image = UIImage(data: data!) else {return}
                    DispatchQueue.main.async {
                        let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
                        imgView.clipsToBounds = true
                        imgView.contentMode = .scaleAspectFit
                        imgView.image = image
                        cell?.accessoryView = imgView
                    }
                }
            }
        }else if selectedPlan.Items[indexPath.row].I_Content == "STINTERNAL_LOCATIONDATA_STINTERNAL"{
            cell?.textLabel?.text = Localized.location.rawValue.localized()
            cell?.accessoryView = UIImageView(image: #imageLiteral(resourceName: "mapView.pdf"))
        }else{
            cell?.textLabel?.text = selectedPlan.Items[indexPath.row].I_Content
            cell?.accessoryView = nil
            cell?.accessoryType = .disclosureIndicator
        }
        
        cell?.textLabel!.font = UIFont(name: "AvenirNext-Regular", size: 28)
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.setSelected(false, animated: true)
        
        if selectedPlan.Items[indexPath.row].I_Content == "STINERNAL_IMG_STINTERNAL"{
            let viewItem = storyboard?.instantiateViewController(withIdentifier: "addPhoto") as! addPhoto
            viewItem.item = selectedPlan.Items[indexPath.row]
            viewItem.mode = "edit"
            viewItem.planID = selectedPlan.TID
            self.navigationController?.pushViewController(viewItem, animated: true)
        }else if selectedPlan.Items[indexPath.row].I_Content == "STINTERNAL_LOCATIONDATA_STINTERNAL"{
            let viewItem = storyboard?.instantiateViewController(withIdentifier: "addMap") as! addMap
            viewItem.item = selectedPlan.Items[indexPath.row]
            viewItem.mode = "edit"
            self.navigationController?.pushViewController(viewItem, animated: true)
        }else{
            let viewItem = storyboard?.instantiateViewController(withIdentifier: "viewItem") as! createItem
            viewItem.item = selectedPlan.Items[indexPath.row]
            viewItem.mode = "edit"
            self.navigationController?.pushViewController(viewItem, animated: true)
        }
        
        
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 62))
        
        let menu = UIButton(frame: CGRect(x: 18, y: 16, width: 30, height: 30))
        let add = UIButton(frame: CGRect(x: 308, y: 8, width: 46, height: 46))
        let edit = UIButton(frame: CGRect(x: 270, y: 8, width: 46, height: 46))
        
        if #available(iOS 13.0, *){
            menu.setImage(UIImage(systemName: "chevron.left"), for: .normal)
            menu.tintColor = darkGreen
            add.setImage(UIImage(systemName: "plus"), for: .normal)
            add.tintColor = darkGreen
            edit.setImage(UIImage(systemName: "line.horizontal.3"), for: .normal)
            edit.tintColor = darkGreen
        }else{
            menu.setImage(#imageLiteral(resourceName: "left_tint"), for: .normal)
            add.setImage(#imageLiteral(resourceName: "plus_tint"), for: .normal)
        }
        menu.addTarget(self, action: #selector(userMenu(_:)), for: .touchUpInside)
        add.addTarget(self, action: #selector(addItem(_:)), for: .touchUpInside)
        edit.addTarget(self, action: #selector(editMode(_:)), for: .touchUpInside)
        
        let text = UITextField(frame: header.frame)
        text.frame = CGRect(x: 0, y: 0, width: text.frame.width - 170, height: text.frame.height)
        text.text = selectedPlan.T_Title
        text.textColor = darkGreen
        text.font = UIFont(name: "AvenirNext-Heavy", size: 30)
        text.adjustsFontSizeToFitWidth = true
        text.borderStyle = .none
        text.minimumFontSize = 3
        
        text.frame.origin.x = 63
        
        text.delegate = self
        
        if #available(iOS 13.0, *) {
            header.backgroundColor = .systemBackground
        } else {
            // Fallback on earlier versions
            header.backgroundColor = .white
        }
        
        header.addSubview(text)
        header.addSubview(menu)
        header.addSubview(add)
        header.addSubview(edit)
        
        return header
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 62
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = selectedPlan.Items[sourceIndexPath.row]
        selectedPlan.Items.remove(at: sourceIndexPath.row)
        selectedPlan.Items.insert(item, at: destinationIndexPath.row)
    }
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return Localized.Delete.rawValue.localized()
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let alert = UIAlertController(title: Localized.removeItemMsg.rawValue.localized(), message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Localized.Yes.rawValue.localized(), style: .default, handler: { _ in
                self.network.send(url: "https://scripttrip.scarletsc.net/iOS/plan.php?user=\(Session.user.UID)&id=\(self.selectedPlan.Items[indexPath.row].IID)&mode=item", method: "DELETE", query: nil) { (data) in
                    guard let result = Session.parser.parse(data!) else {return}
                    for item in result{
                        if (item["Result"] as! String) == "OK"{
                            DispatchQueue.main.async {
                                self.setup()
                            }
                        }else{
                            SVProgressHUD.showInfo(withStatus: Localized.Fail.rawValue.localized() + "\n\(item["Reason"] as! String)")
                            SVProgressHUD.dismiss(withDelay: 1.5)
                        }
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: Localized.Cancel.rawValue.localized(), style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
        //TEXTFIELD
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let t = textField.text?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        network.send(url: "https://scripttrip.scarletsc.net/iOS/plan.php?content=\(t!)&id=\(selectedPlan.TID)&user=\(session.usr.UID)&mode=plan", method: "UPDATE", query: nil) { (data) in
            guard let result = Session.parser.parse(data!) else {
                SVProgressHUD.showError(withStatus: nil)
                SVProgressHUD.dismiss(withDelay: 1.5)
                return
            }
            
            for item in result{
                if (item["Result"] as! String) == "OK"{
                    SVProgressHUD.showSuccess(withStatus: nil)
                    SVProgressHUD.dismiss(withDelay: 1.5)
                }else{
                    SVProgressHUD.showError(withStatus: item["Reason"] as? String)
                    SVProgressHUD.dismiss(withDelay: 1.5)
                }
            }
        }
        
        view.endEditing(true)
        
        return true
    }
    
        //NETWORK
    func ResponseHandle(data: Data) {
        selectedPlan.Items = session.parsePlanItem(Session.parser.parse(data))!
        DispatchQueue.main.async {
            self.itemList.reloadData()
            if self.refreshControl!.isRefreshing{
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    //OBJC FUNC
    @objc func userMenu(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    @objc func addItem(_ sender: UIButton){
        
        let alert = UIAlertController(title: Localized.createNew.rawValue.localized(), message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: Localized.text.rawValue.localized(), style: .default, handler: { (_) in
            let viewItem = self.storyboard?.instantiateViewController(withIdentifier: "viewItem") as! createItem
            viewItem.mode = "add"
            viewItem.planID = self.selectedPlan.TID
            viewItem.order = self.selectedPlan.Items.count
            self.navigationController?.pushViewController(viewItem, animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: Localized.imageWithCaption.rawValue.localized(), style: .default, handler: { (_) in
            let viewItem = self.storyboard?.instantiateViewController(withIdentifier: "addPhoto") as! addPhoto
            viewItem.mode = "add"
            viewItem.planID = self.selectedPlan.TID
            self.navigationController?.pushViewController(viewItem, animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: Localized.location.rawValue.localized(), style: .default, handler: { (_) in
            let viewItem = self.storyboard?.instantiateViewController(withIdentifier: "addMap") as! addMap
            viewItem.mode = "add"
            viewItem.planID = self.selectedPlan.TID
            viewItem.order = self.selectedPlan.Items.count
            self.navigationController?.pushViewController(viewItem, animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: Localized.Cancel.rawValue.localized(), style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @objc func editMode(_ sender: UIButton){
        switch sender.tag{
        case 0:
            UIView.animate(withDuration: slideAnimationTime) {
                sender.transform = CGAffineTransform(rotationAngle: 2 * CGFloat.pi / 4)
                self.itemList.isEditing = true
            }
            sender.tag = 1
        case 1:
            UIView.animate(withDuration: slideAnimationTime) {
                sender.transform = CGAffineTransform(rotationAngle: 2 * CGFloat.pi / 2)
                self.itemList.isEditing = false
            }
            
            var items = ""
            var order = ""
            
            for i in 0..<selectedPlan.Items.count{
                items += "\(selectedPlan.Items[i].IID),"
                order += "\(i),"
            }
            
            items = String(items.dropLast())
            order = String(order.dropLast())
            
            network.send(url: "https://scripttrip.scarletsc.net/iOS/plan.php?user=\(session.usr.UID)&plan=\(selectedPlan.TID)&items=\(items)&order=\(order)", method: "REORDER", query: nil) { (data) in
                guard let result = Session.parser.parse(data!) else {
                    SVProgressHUD.showError(withStatus: nil)
                    SVProgressHUD.dismiss(withDelay: 1.5)
                    return
                }
                for item in result{
                    if (item["Result"] as! String) == "OK"{
                        SVProgressHUD.showSuccess(withStatus: nil)
                        SVProgressHUD.dismiss(withDelay: 1.5)
                    }else{
                        SVProgressHUD.showError(withStatus: item["Reason"] as? String)
                        SVProgressHUD.dismiss(withDelay: 1.5)
                    }
                }
                DispatchQueue.main.async {
                    self.itemList.reloadData()
                }
            }
            sender.tag = 0
        default:
            break
        }
    }
    @objc func refresh(_ sender: UIRefreshControl){
        network.send(url: "https://scripttrip.scarletsc.net/iOS/plan.php?user=\(session.usr.UID)&PID=\(selectedPlan.TID)&mode=item", method: "GET", query: nil)
    }
    
    //FUNC
    func delegate(){
        itemList.delegate = self
        itemList.dataSource = self
        network.delegate = self
    }
    
    func layout(){
        
    }
    
    func setup(){
        DispatchQueue.main.async {
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        }
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        refreshControl?.tintColor = darkGreen
        itemList.refreshControl = refreshControl
        
//        selectedPlan.Items.removeAll()
        network.send(url: "https://scripttrip.scarletsc.net/iOS/plan.php?user=\(session.usr.UID)&PID=\(selectedPlan.TID)&mode=item", method: "GET", query: nil)
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
        setup()
    }
    
}
