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
    let userDefault = UserDefaults.standard
    
    //IBOUTLET
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var fname: UITextField!
    @IBOutlet weak var lname: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var left: UIBarButtonItem!
    @IBOutlet weak var right: UIBarButtonItem!
    @IBOutlet weak var naemText: UILabel!
    @IBOutlet weak var emailText: UILabel!
    
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
    
    //DELEGATE
        //TABLE VIEW
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            return 2
        default:
            return 0
        }
    }
    
    //OBJC FUNC
    @objc func dismissKb(){
        view.endEditing(true)
    }
    
    //FUNC
    func delegate(){
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
        
        fname.inputAccessoryView = toolBar
        lname.inputAccessoryView = toolBar
        email.inputAccessoryView = toolBar
        
        fname.setBottomBorder()
        lname.setBottomBorder()
        email.setBottomBorder()
        
        fname.layer.shadowOpacity = 0
        lname.layer.shadowOpacity = 0
        email.layer.shadowOpacity = 0
        
        fname.placeholder = Localized.firstName.rawValue.localized()
        lname.placeholder = Localized.lastName.rawValue.localized()
        email.placeholder = Localized.email.rawValue.localized()
        emailText.text = Localized.email.rawValue.localized()
        naemText.text = Localized.name.rawValue.localized()
        
    }
    
    func setup(){
        userIcon.image = session.usr.iconImage
        fname.text = session.usr.Fname
        lname.text = session.usr.Lname
        email.text = session.usr.email
        
        fname.isUserInteractionEnabled = false
        lname.isUserInteractionEnabled = false
        email.isUserInteractionEnabled = false
        
    }
    
    //VIEW CONTROLLER
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate()
        layout()
        setup()
    }

    

}
