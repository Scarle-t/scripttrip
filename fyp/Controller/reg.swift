//
//  reg.swift
//  fyp
//
//  Created by Scarlet on 20/4/2019.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit

class reg: UIViewController, FBSDKLoginButtonDelegate{
    //VARIABLE
    let session = Session.shared
    
    //IBOUTLET
    @IBOutlet weak var regBtn: UIButton!
    @IBOutlet weak var introText: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    
    //IBACTION
    @IBAction func back(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //DELEGATION
        //FB LOGIN
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        handleFbLogin()
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        return
    }
    
    //OBJC FUNC
    
    
    //FUNC
    func handleFbLogin(){
        let options = ["fields": "id, email, first_name, last_name, picture.type(large)"]
        FBSDKGraphRequest(graphPath: "me", parameters: options)?.start(completionHandler: { (con, result, err) in
            guard let result = result as? NSDictionary, err == nil else {return}
            
            self.session.regEmail = result["email"] as! String
            self.session.regFname = result["first_name"] as! String
            self.session.regLname = result["last_name"] as! String
            self.session.regFbId = result["id"] as! String
            
            if let picture = result["picture"] as? NSDictionary, let data = picture["data"] as? NSDictionary, let url = data["url"] as? String{
                self.session.usr.icon = url
            }
            
            let finish = self.storyboard?.instantiateViewController(withIdentifier: "interest") as! reg_interestChoice
            
            self.session.regState = "regFb"
            self.navigationController?.pushViewController(finish, animated: true)
            
        })
    }
    
    func delegate(){
        
    }
    
    func layout(){
        
        UIView.animate(withDuration: 1) {
            self.view.layer.backgroundColor = "D3F2FF".uiColor.cgColor
        }
        
        regBtn.layer.cornerRadius = 12
        regBtn.backgroundColor = UIColor(white: 1, alpha: 0.7)
        
        regBtn.setTitle(Localized.Register.rawValue.localized(), for: .normal)
        introText.text = Localized.introText.rawValue.localized()
        backBtn.setTitle(Localized.Back.rawValue.localized(), for: .normal)
    }
    
    func setup(){
        let loginButton = FBSDKLoginButton()
        loginButton.readPermissions = ["email"]
        loginButton.delegate = self
        loginButton.frame = regBtn.frame
        loginButton.frame.origin.x = regBtn.frame.origin.x
        loginButton.frame.origin.y = regBtn.frame.maxY + 50
        
        view.addSubview(loginButton)
    }
    
    //VIEW CONTROLLER
    override func viewDidLoad(){
        super.viewDidLoad()
        
        delegate()
        
        layout()
        
        setup()
        
    }
    
}
