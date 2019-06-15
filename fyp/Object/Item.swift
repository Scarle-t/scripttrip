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
    var IID: Int
    var I_Content: String
    var I_Image: String
    var I_Lat: Double?
    var I_Longt: Double?
    var Item_order: Int
    
    //INIT
    override init(){
        IID = 0
        I_Content = ""
        I_Image = ""
        I_Lat = nil
        I_Longt = nil
        Item_order = 0
    }
    
}
