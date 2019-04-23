//
//  ViewController6.swift
//  fyp
//
//  Created by Scarlet on 8/3/2019.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit

class Search: UIViewController {
    
    //VARIABLE
    
    //IBOUTLET
    @IBOutlet weak var nav: UINavigationBar!
    
    //IBACTION
    
    
    //DELEGATION
    
    //OBJC FUNC
    @objc func tap(_ sender: UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    //FUNC
    func layout(){
        let menu = UIButton(frame: CGRect(x: 10, y: 10, width: 45, height: 30))
        menu.setImage(#imageLiteral(resourceName: "menu"), for: .normal)
        nav.addSubview(menu)
    }
    
    func setup(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        self.view.addGestureRecognizer(tap)
    }
    
    //VIEW CONTROLLER
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        layout()
        
        setup()
        
    }
    
}
