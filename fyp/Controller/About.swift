//
//  About.swift
//  fyp
//
//  Created by Scarlet on 5/7/31 H.
//  Copyright © 31 Scarlet. All rights reserved.
//

import UIKit

class About: UIViewController{
    
    //VARIABLE
    
    
    //IBOUTLET
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
        if #available(iOS 13.0, *){
        }else{
            closeBtn.setImage(#imageLiteral(resourceName: "cross_tint"), for: .normal)
        }
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
