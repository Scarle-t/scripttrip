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
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var pv: UIView!
    
    
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
        closeBtn.layer.cornerRadius = 30 / 2
        tripView?.delegate = self
        tripView?.view.frame.origin.y = 0
        if #available(iOS 13.0, *) {
        } else {
            self.view.backgroundColor = .white
            tripView?.view.frame = view.bounds
            closeBtn.frame.origin.y += 23
            closeBtn.setImage(#imageLiteral(resourceName: "cross_tint"), for: .normal)
        }
        pv.addSubview(tripView!.view)
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
