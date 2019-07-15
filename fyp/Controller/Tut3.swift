//
//  Tut3.swift
//  fyp
//
//  Created by Scarlet on A2019/J/2.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit

class Tut3: UIViewController{
    
    //MARK: VARIABLE
    
    
    //MARK: IBOUTLET
    
    
    //MARK: IBACTION
    @IBAction func back(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func done(_ sender: UIButton) {
        UserDefaults.standard.set(false, forKey: "isReg")
        navigationController?.dismiss(animated: true, completion: nil)
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
