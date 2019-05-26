//
//  createItem.swift
//  fyp
//
//  Created by Scarlet on R1/M/23.
//  Copyright © 1 Scarlet. All rights reserved.
//

import UIKit

class createItem: UIViewController, NetworkDelegate{
    
    //VARIABLE
    let network = Network()
    var item: Item?
    var planID: Int?
    var mode = ""
    
    //IBOUTLET
    @IBOutlet weak var content: UITextView!
    
    
    //IBACTION
    @IBAction func close(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func save(_ sender: UIButton) {
        guard var t = content.text else {return}
        
        t = t.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        if mode == "add"{
            network.send(url: "https://scripttrip.scarletsc.net/iOS/plan.php?user=\(Session.user.UID)&PID=\(planID!)&image=0&publicity=0&content=\(t)&mode=item", method: "POST", query: nil)
        }else if mode == "edit"{
            network.send(url: "https://scripttrip.scarletsc.net/iOS/plan.php?user=\(Session.user.UID)&id=\(item!.IID)&content=\(t)&mode=item", method: "UPDATE", query: nil)
        }
        dismissKb()
    }
    
    
    //DELEGATION
        //NETWORK
    func ResponseHandle(data: Data) {
        guard let result = Session.parser.parse(data) else {
            SVProgressHUD.showError(withStatus: nil)
            SVProgressHUD.dismiss(withDelay: 1.5)
            return
        }
        
        for item in result{
            if (item["Result"] as! String) == "OK"{
                SVProgressHUD.showSuccess(withStatus: nil)
                SVProgressHUD.dismiss(withDelay: 1.5)
            }else{
                SVProgressHUD.showError(withStatus: item["Reason"] as? String)
                SVProgressHUD.dismiss(withDelay: 1.5)
            }
        }
    }
    
    //OBJC FUNC
    @objc func dismissKb(){
        view.endEditing(true)
    }
    
    //FUNC
    func delegate(){
        network.delegate = self
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
        
        content.inputAccessoryView = toolBar
    }
    
    func setup(){
        content.text = item?.I_Content
        content.becomeFirstResponder()
    }
    
    //VIEW CONTROLLER
    override func viewDidLoad(){
        super.viewDidLoad()
        
        delegate()
        
        layout()
        
        setup()
        
    }
    
}
