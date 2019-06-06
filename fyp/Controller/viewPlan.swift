//
//  viewPlan.swift
//  fyp
//
//  Created by Scarlet on R1/M/25.
//  Copyright © 1 Scarlet. All rights reserved.
//

import UIKit

class viewPlan: UIViewController, UITableViewDelegate, UITableViewDataSource, NetworkDelegate{
    
    //VARIABLE
    let network = Network()
    let session = Session.shared
    var selectedPlan: Trip!
    
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
        cell?.textLabel?.text = selectedPlan.Items[indexPath.row].I_Content
        cell?.accessoryType = .disclosureIndicator
        cell?.textLabel!.font = UIFont(name: "AvenirNext-Regular", size: 28)
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
        let viewItem = storyboard?.instantiateViewController(withIdentifier: "viewItem") as! createItem
        viewItem.item = selectedPlan.Items[indexPath.row]
        viewItem.mode = "edit"
        self.navigationController?.pushViewController(viewItem, animated: true)
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 62))
        
        let menu = UIButton(frame: CGRect(x: 18, y: 16, width: 30, height: 30))
        menu.setImage(#imageLiteral(resourceName: "down_tint"), for: .normal)
        menu.addTarget(self, action: #selector(userMenu(_:)), for: .touchUpInside)
        
        let add = UIButton(frame: CGRect(x: 308, y: 8, width: 46, height: 46))
        add.setImage(#imageLiteral(resourceName: "plus_tint"), for: .normal)
        add.addTarget(self, action: #selector(addItem(_:)), for: .touchUpInside)
        
        let text = UILabel(frame: header.frame)
        text.frame = CGRect(x: 0, y: 0, width: text.frame.width - 150, height: text.frame.height)
        text.text = selectedPlan.T_Title
        text.textColor = "42C89D".uiColor
        text.font = UIFont(name: "AvenirNext-Heavy", size: 30)
        text.minimumScaleFactor = 0.5
        text.adjustsFontSizeToFitWidth = true
        
        text.frame.origin.x = 63
        
        if #available(iOS 13.0, *) {
            header.backgroundColor = .systemBackground
        } else {
            // Fallback on earlier versions
            header.backgroundColor = .white
        }
        
        header.addSubview(text)
        header.addSubview(menu)
        header.addSubview(add)
        
        return header
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 62
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
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
                            self.setup()
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
    
        //NETWORK
    func ResponseHandle(data: Data) {
        selectedPlan.Items = session.parsePlanItem(Session.parser.parse(data))!
        DispatchQueue.main.async {
            self.itemList.reloadData()
        }
    }
    
    //OBJC FUNC
    @objc func userMenu(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    @objc func addItem(_ sender: UIButton){
        let viewItem = storyboard?.instantiateViewController(withIdentifier: "viewItem") as! createItem
        viewItem.mode = "add"
        viewItem.planID = selectedPlan.TID
        self.navigationController?.pushViewController(viewItem, animated: true)
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
        selectedPlan.Items.removeAll()
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
