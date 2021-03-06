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
    var order: Int?
    
    //IBOUTLET
    @IBOutlet weak var content: UITextView!
    @IBOutlet weak var save: UIButton!
    @IBOutlet weak var closeCancel: UIButton!
    
    
    //IBACTION
    @IBAction func close(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func save(_ sender: UIButton) {
        guard var t = content.text else {return}
        
        t = t.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        sender.isEnabled = false
        closeCancel.isEnabled = false
        dismissKb()
        if mode == "add"{
            network.send(url: "https://scripttrip.scarletsc.net/iOS/plan.php?user=\(Session.user.UID)&PID=\(planID!)&image=0&i_lat=0&i_longt=0&publicity=0&content=\(t)&order=\(order!)&mode=item", method: "POST", query: nil)
        }else if mode == "edit"{
            network.send(url: "https://scripttrip.scarletsc.net/iOS/plan.php?user=\(Session.user.UID)&id=\(item!.IID)&content=\(t)&mode=item&field=I_Content", method: "UPDATE", query: nil)
        }
    }
    
    
    //DELEGATION
        //NETWORK
    func ResponseHandle(data: Data) {
        guard let result = Session.parser.parse(data) else {
            SVProgressHUD.showError(withStatus: nil)
            SVProgressHUD.dismiss(withDelay: 1.5)
            return
        }
        DispatchQueue.main.async {
            self.save.isEnabled = true
            self.closeCancel.isEnabled = true
        }
        for item in result{
            if (item["Result"] as! String) == "OK"{
                SVProgressHUD.showSuccess(withStatus: nil)
                SVProgressHUD.dismiss(withDelay: 1.5)
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }else{
                SVProgressHUD.showError(withStatus: item["Reason"] as? String)
                SVProgressHUD.dismiss(withDelay: 1.5)
            }
        }
    }
    
    //OBJC FUNC
    @objc func dismissKb(){
        view.endEditing(true)
        content.isEditable = false
        content.gestureRecognizers?.first?.isEnabled = true
    }
    @objc func editText(){
        if !content.isEditable{
            content.isEditable = true
            content.becomeFirstResponder()
            content.gestureRecognizers?.first?.isEnabled = false
        }
    }
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            UIView.animate(withDuration: slideAnimationTime) {
                self.content.frame = CGRect(x: self.content.frame.minX, y: self.content.frame.minY, width: self.content.frame.width, height: self.content.frame.height - keyboardHeight)
            }
            
        }
    }
    @objc func keyboardWillHide(_ notification: Notification){
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            UIView.animate(withDuration: slideAnimationTime) {
                self.content.frame = CGRect(x: self.content.frame.minX, y: self.content.frame.minY, width: self.content.frame.width, height: self.content.frame.height + keyboardHeight)
            }
            
        }
    }
    
    //FUNC
    func delegate(){
        network.delegate = self
    }
    
    func layout(){
        
//        if #available(iOS 13.0, *){
//        }else{
//            save.setImage(#imageLiteral(resourceName: "small_tick_tint"), for: .normal)
//            closeCancel.setImage(#imageLiteral(resourceName: "cross_tint"), for: .normal)
//        }
        
        save.setImage(#imageLiteral(resourceName: "small_tick_tint"), for: .normal)
        closeCancel.setImage(#imageLiteral(resourceName: "cross_tint"), for: .normal)
        
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
        let tap = UITapGestureRecognizer(target: self, action: #selector(editText))
        tap.numberOfTapsRequired = 2
        content.addGestureRecognizer(tap)
        content.isEditable = false
        if content.text.isEmpty{
            editText()
        }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    //VIEW CONTROLLER
    override func viewDidLoad(){
        super.viewDidLoad()
        
        delegate()
        
        layout()
        
        setup()
        
    }
    
}
