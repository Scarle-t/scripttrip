//
//  Item.swift
//  fyp
//
//  Created by Scarlet on 18/4/2019.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import Foundation

class Item: NSObject{
    
    //ATTRIBUTE
    var I_Content: String
    var I_Image: String
    var I_Lat: Double
    var I_Longt: Double
    var Item_order: Int
    
    //INIT
    override init(){
        I_Content = ""
        I_Image = ""
        I_Lat = 0.0
        I_Longt = 0.0
        Item_order = 0
    }
    
}
