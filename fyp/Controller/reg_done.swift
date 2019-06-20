//
//  ViewController3.swift
//  fyp
//
//  Created by Scarlet on 6/3/2019.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit

class reg_done: UIViewController, NetworkDelegate {
    //VARIABLE
    let network = Network()
    let session = Session.shared
    var state = ""
    
    //IBOUTLET
    @IBOutlet weak var txt: UILabel!
    @IBOutlet weak var btn: UIButton!
    
    //IBACTION
    @IBAction func finishBtn(_ sender: UIButton) {
        if state == "regFb"{
            state = "login"
            network.send(url: "https://scripttrip.scarletsc.net/iOS/login.php", method: "POST", query: "email=\(session.regEmail)&fbid=\(session.regFbId)")
            session.loginState = "fb"
        }else{
            state = "login"
            network.send(url: "https://scripttrip.scarletsc.net/iOS/login.php", method: "POST", query: "email=\(session.regEmail)&pass=\(session.regPass.sha1())")
        }
    }
    
    //DELEGATION
    func ResponseHandle(data: Data) {
        if state == "reg" || state == "regFb"{
            guard let result = Session.parser.parse(data) else {return}
            
            for item in result{
                if (item["Result"] as! String) != "OK"{
                    SVProgressHUD.showError(withStatus: Localized.regError.rawValue.localized() + "\n\(item["Reason"] as! String)")
                    SVProgressHUD.dismiss(withDelay: 1.5)
                    self.navigationController?.popViewController(animated: true)
                }else if (item["Result"] as! String) == "OK"{
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.2) {
                            SVProgressHUD.dismiss()
                            self.txt.alpha = 1
                            self.btn.alpha = 1
                        }
                    }
                }
            }
        }else if state == "login"{
            guard let result = Session.parser.parse(data) else {return}
            
            for item in result{
                if (item["Result"] as! String) == "OK"{
                    session.parseUser([item["Reason"] as! NSDictionary])
                    DispatchQueue.main.async {
                        let vct = self.storyboard?.instantiateViewController(withIdentifier: "vct") as! UITabBarController
                        self.session.rootNavigationController?.pushViewController(vct, animated: false)
                        self.navigationController?.dismiss(animated: false, completion: nil)
                    }
//                    UIApplication.shared.keyWindow?.rootViewController!.present(vct, animated: false, completion: nil)
                }else{
                    SVProgressHUD.showError(withStatus: Localized.failLoginTitle.rawValue.localized() + " " + Localized.failLoginMsg.rawValue.localized())
                    SVProgressHUD.dismiss(withDelay: 1.5)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    //OBJC FUNC
    
    
    //FUNC
    func delegate(){
        network.delegate = self
    }
    
    func layout(){
        btn.layer.cornerRadius = 12
        btn.backgroundColor = UIColor(white: 1, alpha: 0.7)
        btn.setTitle(Localized.letsgo.rawValue.localized(), for: .normal)
        txt.text = Localized.welcomeText.rawValue.localized()
    }
    
    func setup(){
        SVProgressHUD.show()
        state = session.regState
        var interest = ""
        for i in session.regInterest{
            interest += "\(i.CID),"
        }
        interest = String(interest.dropLast())
        if state == "regFb"{
            network.send(url: "https://scripttrip.scarletsc.net/iOS/register.php", method: "POST", query: "email=\(session.regEmail)&&fname=\(session.regFname)&lname=\(session.regLname)&interest=\(interest)^&icon=\(session.usr.icon!)&fb=\(session.regFbId)")
        }else{
            state = "reg"
            network.send(url: "https://scripttrip.scarletsc.net/iOS/register.php", method: "POST", query: "email=\(session.regEmail)&pass=\(session.regPass.sha1())&fname=\(session.regFname)&lname=\(session.regLname)&interest=\(interest)")
        }
        
    }
    
    //VIEW CONTROLLER
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        delegate()
        layout()
        setup()
        
    }

}
