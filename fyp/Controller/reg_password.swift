//
//  reg_password.swift
//  fyp
//
//  Created by Scarlet on 29/4/2019.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit

class reg_password: UIViewController, UITextFieldDelegate{
    
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
        nextCheck()
    }
    @IBAction func tapTxt(_ sender: UITextField) {
        sender.layer.borderWidth = 0
    }
    
    //DELEGATION
        //TEXT FIELD
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 0{
            pwd.becomeFirstResponder()
        }else if textField.tag == 1{
            verPwd.becomeFirstResponder()
        }else{
            view.endEditing(true)
            nextCheck()
        }
        return true
    }
    
    //OBJC FUNC
    @objc func dismissKb(){
        view.endEditing(true)
    }
    
    //FUNC
    func nextCheck(){
        if mail.text == "" || mail.text == nil{
            SVProgressHUD.showInfo(withStatus: Localized.regEmailMsg.rawValue.localized())
            SVProgressHUD.dismiss(withDelay: 1.5)
            mail.layer.borderWidth = 1
            mail.layer.borderColor = "FF697B".toUIColor.cgColor
            return
        }
        if pwd.text == "" || pwd.text == nil{
            SVProgressHUD.showInfo(withStatus: Localized.regPwdMsg.rawValue.localized())
            SVProgressHUD.dismiss(withDelay: 1.5)
            pwd.layer.borderWidth = 1
            pwd.layer.borderColor = "FF697B".toUIColor.cgColor
            return
        }
        if verPwd.text == "" || verPwd.text == nil{
            SVProgressHUD.showInfo(withStatus: Localized.regVerPwdMsg.rawValue.localized())
            SVProgressHUD.dismiss(withDelay: 1.5)
            verPwd.layer.borderWidth = 1
            verPwd.layer.borderColor = "FF697B".toUIColor.cgColor
            return
        }
        
        if !(mail.text?.validateEmail())!{
            mail.layer.borderWidth = 1
            mail.layer.borderColor = "FF697B".toUIColor.cgColor
            SVProgressHUD.showInfo(withStatus: Localized.regEmailRegexMsg.rawValue.localized())
            SVProgressHUD.dismiss(withDelay: 1.5)
            return
        }
        
        if pwd.text != verPwd.text {
            pwd.layer.borderWidth = 1
            pwd.layer.borderColor = "FF697B".toUIColor.cgColor
            verPwd.layer.borderWidth = 1
            verPwd.layer.borderColor = "FF697B".toUIColor.cgColor
            SVProgressHUD.showInfo(withStatus: Localized.regVerPwdMsg.rawValue.localized())
            SVProgressHUD.dismiss(withDelay: 1.5)
            return
        }
        
        Session.shared.regEmail = mail.text!
        Session.shared.regPass = pwd.text!
        
        let regDone = storyboard?.instantiateViewController(withIdentifier: "vc3") as! reg_done
        
        self.navigationController?.pushViewController(regDone, animated: true)
    }
    
    func delegate(){
        mail.delegate = self
        pwd.delegate = self
        verPwd.delegate = self
    }
    
    func layout(){
        regBtn.layer.cornerRadius = 12
        regBtn.backgroundColor = UIColor(white: 1, alpha: 0.7)
        
        mail.setBottomBorder()
        pwd.setBottomBorder()
        verPwd.setBottomBorder()
        
        let mPH = NSAttributedString(string: Localized.email.rawValue.localized(), attributes: [NSAttributedString.Key.foregroundColor : UIColor.black])
        let pPh = NSAttributedString(string: Localized.password.rawValue.localized(), attributes: [NSAttributedString.Key.foregroundColor : UIColor.black])
        let vPH = NSAttributedString(string: Localized.verifyPassword.rawValue.localized(), attributes: [NSAttributedString.Key.foregroundColor : UIColor.black])
        
        mail.backgroundColor = "D3F2FF".toUIColor
        pwd.backgroundColor = "D3F2FF".toUIColor
        verPwd.backgroundColor = "D3F2FF".toUIColor
        
        mail.attributedPlaceholder = mPH
        pwd.attributedPlaceholder = pPh
        verPwd.attributedPlaceholder = vPH
        
    }
    
    func setup(){
        let toolBar = UIToolbar()
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: Localized.hideKB.rawValue.localized(), style: .plain, target: self, action: #selector(dismissKb))
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        toolBar.setItems([spaceButton, cancelButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        mail.inputAccessoryView = toolBar
        pwd.inputAccessoryView = toolBar
        verPwd.inputAccessoryView = toolBar
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKb))
        
        view.addGestureRecognizer(tap)
        
        if Session.shared.regState == "regFb"{
            mail.text = Session.shared.regEmail
        }
        
    }
    
    //VIEW CONTROLLER
    override func viewDidLoad(){
        super.viewDidLoad()
        
        delegate()
        
        layout()
        
        setup()
        
    }
    
}
