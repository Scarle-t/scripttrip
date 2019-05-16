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
    case deviceSettings
    case Back
    case forgotPassword
    case Login
    case Register
    case introText
    case getStarted
    case nameIntro
    case interestIntro
    case Next
    case hereYouGo
    case letsgo
    case welcomeText
    case Filter
    case Clear
    case secureText
    case name
    case Settings
    case clearHistory
    case shakeForTrips
    case historyError
    case langFooter
    case shakeFooter
    case historyFooter
    case otpTitle
    case Authenticate
}

enum locale: String, CaseIterable{
    case system = "system"
    case en = "en"
    case zhHK = "zh-HK"
//    case ja = "ja"
}

enum cateEnum: Int{
    case fun = 1, dining, relax, sightseeing, artsAndCulture, gathering, hiking, workout, handicraft, hobby, landscape
}

enum color: String{
    case darkGreen = "42C89D"
    case lightGreen = "42E89D"
    case red = "FF697B"
    case blue = "D3F2FF"
}
