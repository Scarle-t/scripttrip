//
//  postView.swift
//  fyp
//
//  Created by Scarlet on R1/J/4.
//  Copyright © 1 Scarlet. All rights reserved.
//

import UIKit

class postView: UIViewController{
    
    //VARIABLE
    var tripView: TripView?
    
    //IBOUTLET
    
    
    //IBACTION
    
    
    //DELEGATION
    
    
    //OBJC FUNC
    
    
    //FUNC
    func delegate(){
        
    }
    
    func layout(){
        tripView?.view.frame.origin.y = 0
        self.view.addSubview(tripView!.view)
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
