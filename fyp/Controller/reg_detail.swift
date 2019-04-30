//
//  reg_detail.swift
//  fyp
//
//  Created by Scarlet on 29/4/2019.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit

class reg_detail: UIViewController{
    
    //VARIABLE
    
    
    //IBOUTLET
    @IBOutlet weak var regBtn: UIButton!
    @IBOutlet weak var fname: UITextField!
    @IBOutlet weak var lname: UITextField!
    
    //IBACTION
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func next(_ sender: UIButton) {
        view.endEditing(true)
        fname.layer.borderWidth = 0
        lname.layer.borderWidth = 0
        if fname.text == "" || fname.text == nil{
            fname.layer.borderWidth = 1
            fname.layer.borderColor = "FF697B".toUIColor.cgColor
//            fname.becomeFirstResponder()
            return
        }
        if lname.text == "" || lname.text == nil{
            lname.layer.borderWidth = 1
            lname.layer.borderColor = "FF697B".toUIColor.cgColor
//            lname.becomeFirstResponder()
            return
        }
        Session.shared.regFname = fname.text!
        Session.shared.regLname = lname.text!
        
        let reg_int = storyboard?.instantiateViewController(withIdentifier: "interest") as! reg_interestChoice
        
        self.navigationController?.pushViewController(reg_int, animated: true)
        
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
        fname.backgroundColor = UIColor(white: 1, alpha: 0.75)
        lname.backgroundColor = UIColor(white: 1, alpha: 0.75)
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
        
        fname.inputAccessoryView = toolBar
        lname.inputAccessoryView = toolBar
        
    }
    
    //VIEW CONTROLLER
    override func viewDidLoad(){
        super.viewDidLoad()
        
        delegate()
        
        layout()
        
        setup()
        
    }
    
}
