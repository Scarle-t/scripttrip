//
//  addMap.swift
//  fyp
//
//  Created by Scarlet on A2019/J/16.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit
import MapKit

class addMap: UIViewController, MKMapViewDelegate{
    
    //VARIABLE
    
    
    //IBOUTLET
    @IBOutlet weak var map: MKMapView!
    
    
    //IBACTION
    @IBAction func longPressMap(_ sender: UILongPressGestureRecognizer) {
        let point = sender.location(in: map)
        print(map.convert(point, toCoordinateFrom: map))
    }
    
    
    //DELEGATION
    
    
    //OBJC FUNC
    
    
    //FUNC
    func delegate(){
        map.delegate = self
    }
    
    func layout(){
        map.fillSuperview()
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
