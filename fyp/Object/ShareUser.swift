//
//  ShareUser.swift
//  fyp
//
//  Created by Scarlet on R1/M/28.
//  Copyright © 1 Scarlet. All rights reserved.
//

import Foundation

class ShareUser: NSObject{
    
    //ATTRIBUTE
    var UID: Int
    var email: String
    var FullName: String
    var icon: String?
    
    //INIT
    override init(){
        UID = 0
        email = ""
        FullName = ""
        icon = nil
    }
    
}
