//
//  otp_authentication.swift
//  fyp
//
//  Created by Scarlet on 5/16/31 H.
//  Copyright © 31 Scarlet. All rights reserved.
//

import UIKit

class otp_authentication: UIViewController, UITextFieldDelegate, NetworkDelegate{
    //VARIABLE
    let network = Network()
    
    //IBOUTLET
    @IBOutlet weak var heading: UILabel!
    @IBOutlet var code: [UITextField]!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var authBtn: UIButton!
    
    //IBACTION
    @IBAction func close(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5) {
            self.view.layer.backgroundColor = color.lightGreen.rawValue.uiColor.cgColor
        }
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func auth(_ sender: UIButton) {
        var c = ""
        for field in code{
            if field.text == nil || field.text == ""{
                SVProgressHUD.showInfo(withStatus: "Error")
                SVProgressHUD.dismiss(withDelay: 1.5)
                return
            }
            c += field.text!
        }
        SVProgressHUD.showInfo(withStatus: c)
        SVProgressHUD.dismiss(withDelay: 1.5)
    }
    
    //DELEGATION
        //TEXT FIELD
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        textField.text = string
        
        if textField.tag != 5{
            code[textField.tag + 1].becomeFirstResponder()
        }else{
            textField.resignFirstResponder()
        }
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        for field in code{
            field.layer.shadowOpacity = 0
        }
        textField.layer.shadowOpacity = 1
        
        return true
    }
    
        //NETWORK
    func ResponseHandle(data: Data) {
        return
    }
    
    //OBJC FUNC
    @objc func dismissKb(){
        view.endEditing(true)
    }
    
    //FUNC
    func delegate(){
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
        for field in code{
            field.delegate = self
            field.inputAccessoryView = toolBar
            field.setBottomBorder(strokeColor: UIColor.black.cgColor, backgroundColor: color.blue.rawValue.uiColor.cgColor)
            field.layer.shadowOpacity = 0
        }
        network.delegate = self
    }
    
    func layout(){
        heading.text = Localized.otpTitle.rawValue.localized()
        backBtn.setTitle(Localized.Back.rawValue.localized(), for: .normal)
        authBtn.setTitle(Localized.Authenticate.rawValue.localized(), for: .normal)
        
        authBtn.layer.cornerRadius = 12
        
        UIView.animate(withDuration: 0.5) {
            self.view.layer.backgroundColor = color.blue.rawValue.uiColor.cgColor
        }
    }
    
    func setup(){
        code[0].becomeFirstResponder()
        code[0].layer.shadowOpacity = 1
    }
    
    //VIEW CONTROLLER
    override func viewDidLoad(){
        super.viewDidLoad()
        
        layout()
        
        delegate()
        
        setup()
        
    }
    
}
