//
//  Trip.swift
//  fyp
//
//  Created by Scarlet on 18/4/2019.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import Foundation

class Trip: NSObject{
    
    //ATTRIBUTE
    var TID: Int
    var T_Title: String
    var Category: String
    var Items: [Item]
    var trends: Int
    var naturalLanguage: String?
    
    //INIT
    override init(){
        TID = 0
        T_Title = ""
        Category = ""
        Items = []
        trends = 0
        naturalLanguage = nil
    }
    
}
