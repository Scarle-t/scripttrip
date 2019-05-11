//
//  Profile.swift
//  fyp
//
//  Created by Scarlet on 5/2/31 H.
//  Copyright © 31 Scarlet. All rights reserved.
//

import UIKit

class Profile: UITableViewController {
    //VARIABLE
    let session = Session.shared
    
    //IBOUTLET
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var fname: UITextField!
    @IBOutlet weak var lname: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var left: UIBarButtonItem!
    @IBOutlet weak var right: UIBarButtonItem!
    @IBOutlet weak var history: UISwitch!
    
    //IBACTION
    @IBAction func leftItem(_ sender: UIBarButtonItem) {
        if sender.tag == 0{
            self.dismiss(animated: true, completion: nil)
        }
        
        if sender.tag == -1{
            sender.tag = 0
            right.tag = 0
            right.image = #imageLiteral(resourceName: "Edit_pdf")
            sender.image = #imageLiteral(resourceName: "small_tick_pdf")
            fname.layer.shadowOpacity = 0
            lname.layer.shadowOpacity = 0
            email.layer.shadowOpacity = 0
            fname.isUserInteractionEnabled = false
            lname.isUserInteractionEnabled = false
            email.isUserInteractionEnabled = false
            return
        }
        
    }
    
    @IBAction func rightItem(_ sender: UIBarButtonItem) {
        
        if sender.tag == 0{
            fname.layer.shadowOpacity = 1
            lname.layer.shadowOpacity = 1
            email.layer.shadowOpacity = 1
            fname.isUserInteractionEnabled = true
            lname.isUserInteractionEnabled = true
            email.isUserInteractionEnabled = true
            sender.tag = -1
            left.tag = -1
            sender.image = #imageLiteral(resourceName: "small_tick_pdf")
            left.image = #imageLiteral(resourceName: "small_cross_pdf")
            return
        }
        
        if sender.tag == -1{
            sender.tag = 0
            left.tag = 0
            sender.image = #imageLiteral(resourceName: "Edit_pdf")
            left.image = #imageLiteral(resourceName: "small_tick_pdf")
            fname.layer.shadowOpacity = 0
            lname.layer.shadowOpacity = 0
            email.layer.shadowOpacity = 0
            fname.isUserInteractionEnabled = false
            lname.isUserInteractionEnabled = false
            email.isUserInteractionEnabled = false
            return
        }
        
    }
    
    @IBAction func historySwitch(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "history")
    }
    
    //DELEGATE
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 1{
            let alert = UIAlertController(title: NSLocalizedString("historyClearMsg", comment: ""), message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .destructive, handler: { (_) in
                Network().send(url: "https://scripttrip.scarletsc.net/iOS/history.php?user=\(Session.user.UID)", method: "DELETE", query: nil, completion: { (data) in
                    guard let d = data, let result = Session.parser.parse(d) else {return}
                    for item in result{
                        if (item["Result"] as! String) == "OK"{
                            SVProgressHUD.showSuccess(withStatus: NSLocalizedString("Success", comment: ""))
                            SVProgressHUD.dismiss(withDelay: 1.5)
                        }else{
                            SVProgressHUD.showError(withStatus: NSLocalizedString("Fail", comment: ""))
                            SVProgressHUD.dismiss(withDelay: 1.5)
                        }
                    }
                })
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //FUNC
    func delegate(){
        
    }
    
    func layout(){
        fname.setBottomBorder()
        lname.setBottomBorder()
        email.setBottomBorder()
        
        fname.layer.shadowOpacity = 0
        lname.layer.shadowOpacity = 0
        email.layer.shadowOpacity = 0
        
    }
    
    func setup(){
        userIcon.image = session.usr.iconImage
        fname.text = session.usr.Fname
        lname.text = session.usr.Lname
        email.text = session.usr.email
        
        fname.isUserInteractionEnabled = false
        lname.isUserInteractionEnabled = false
        email.isUserInteractionEnabled = false
        
        history.setOn(UserDefaults.standard.bool(forKey: "history"), animated: false)
    }
    
    //VIEW CONTROLLER
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate()
        layout()
        setup()
    }

    

}
