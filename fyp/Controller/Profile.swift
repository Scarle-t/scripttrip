//
//  Profile.swift
//  fyp
//
//  Created by Scarlet on 5/2/31 H.
//  Copyright © 31 Scarlet. All rights reserved.
//

import UIKit

class Profile: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //VARIABLE
    let session = Session.shared
    let userDefault = UserDefaults.standard
    let langPicker = UIPickerView()
    
    //IBOUTLET
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var fname: UITextField!
    @IBOutlet weak var lname: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var left: UIBarButtonItem!
    @IBOutlet weak var right: UIBarButtonItem!
    @IBOutlet weak var history: UISwitch!
    @IBOutlet weak var localeLabel: UITextField!
    
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
        userDefault.set(sender.isOn, forKey: "history")
    }
    
    //DELEGATE
        //TABLE VIEW
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0, 2:
            return 2
        case 1:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 && indexPath.row == 1{
            let alert = UIAlertController(title: Localized.historyClearMsg.rawValue.localized(), message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: Localized.Yes.rawValue.localized(), style: .destructive, handler: { (_) in
                Network().send(url: "https://scripttrip.scarletsc.net/iOS/history.php?user=\(Session.user.UID)", method: "DELETE", query: nil, completion: { (data) in
                    guard let d = data, let result = Session.parser.parse(d) else {return}
                    for item in result{
                        if (item["Result"] as! String) == "OK"{
                            SVProgressHUD.showSuccess(withStatus: Localized.Success.rawValue.localized())
                            SVProgressHUD.dismiss(withDelay: 1.5)
                        }else{
                            SVProgressHUD.showError(withStatus: Localized.Fail.rawValue.localized())
                            SVProgressHUD.dismiss(withDelay: 1.5)
                        }
                    }
                })
            }))
            alert.addAction(UIAlertAction(title: Localized.Cancel.rawValue.localized(), style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
        //PICKER VIEW
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return locale.allCases.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let l = locale.allCases[row]
        return Localized.init(rawValue: "\(l)")!.rawValue.localized()
    }
    //OBJC FUNC
    @objc func dismissKb(){
        view.endEditing(true)
    }
    @objc func confirmPicker(){
        let index = langPicker.selectedRow(inComponent: 0)
        userDefault.set(locale.allCases[index].rawValue, forKey: "locale")
        localeLabel.text = Localized.init(rawValue: "\(locale.allCases[index])")!.rawValue.localized()
        session.reloadLocale()
        dismissKb()
        SVProgressHUD.showSuccess(withStatus: nil)
        SVProgressHUD.dismiss(withDelay: 1.5)
    }
    
    //FUNC
    func delegate(){
        langPicker.delegate = self
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
        
        let toolBar = UIToolbar()
        let confirmButton = UIBarButtonItem(title: Localized.Confirm.rawValue.localized(), style: .plain, target: self, action: #selector(confirmPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: Localized.Cancel.rawValue.localized(), style: .plain, target: self, action: #selector(dismissKb))
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        toolBar.setItems([cancelButton, spaceButton, confirmButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        history.setOn(userDefault.bool(forKey: "history"), animated: false)
        
        localeLabel.text = Localized.init(rawValue: "\(locale.init(rawValue: (userDefault.string(forKey: "locale") ?? "system"))!)")?.rawValue.localized()
        localeLabel.inputView = langPicker
        localeLabel.inputAccessoryView = toolBar
        
        
    }
    
    //VIEW CONTROLLER
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate()
        layout()
        setup()
    }

    

}
