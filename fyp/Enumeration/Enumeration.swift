//
//  Enumeration.swift
//  fyp
//
//  Created by Scarlet on 5/12/31 H.
//  Copyright © 31 Scarlet. All rights reserved.
//

import Foundation

enum Localized: String{
    case system
    case en
//    case ja
    case zhHK
    
    case resetTitle
    case failLoginTitle
    case failLoginMsg
    case resetSuccess
    case resetFail
    case regFNMsg
    case regLNMsg
    case regItemMsg
    case regEmailMsg
    case regPwdMsg
    case regVerPwdMsg
    case regEmailRegexMsg
    case regError
    case email
    case password
    case newPassword
    case verifyPassword
    case firstName
    case lastName
    case Yes
    case OK
    case Cancel
    case Success
    case Completed
    case Fail
    case Logout
    case hideKB
    case bookmarks
    case history
    case accountSettings
    case about
    case category
    case explore
    case search
    case searchTrip
    case searchLocation
    case searchPH
    case removeBKMsg
    case historyClearMsg
    case languages
    case Confirm
}

enum locale: String, CaseIterable{
    case system = "system"
    case en = "en"
    case zhHK = "zh-HK"
//    case ja = "ja"
}
