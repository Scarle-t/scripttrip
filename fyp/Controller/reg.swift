//
//  reg.swift
//  fyp
//
//  Created by Scarlet on 20/4/2019.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit

class reg: UIViewController{
    
    //VARIABLE
    
    
    //IBOUTLET
    @IBOutlet weak var regBtn: UIButton!
    
    //IBACTION
    @IBAction func back(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //DELEGATION
    
    
    //OBJC FUNC
    
    
    //FUNC
    func delegate(){
        
    }
    
    func layout(){
        
        UIView.animate(withDuration: 1) {
            self.view.layer.backgroundColor = "D3F2FF".toUIColor.cgColor
        }
        
        regBtn.layer.cornerRadius = 12
        regBtn.backgroundColor = UIColor(white: 1, alpha: 0.7)
        
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
