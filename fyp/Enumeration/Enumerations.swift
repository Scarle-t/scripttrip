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
    case networkErrorMsg
    case urlSessionErrorMsg
    case httpErrorMsg
    case reduceMotion
    case tfaText
    case plans
    case removePlanMsg
    case removeItemMsg
    case Delete
    case myPlan
    case Shared
    case from
    case created
    case shareTo
    case stopSharing
    case stopSharingMsg
    case Sharing
    case createNew
    case text
    case imageWithCaption
    case location
    case Title
    case Camera
    case photoLibrary
    case photoEmptyMsg
    case quickAccess
    case quickAccessFooter
    case noLocMsg
    case Interest
    case Licence
    case Disclaimer
    case loginWith
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
