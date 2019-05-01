//
//  ViewController.swift
//  fyp
//
//  Created by Scarlet on 6/3/2019.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit

class mainScreen: UIViewController, UITextFieldDelegate, NetworkDelegate, FBSDKLoginButtonDelegate {
    //VARIABLE
    var state = ""
    var loginButton: FBSDKLoginButton!
    let network = Network()
    let session = Session.shared
    let userDefault = UserDefaults.standard
    
    //IBOUTLET
    @IBOutlet weak var logo: UIView!
    @IBOutlet weak var usr: UITextField!
    @IBOutlet weak var pwd: UITextField!
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var register: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var forgot: UIButton!
    @IBOutlet weak var whiteView: UIView!
    
    //IBACTION
    @IBAction func loginAction(_ sender: UIButton) {
        if state == ""{
            UIView.animate(withDuration: 0.5) {
                self.logo.frame = CGRect(x: self.logo.frame.minX, y: self.logo.frame.minY - 50, width: self.logo.frame.width, height: self.logo.frame.height)
                
                self.usr.alpha = 1
                self.pwd.alpha = 1
                self.register.alpha = 0
                self.backBtn.alpha = 1
                self.forgot.alpha = 1
                
                self.login.frame = CGRect(x: self.login.frame.minX, y: self.login.frame.minY + 55, width: self.login.frame.width, height: self.login.frame.height)
                self.loginButton.alpha = 1
                
            }
            state = "login"
        }else if state == "login"{
            view.endEditing(true)
            network.send(url: "https://scripttrip.scarletsc.net/iOS/login.php", method: "POST", query: "email=\(usr.text!)&pass=\(pwd.text!.sha1())")

        }
    }
    
    @IBAction func registerBtn(_ sender: UIButton) {
        
    }
    
    @IBAction func back(_ sender: UIButton) {
        backFunc()
    }
    
    //DELEGATION
        //NETWORK
    func ResponseHandle(data: Data) {
        guard let result = Session.parser.parse(data) else {return}
        
        for item in result{
            if (item["Result"] as! String) == "OK"{
                session.parseUser([item["Reason"] as! NSDictionary])
                let vct = storyboard?.instantiateViewController(withIdentifier: "vct") as! UITabBarController
                if whiteView.alpha == 1{
                    self.present(vct, animated: false, completion: {
                        self.whiteView.alpha = 0
                    })
                }else{
                    self.present(vct, animated: false, completion: backFunc)
                }
                
            }else{
                let alert = UIAlertController(title: "Failed to login.", message: "Please try again.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: ({ _ in
                    DispatchQueue.main.async {
                        self.whiteView.alpha = 0
                    }
                })))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
        //TEXT FIELD
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 0{
            pwd.becomeFirstResponder()
        }else{
            view.endEditing(true)
            network.send(url: "https://scripttrip.scarletsc.net/iOS/login.php", method: "POST", query: "email=\(usr.text!)&pass=\(pwd.text!.sha1())")
        }
        return true
    }
    
        //FB LOGIN
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        handleFbLogin()
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        return
    }
    
    //OBJC FUNC
    @objc func dismissKb(){
        view.endEditing(true)
    }
    
    //FUNC
    func backFunc(){
        view.endEditing(true)
        usr.text = nil
        pwd.text = nil
        UIView.animate(withDuration: 0.5) {
            self.logo.frame = CGRect(x: self.logo.frame.minX, y: self.logo.frame.minY + 50, width: self.logo.frame.width, height: self.logo.frame.height)
            
            self.usr.alpha = 0
            self.pwd.alpha = 0
            self.register.alpha = 1
            self.login.alpha = 1
            self.backBtn.alpha = 0
            self.forgot.alpha = 0
            self.loginButton.alpha = 0
            
            if self.state == "login"{
                self.login.frame = CGRect(x: self.login.frame.minX, y: self.login.frame.minY - 55, width: self.login.frame.width, height: self.login.frame.height)
            }
            
        }
        state = ""
    }
    
    func handleFbLogin(){
//        let options = ["fields": "id, email, first_name, last_name, picture.type(large)"]
        let options = ["fields": "id, email, picture.type(large)"]
        FBSDKGraphRequest(graphPath: "me", parameters: options)?.start(completionHandler: { (con, result, err) in
            guard let result = result as? NSDictionary, err == nil else {return}
            print(result)
            if let picture = result["picture"] as? NSDictionary, let data = picture["data"] as? NSDictionary, let url = data["url"] as? String{
                self.session.usr.icon = url
            }
            
            self.network.send(url: "https://scripttrip.scarletsc.net/iOS/login.php", method: "POST", query: "email=\(result["email"]!)&fbid=\(result["id"]!)&fb")
            self.session.loginState = "fb"
            
        })
    }
    
    func delegate(){
        network.delegate = self
        usr.delegate = self
        pwd.delegate = self
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
        
        login.layer.cornerRadius = 12
        register.layer.cornerRadius = 12
        login.backgroundColor = UIColor(white: 1, alpha: 0.7)
        register.backgroundColor = UIColor(white: 1, alpha: 0.7)
        
        usr.backgroundColor = UIColor(white: 1, alpha: 0.75)
        pwd.backgroundColor = UIColor(white: 1, alpha: 0.75)
        
        usr.inputAccessoryView = toolBar
        pwd.inputAccessoryView = toolBar
        
//        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
//        if statusBar.responds(to: #selector(setter: UIView.backgroundColor)) {
//            statusBar.backgroundColor = "42E89D".toUIColor
//        }
    }
    
    func setup(){
        if userDefault.bool(forKey: "isLoggedIn"){
            let uuid = userDefault.value(forKey: "uuid") as! String
            let sessID = userDefault.value(forKey: "sessid") as! String
            
            network.send(url: "https://scripttrip.scarletsc.net/iOS/login.php", method: "POST", query: "uuid=\(uuid.sha1())&sessID=\(sessID.sha1())")
            
        }else{
            UIView.animate(withDuration: 0.2) {
                self.whiteView.alpha = 0
            }
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKb))
        
        view.addGestureRecognizer(tap)
        
        loginButton = FBSDKLoginButton()
        loginButton.readPermissions = ["email"]
        loginButton.delegate = self
        loginButton.frame = login.frame
        loginButton.frame.origin.x = login.frame.origin.x
        loginButton.frame.origin.y = login.frame.maxY + 50 + 55
        loginButton.alpha = 0
        
        view.addSubview(loginButton)
        
        if FBSDKAccessToken.current() != nil{
            handleFbLogin()
        }
        
    }
    
    //VIEW CONTROLLER
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        delegate()
        layout()
        setup()
        
    }


}

