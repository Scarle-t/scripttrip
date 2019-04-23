//
//  Category.swift
//  fyp
//
//  Created by Scarlet on 17/4/2019.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import Foundation

class Category: NSObject{
    
    //ATTRIBUTE
    var CID: Int
    var C_Name: String
    
    //INIT
    override init() {
        CID = 0
        C_Name = ""
    }
    
    init(CID: Int, C_Name: String){
        self.CID = CID
        self.C_Name = C_Name
    }
    
}
