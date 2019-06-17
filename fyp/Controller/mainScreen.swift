//
//  ViewController.swift
//  fyp
//
//  Created by Scarlet on 6/3/2019.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit
import AuthenticationServices

class mainScreen: UIViewController, UITextFieldDelegate, NetworkDelegate, FBSDKLoginButtonDelegate, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    //VARIABLE
    var state = ""
    var networkState = ""
    var loginButton: FBSDKLoginButton!
    var appleLogin: UIControl?
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
                self.appleLogin?.alpha = 1
                
            }
            state = "login"
        }else if state == "login"{
            view.endEditing(true)
            networkState = "login"
            SVProgressHUD.show()
            network.send(url: "https://scripttrip.scarletsc.net/iOS/login.php", method: "POST", query: "email=\(usr.text!)&pass=\(pwd.text!.sha1())")

        }
    }
    
    @IBAction func registerBtn(_ sender: UIButton) {
        
    }
    
    @IBAction func back(_ sender: UIButton) {
        backFunc()
    }
    
    @IBAction func forgotPass(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: Localized.resetTitle.rawValue.localized(), preferredStyle: .alert)
        alert.addTextField { (email) in
            email.placeholder = Localized.email.rawValue.localized()
            email.keyboardType = .emailAddress
            email.textContentType = .emailAddress
            email.returnKeyType = .next
            email.enablesReturnKeyAutomatically = true
            email.font = UIFont(name: "AvenirNext-Regular", size: 17)
            email.tag = 10
        }
        alert.addTextField { (pass) in
            pass.placeholder = Localized.newPassword.rawValue.localized()
            pass.keyboardType = .asciiCapable
            if #available(iOS 12.0, *) {
                pass.textContentType = .newPassword
            } else {
                // Fallback on earlier versions
            }
            pass.isSecureTextEntry = true
            pass.returnKeyType = .next
            pass.enablesReturnKeyAutomatically = true
            pass.font = UIFont(name: "AvenirNext-Regular", size: 17)
            pass.tag = 11
        }
        alert.addTextField { (verPass) in
            verPass.placeholder = Localized.verifyPassword.rawValue.localized()
            verPass.keyboardType = .asciiCapable
            if #available(iOS 12.0, *) {
                verPass.textContentType = .newPassword
            } else {
                // Fallback on earlier versions
            }
            verPass.isSecureTextEntry = true
            verPass.returnKeyType = .send
            verPass.enablesReturnKeyAutomatically = true
            verPass.font = UIFont(name: "AvenirNext-Regular", size: 17)
            verPass.tag = 12
        }
        alert.addAction(UIAlertAction(title: Localized.OK.rawValue.localized(), style: .default, handler: { [weak alert] _ in
            let emailTxt = alert!.textFields![0]
            let passTxt = alert!.textFields![1]
            let verTxt = alert!.textFields![2]
            
            if emailTxt.text == "" || emailTxt.text == nil{
                emailTxt.layer.borderColor = "FF697B".uiColor.cgColor
                emailTxt.layer.borderWidth = 1
                alert!.actions[0].isEnabled = false
            }
            
            if passTxt.text == "" || passTxt.text == nil{
                passTxt.layer.borderColor = "FF697B".uiColor.cgColor
                passTxt.layer.borderWidth = 1
                alert!.actions[0].isEnabled = false
            }
            
            if verTxt.text == "" || verTxt.text == nil{
                verTxt.layer.borderColor = "FF697B".uiColor.cgColor
                verTxt.layer.borderWidth = 1
                alert!.actions[0].isEnabled = false
            }
            
            if passTxt.text != verTxt.text {
                passTxt.layer.borderColor = "FF697B".uiColor.cgColor
                verTxt.layer.borderColor = "FF697B".uiColor.cgColor
                passTxt.layer.borderWidth = 1
                verTxt.layer.borderWidth = 1
                alert!.actions[0].isEnabled = false
            }
            
            self.networkState = "reset"
            
            self.network.send(url: "https://scripttrip.scarletsc.net/iOS/reset.php", method: "POST", query: "email=\(emailTxt.text!)&pass=\(passTxt.text!.sha1())")
            
            alert?.dismiss(animated: true, completion: nil)
            
        }))
        alert.addAction(UIAlertAction(title: Localized.Cancel.rawValue.localized(), style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    //DELEGATION
        //SIGN IN WITH APPLE
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        
    }
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        switch authorization.credential{
        case let appleID as ASAuthorizationAppleIDCredential:
            networkState = "login_apple"
            SVProgressHUD.show()
            network.send(url: "https://scripttrip.scarletsc.net/iOS/login.php", method: "POST", query: "appleid=\(appleID.user.sha1())")
        case let password as ASPasswordCredential:
            networkState = "login"
            SVProgressHUD.show()
            network.send(url: "https://scripttrip.scarletsc.net/iOS/login.php", method: "POST", query: "email=\(password.user)&pass=\(password.password.sha1())")
        default:
            break
        }
        
    }
        //NETWORK
    func ResponseHandle(data: Data) {
        guard let result = Session.parser.parse(data) else {return}
        
        if networkState == "login"{
            for item in result{
                if (item["Result"] as! String) == "OK"{
                    session.parseUser([item["Reason"] as! NSDictionary])
                    
                    if !userDefault.bool(forKey: "isLoggedIn"){
                        networkState = "otp"
                        network.send(url: "https://scripttrip.scarletsc.net/iOS/otp.php?mode=check&user=\(session.usr.UID)", method: "POST", query: nil)
                    }else{
                        userDefault.set(true, forKey: "isLoggedIn")
                        DispatchQueue.main.async {
                            let vct = self.storyboard?.instantiateViewController(withIdentifier: "vct") as! UITabBarController
                            self.whiteView.alpha = 0
                            self.navigationController?.pushViewController(vct, animated: false)
                        }
                    }
                    
                }else{
                    SVProgressHUD.showError(withStatus: Localized.failLoginMsg.rawValue.localized())
                    SVProgressHUD.dismiss(withDelay: 1.5)
                    DispatchQueue.main.async {
                        self.whiteView.alpha = 0
                    }
                    
                }
            }
        }else if networkState == "reset"{
            for item in result{
                if (item["Result"] as! String) == "OK"{
                    
                    let alert = UIAlertController(title: Localized.resetSuccess.rawValue.localized(), message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: Localized.OK.rawValue.localized(), style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                }else{
                    let alert = UIAlertController(title: Localized.resetFail.rawValue.localized(), message: "\(item["Reason"]!)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: Localized.OK.rawValue.localized(), style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }else if networkState == "otp"{
            SVProgressHUD.dismiss()
            for item in result{
                if (item["Result"] as! String) == "Yes"{
                    DispatchQueue.main.async {
                        let otp_auth = self.storyboard?.instantiateViewController(withIdentifier: "otp_auth") as! otp_authentication
                        self.navigationController?.pushViewController(otp_auth, animated: true)
                    }
                }else{
                    userDefault.set(true, forKey: "isLoggedIn")
                    DispatchQueue.main.async {
                        let vct = self.storyboard?.instantiateViewController(withIdentifier: "vct") as! UITabBarController
                        self.whiteView.alpha = 0
                        self.navigationController?.pushViewController(vct, animated: false)
                    }
                }
            }
        }else if networkState == "login_apple"{
            for item in result{
                if (item["Result"] as! String) == "OK"{
                    session.parseUser([item["Reason"] as! NSDictionary])
                    userDefault.set(true, forKey: "isLoggedIn")
                    DispatchQueue.main.async {
                        let vct = self.storyboard?.instantiateViewController(withIdentifier: "vct") as! UITabBarController
                        self.whiteView.alpha = 0
                        self.navigationController?.pushViewController(vct, animated: false)
                    }
                }else{
                    SVProgressHUD.showError(withStatus: Localized.failLoginMsg.rawValue.localized())
                    SVProgressHUD.dismiss(withDelay: 1.5)
                    DispatchQueue.main.async {
                        self.whiteView.alpha = 0
                    }
                }
            }
        }
    }
    func httpErrorHandle(httpStatus: HTTPURLResponse){
        SVProgressHUD.showInfo(withStatus: "\(Localized.httpErrorMsg.rawValue.localized())\n\(httpStatus.statusCode)")
        SVProgressHUD.dismiss(withDelay: 1.5)
        DispatchQueue.main.async {
            self.whiteView.alpha = 0
        }
    }
    func reachabilityError(){
        SVProgressHUD.showError(withStatus: Localized.networkErrorMsg.rawValue.localized())
        SVProgressHUD.dismiss(withDelay: 1.5)
        DispatchQueue.main.async {
            self.whiteView.alpha = 0
        }
    }
    func URLSessionError(error: Error?){
        SVProgressHUD.showInfo(withStatus: "\(Localized.urlSessionErrorMsg.rawValue.localized())\n\(error ?? Error.self as! Error)")
        SVProgressHUD.dismiss(withDelay: 1.5)
        DispatchQueue.main.async {
            self.whiteView.alpha = 0
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
    
    @available(iOS 13.0, *)
    @objc func handleAppleLogin(){
        let requests = [ASAuthorizationAppleIDProvider().createRequest(),
        ASAuthorizationPasswordProvider().createRequest()]
        
        let controller = ASAuthorizationController(authorizationRequests: requests)
        
        controller.delegate = self
        controller.presentationContextProvider = self
        
        controller.performRequests()
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
            self.appleLogin?.alpha = 0
            
            if self.state == "login"{
                self.login.frame = CGRect(x: self.login.frame.minX, y: self.login.frame.minY - 55, width: self.login.frame.width, height: self.login.frame.height)
            }
            
        }
        state = ""
        SVProgressHUD.dismiss()
    }
    
    func handleFbLogin(){
//        let options = ["fields": "id, email, first_name, last_name, picture.type(large)"]
        SVProgressHUD.show()
        networkState = "login"
        let options = ["fields": "id, email, picture.type(large)"]
        FBSDKGraphRequest(graphPath: "me", parameters: options)?.start(completionHandler: { (con, result, err) in
            guard let result = result as? NSDictionary, err == nil else {return}
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
        let cancelButton = UIBarButtonItem(title: Localized.hideKB.rawValue.localized(), style: .plain, target: self, action: #selector(dismissKb))
        toolBar.barStyle = .default
        toolBar.tintColor = "42C89D".uiColor
        toolBar.isTranslucent = false
        toolBar.sizeToFit()
        toolBar.setItems([spaceButton, cancelButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        cancelButton.setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "AvenirNext-DemiBold", size: 17)!], for: .normal)
        
        login.layer.cornerRadius = 12
        register.layer.cornerRadius = 12
        login.backgroundColor = UIColor(white: 1, alpha: 0.7)
        register.backgroundColor = UIColor(white: 1, alpha: 0.7)
        
        usr.setBottomBorder()
        pwd.setBottomBorder()
        
        let usrPH = NSAttributedString(string: Localized.email.rawValue.localized(), attributes: [NSAttributedString.Key.foregroundColor : UIColor.black])
        let pwdPH = NSAttributedString(string: Localized.password.rawValue.localized(), attributes: [NSAttributedString.Key.foregroundColor : UIColor.black])
        
        usr.backgroundColor = "42E89D".uiColor
        pwd.backgroundColor = "42E89D".uiColor
        
        usr.attributedPlaceholder = usrPH
        pwd.attributedPlaceholder = pwdPH
        
        usr.inputAccessoryView = toolBar
        pwd.inputAccessoryView = toolBar
        
        backBtn.setTitle(Localized.Back.rawValue.localized(), for: .normal)
        forgot.setTitle(Localized.forgotPassword.rawValue.localized(), for: .normal)
        login.setTitle(Localized.Login.rawValue.localized(), for: .normal)
        register.setTitle(Localized.Register.rawValue.localized(), for: .normal)
        
    }
    
    func setup(){
        SVProgressHUD.setHapticsEnabled(true)
        SVProgressHUD.setMinimumSize(CGSize(width: 175, height: 175))
        SVProgressHUD.setFont(UIFont(name: "AvenirNext-Medium", size: 20)!)
        if #available(iOS 12.0, *) {
            switch self.traitCollection.userInterfaceStyle{
            case .light:
                SVProgressHUD.setDefaultStyle(.light)
            case .dark:
                SVProgressHUD.setDefaultStyle(.dark)
            default:
                break
            }
        } else {
            // Fallback on earlier versions
        }
        
        if userDefault.bool(forKey: "isLoggedIn"){
            let uuid = userDefault.value(forKey: "uuid") as! String
            let sessID = userDefault.value(forKey: "sessid") as! String
            SVProgressHUD.show()
            networkState = "login"
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
        loginButton.frame.origin.y = login.frame.maxY + 70 + 55
        loginButton.alpha = 0
        
        if #available(iOS 13.0, *){
            appleLogin = ASAuthorizationAppleIDButton()
            appleLogin?.frame.origin.x = login.frame.origin.x - 13
            appleLogin?.frame.origin.y = login.frame.maxY + 70 + 55 + 55
            appleLogin?.alpha = 0
            appleLogin?.addTarget(self, action: #selector(handleAppleLogin), for: .touchUpInside)
            view.addSubview(appleLogin!)
        }
        view.addSubview(loginButton)
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

