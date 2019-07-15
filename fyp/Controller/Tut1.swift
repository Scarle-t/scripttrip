//
//  Tut1.swift
//  fyp
//
//  Created by Scarlet on A2019/J/2.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit

class Tut1: UIViewController{
    
    //MARK: VARIABLE
    
    
    //MARK: IBOUTLET
    
    
    //MARK: IBACTION
    @IBAction func next(_ sender: UIButton) {
        let tut2 = storyboard?.instantiateViewController(withIdentifier: "tut2") as! Tut2
        navigationController?.pushViewController(tut2, animated: true)
    }
    
    //MARK: DELEGATION
    
    
    //MARK: OBJC FUNC
    
    
    //MARK: FUNC
    func delegate(){
        
    }
    
    func layout(){
        
    }
    
    func setup(){
        
    }
    
    //MARK: VIEW CONTROLLER
    override func viewDidLoad(){
        super.viewDidLoad()
        
        delegate()
        
        layout()
        
        setup()
        
    }
    
}
