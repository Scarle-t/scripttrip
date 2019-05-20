//
//  otp_setup.swift
//  fyp
//
//  Created by Scarlet on 5/20/1 R.
//  Copyright © 1 Scarlet. All rights reserved.
//

import UIKit

class otp_setup: UIViewController, NetworkDelegate{
    
    //VARIABLE
    let network = Network()
    var mode = ""
    
    //IBOUTLET
    
    
    //IBACTION
    
    
    //DELEGATION
        //NETWORK
    func ResponseHandle(data: Data) {
        SVProgressHUD.dismiss()
        guard let result = Session.parser.parse(data) else {
            SVProgressHUD.showInfo(withStatus: "An error occur.")
            SVProgressHUD.dismiss(withDelay: 1.5)
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        for item in result{
            if (item["Result"] as! String) == "OK"{
                SVProgressHUD.showSuccess(withStatus: nil)
                SVProgressHUD.dismiss(withDelay: 1.5)
                self.dismiss(animated: true, completion: {
                    if self.mode == "create"{
                        UIApplication.shared.open(URL(string: item["Reason"] as! String)!, options: [:], completionHandler: nil)
                    }
                })
            }else{
                SVProgressHUD.showError(withStatus: item["Reason"] as? String)
                SVProgressHUD.dismiss(withDelay: 1.5)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    //OBJC FUNC
    
    
    //FUNC
    func delegate(){
        network.delegate = self
    }
    
    func layout(){
        
    }
    
    func setup(){
        SVProgressHUD.show()
        if mode == "create" {
            network.send(url: "https://scripttrip.scarletsc.net/iOS/otp.php?mode=create&user=\(Session.user.UID)", method: "POST", query: nil)
        }else if mode == "remove"{
            network.send(url: "https://scripttrip.scarletsc.net/iOS/otp.php?mode=remove&user=\(Session.user.UID)", method: "POST", query: nil)
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
