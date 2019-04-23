//
//  reg.swift
//  fyp
//
//  Created by Scarlet on 20/4/2019.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit

class reg: UIViewController{
    
    //VARIABLE
    
    
    //IBOUTLET
    @IBOutlet weak var fname: UITextField!
    @IBOutlet weak var lname: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var pwd: UITextField!
    @IBOutlet weak var verPwd: UITextField!
    @IBOutlet weak var regBtn: UIButton!
    
    //IBACTION
    @IBAction func back(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
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
        
        let toolBar = UIToolbar()
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Hide Keyboard", style: .plain, target: self, action: #selector(dismissKb))
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        toolBar.setItems([spaceButton, cancelButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        lname.backgroundColor = UIColor(white: 1, alpha: 0.75)
        fname.backgroundColor = UIColor(white: 1, alpha: 0.75)
        email.backgroundColor = UIColor(white: 1, alpha: 0.75)
        pwd.backgroundColor = UIColor(white: 1, alpha: 0.75)
        verPwd.backgroundColor = UIColor(white: 1, alpha: 0.75)
        
        lname.inputAccessoryView = toolBar
        fname.inputAccessoryView = toolBar
        email.inputAccessoryView = toolBar
        pwd.inputAccessoryView = toolBar
        verPwd.inputAccessoryView = toolBar
        
        regBtn.layer.cornerRadius = 12
        regBtn.backgroundColor = UIColor(white: 1, alpha: 0.7)
        
    }
    
    func setup(){
        pwd.passwordRules = UITextInputPasswordRules(descriptor: "minlength: 8;")
        verPwd.passwordRules = UITextInputPasswordRules(descriptor: "minlength: 8;")
    }
    
    //VIEW CONTROLLER
    override func viewDidLoad(){
        super.viewDidLoad()
        
        delegate()
        
        layout()
        
        setup()
        
    }
    
}
