//
//  reg_password.swift
//  fyp
//
//  Created by Scarlet on 29/4/2019.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit

class reg_password: UIViewController{
    
    //VARIABLE
    
    
    //IBOUTLET
    @IBOutlet weak var regBtn: UIButton!
    @IBOutlet weak var mail: UITextField!
    @IBOutlet weak var pwd: UITextField!
    @IBOutlet weak var verPwd: UITextField!
    
    //IBACTION
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func next(_ sender: UIButton) {
        if mail.text == "" || mail.text == nil{
            mail.layer.borderWidth = 1
            mail.layer.borderColor = "FF697B".toUIColor.cgColor
            return
        }
        if pwd.text == "" || pwd.text == nil{
            pwd.layer.borderWidth = 1
            pwd.layer.borderColor = "FF697B".toUIColor.cgColor
            return
        }
        if verPwd.text == "" || pwd.text == nil{
            verPwd.layer.borderWidth = 1
            verPwd.layer.borderColor = "FF697B".toUIColor.cgColor
            return
        }
        
        if pwd.text != verPwd.text {
            pwd.layer.borderWidth = 1
            pwd.layer.borderColor = "FF697B".toUIColor.cgColor
            verPwd.layer.borderWidth = 1
            verPwd.layer.borderColor = "FF697B".toUIColor.cgColor
            return
        }
        
        Session.shared.regEmail = mail.text!
        Session.shared.regPass = pwd.text!
        
        let regDone = storyboard?.instantiateViewController(withIdentifier: "vc3") as! reg_done
        
        self.navigationController?.pushViewController(regDone, animated: true)
        
    }
    @IBAction func tapTxt(_ sender: UITextField) {
        sender.layer.borderWidth = 0
    }
    
    //DELEGATION
    
    
    //OBJC FUNC
    @objc func dismissKb(){
        view.endEditing(true)
    }
    
    //FUNC
    func delegate(){
        
    }
    
    func layout(){
        regBtn.layer.cornerRadius = 12
        regBtn.backgroundColor = UIColor(white: 1, alpha: 0.7)
        mail.backgroundColor = UIColor(white: 1, alpha: 0.75)
        pwd.backgroundColor = UIColor(white: 1, alpha: 0.75)
        verPwd.backgroundColor = UIColor(white: 1, alpha: 0.75)
    }
    
    func setup(){
        let toolBar = UIToolbar()
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Hide Keyboard", style: .plain, target: self, action: #selector(dismissKb))
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        toolBar.setItems([spaceButton, cancelButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        mail.inputAccessoryView = toolBar
        pwd.inputAccessoryView = toolBar
        verPwd.inputAccessoryView = toolBar
        
    }
    
    //VIEW CONTROLLER
    override func viewDidLoad(){
        super.viewDidLoad()
        
        delegate()
        
        layout()
        
        setup()
        
    }
    
}
