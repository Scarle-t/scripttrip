//
//  Tut2.swift
//  fyp
//
//  Created by Scarlet on A2019/J/2.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit

class Tut2: UIViewController{
    
    //MARK: VARIABLE
    
    
    //MARK: IBOUTLET
    
    
    //MARK: IBACTION
    @IBAction func back(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func next(_ sender: UIButton) {
        let tut3 = storyboard?.instantiateViewController(withIdentifier: "tut3") as! Tut3
        navigationController?.pushViewController(tut3, animated: true)
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
