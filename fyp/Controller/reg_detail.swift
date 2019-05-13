//
//  reg_detail.swift
//  fyp
//
//  Created by Scarlet on 29/4/2019.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit

class reg_detail: UIViewController, UITextFieldDelegate{
    //VARIABLE
    
    
    //IBOUTLET
    @IBOutlet weak var regBtn: UIButton!
    @IBOutlet weak var fname: UITextField!
    @IBOutlet weak var lname: UITextField!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var headingText: UILabel!
    
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
            lname.becomeFirstResponder()
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
        view.endEditing(true)
        fname.layer.borderWidth = 0
        lname.layer.borderWidth = 0
        if fname.text == "" || fname.text == nil{
            SVProgressHUD.showInfo(withStatus: Localized.regFNMsg.rawValue.localized())
            SVProgressHUD.dismiss(withDelay: 1.5)
            fname.layer.borderWidth = 1
            fname.layer.borderColor = "FF697B".uiColor.cgColor
            //            fname.becomeFirstResponder()
            return
        }
        if lname.text == "" || lname.text == nil{
            SVProgressHUD.showInfo(withStatus: Localized.regLNMsg.rawValue.localized())
            SVProgressHUD.dismiss(withDelay: 1.5)
            lname.layer.borderWidth = 1
            lname.layer.borderColor = "FF697B".uiColor.cgColor
            //            lname.becomeFirstResponder()
            return
        }
        Session.shared.regFname = (fname.text?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))!
        Session.shared.regLname = (lname.text?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))!
        
        let reg_int = storyboard?.instantiateViewController(withIdentifier: "interest") as! reg_interestChoice
        
        self.navigationController?.pushViewController(reg_int, animated: true)
    }
    
    func delegate(){
        fname.delegate = self
        lname.delegate = self
    }
    
    func layout(){
        regBtn.layer.cornerRadius = 12
        regBtn.backgroundColor = UIColor(white: 1, alpha: 0.7)
        
        fname.setBottomBorder()
        lname.setBottomBorder()
        
        let fPH = NSAttributedString(string: Localized.firstName.rawValue.localized(), attributes: [NSAttributedString.Key.foregroundColor : UIColor.black])
        let lPH = NSAttributedString(string: Localized.lastName.rawValue.localized(), attributes: [NSAttributedString.Key.foregroundColor : UIColor.black])
        
        fname.backgroundColor = "D3F2FF".uiColor
        lname.backgroundColor = "D3F2FF".uiColor
        
        fname.attributedPlaceholder = fPH
        lname.attributedPlaceholder = lPH
        
        backBtn.setTitle(Localized.Back.rawValue.localized(), for: .normal)
        regBtn.setTitle(Localized.getStarted.rawValue.localized(), for: .normal)
        headingText.text = Localized.nameIntro.rawValue.localized()
        
    }
    
    func setup(){
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
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKb))
        
        view.addGestureRecognizer(tap)
        
    }
    
    //VIEW CONTROLLER
    override func viewDidLoad(){
        super.viewDidLoad()
        
        delegate()
        
        layout()
        
        setup()
        
    }
    
}
