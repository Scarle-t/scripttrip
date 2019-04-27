//
//  User.swift
//  fyp
//
//  Created by Scarlet on 28/4/2019.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import Foundation

class User: NSObject{
    
    //ATTRIBUTE
    var UID: Int
    var email: String
    var Fname: String
    var Lname: String
    var Sess_ID: String?
    var type: String
    var icon: String?
    
    //INIT
    override init(){
        UID = 0
        email = ""
        Fname = ""
        Lname = ""
        Sess_ID = nil
        type = ""
        icon = nil
    }
    
}
