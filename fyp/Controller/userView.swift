//
//  userView.swift
//  fyp
//
//  Created by Scarlet on R1/J/4.
//  Copyright © 1 Scarlet. All rights reserved.
//

import UIKit

class userView: UIViewController{
    
    //VARIABLE
    let session = Session.shared
    var logout = {}
    
    //IBOUTLET
    @IBOutlet weak var uv: UIView!
    @IBOutlet weak var closeBtn: UIButton!
    
    
    //IBACTION
    @IBAction func close(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //DELEGATION
    
    
    //OBJC FUNC
    
    
    //FUNC
    func delegate(){
        
    }
    
    func layout(){
        session.userView.frame.origin.x = 0
        closeBtn.layer.cornerRadius = 30/2
        if #available(iOS 13.0, *){
            closeBtn.frame.origin.y -= 10
        }else{
            self.view.backgroundColor = .white
            closeBtn.frame.origin.y += 10
        }
        uv.addSubview(session.userView)
    }
    
    func setup(){
        
    }
    
    //VIEW CONTROLLER
    override func viewDidLoad(){
        super.viewDidLoad()
        
        delegate()
        
        layout()
        
        setup()
        
    }
    
}