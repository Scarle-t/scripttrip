//
//  ViewController.swift
//  fyp
//
//  Created by Scarlet on 6/3/2019.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit

class mainScreen: UIViewController {
    
    var state = ""
    
    @IBOutlet weak var logo: UIView!
    @IBOutlet weak var usr: UITextField!
    @IBOutlet weak var pwd: UITextField!
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var register: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var forgot: UIButton!
    
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
                
//                self.view.layoutIfNeeded()
                
            }
            state = "login"
        }else if state == "login"{
            
            let vct = storyboard?.instantiateViewController(withIdentifier: "vct") as! UITabBarController
            
            self.present(vct, animated: false, completion: backFunc)
            
        }
    }
    @IBAction func registerBtn(_ sender: UIButton) {
        if state == ""{
            UIView.animate(withDuration: 0.5) {
                self.logo.frame = CGRect(x: self.logo.frame.minX, y: self.logo.frame.minY - 50, width: self.logo.frame.width, height: self.logo.frame.height)
                
                self.usr.alpha = 1
                self.pwd.alpha = 1
                self.login.alpha = 0
                self.backBtn.alpha = 1
                
            }
            state = "register"
        }else if state == "register"{
            UIView.animate(withDuration: 0.5) {
                self.login.alpha = 0
                self.backBtn.alpha = 0
                self.register.alpha = 0
                self.usr.alpha = 0
                self.pwd.alpha = 0
            }
            let interest = storyboard?.instantiateViewController(withIdentifier: "interest") as! ViewController2
            
            self.present(interest, animated: true, completion: backFunc)
            
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        backFunc()
    }
    
    func backFunc(){
        view.endEditing(true)
        UIView.animate(withDuration: 0.5) {
            self.logo.frame = CGRect(x: self.logo.frame.minX, y: self.logo.frame.minY + 50, width: self.logo.frame.width, height: self.logo.frame.height)
            
            self.usr.alpha = 0
            self.pwd.alpha = 0
            self.register.alpha = 1
            self.login.alpha = 1
            self.backBtn.alpha = 0
            self.forgot.alpha = 0
            
            if self.state == "login"{
                self.login.frame = CGRect(x: self.login.frame.minX, y: self.login.frame.minY - 55, width: self.login.frame.width, height: self.login.frame.height)
            }
            
        }
        state = ""
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        login.layer.cornerRadius = 12
        register.layer.cornerRadius = 12
        login.backgroundColor = UIColor(white: 1, alpha: 0.7)
        register.backgroundColor = UIColor(white: 1, alpha: 0.7)
        
        usr.backgroundColor = UIColor(white: 1, alpha: 0.75)
        pwd.backgroundColor = UIColor(white: 1, alpha: 0.75)
        
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to: #selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = "42E89D".toUIColor
        }
        
    }


}

