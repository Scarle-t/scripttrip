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
    @IBOutlet weak var loadingTxt: UILabel!
    @IBOutlet weak var loadingWheel: UIActivityIndicatorView!
    
    //IBACTION
    @IBAction func finishBtn(_ sender: UIButton) {
        state = "login"
        network.send(url: "https://scripttrip.scarletsc.net/iOS/login.php", method: "POST", query: "email=\(session.regEmail)&pass=\(session.regPass.sha1())")
    }
    
    //DELEGATION
    func ResponseHandle(data: Data) {
        if state == "reg"{
            guard let result = Session.parser.parse(data) else {return}
            
            for item in result{
                if (item["Result"] as! String) != "OK"{
                    let alert = UIAlertController(title: "Sorry!", message: (item["Reason"] as! String), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
                        self.navigationController?.popViewController(animated: true)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }else if (item["Result"] as! String) == "OK"{
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.2) {
                            self.loadingTxt.alpha = 0
                            self.loadingWheel.alpha = 0
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
                    let vct = storyboard?.instantiateViewController(withIdentifier: "vct") as! UITabBarController
                    self.navigationController?.dismiss(animated: false, completion: nil)
                    UIApplication.shared.keyWindow?.rootViewController!.present(vct, animated: false, completion: nil)
                }else{
                    let alert = UIAlertController(title: "Failed to login.", message: "Please try again.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
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
    }
    
    func setup(){
        state = "reg"
        network.send(url: "https://scripttrip.scarletsc.net/iOS/register.php", method: "POST", query: "email=\(session.regEmail)&pass=\(session.regPass.sha1())&fname=\(session.regFname)&lname=\(session.regLname)")
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
