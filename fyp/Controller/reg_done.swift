//
//  ViewController3.swift
//  fyp
//
//  Created by Scarlet on 6/3/2019.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit

class reg_done: UIViewController {
    
    //VARIABLE
    
    //IBOUTLET
    @IBOutlet weak var txt: UILabel!
    @IBOutlet weak var btn: UIButton!
    
    //IBACTION
    @IBAction func finishBtn(_ sender: UIButton) {
        let vct = storyboard?.instantiateViewController(withIdentifier: "vct") as! UITabBarController
        
        self.present(vct, animated: false, completion: nil)
    }
    
    //DELEGATION
    
    //OBJC FUNC
    
    //FUNC
    
    //VIEW CONTROLLER
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.2) {
            self.txt.alpha = 1
            self.btn.alpha = 1
        }
        
    }

}
