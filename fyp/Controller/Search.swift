//
//  ViewController6.swift
//  fyp
//
//  Created by Scarlet on 8/3/2019.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit

class Search: UIViewController {

    @IBOutlet weak var nav: UINavigationBar!
    
    @objc func tap(_ sender: UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        
        self.view.addGestureRecognizer(tap)
        
        let menu = UIButton(frame: CGRect(x: 10, y: 10, width: 45, height: 30))
        
        menu.setImage(#imageLiteral(resourceName: "menu"), for: .normal)
        
        nav.addSubview(menu)
        
    }
    
}
