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
    
    
    //IBACTION
    
    
    //DELEGATION
    
    
    //OBJC FUNC
    
    
    //FUNC
    func delegate(){
        
    }
    
    func layout(){
        session.userView.frame.origin.x = 0
        self.view.addSubview(session.userView)
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
