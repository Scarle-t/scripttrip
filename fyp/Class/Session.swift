//
//  Session.swift
//  fyp
//
//  Created by Scarlet on 16/4/2019.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit

class Session: NSObject{
    
    static let shared = Session()
    static let parser = JSONParser()
    
    fileprivate var categories = [Category]()
    func getCategories()->[Category]{
        return categories
    }
    func setCategories(_ item: [Category]?){
        guard let data = item else {print("data is null"); return}
        self.categories = data
    }
    func parseCategory(_ item: [NSDictionary]?)->[Category]?{
        guard let data = item else {print("data is null"); return nil}
        
        var returnItem = [Category]()
        for item in data{
            guard let cid = item["CID"] as? Int else {print("cid is null"); return nil}
            guard let c_name = item["C_Name"] as? String else {print("c_name is null"); return nil}
            
            returnItem.append(Category(CID: cid, C_Name: c_name))
            
        }
        return returnItem
    }
    
    fileprivate var trips = [Trip]()
    func getTrips()->[Trip]{
        return trips
    }
    func setTrips(_ item: [Trip]?){
        guard let data = item else {print("data is null"); return}
        self.trips = data
    }
    func parseTrip(_ item: [[NSDictionary]]?)->[Trip]?{
        guard let data = item else {print("data is null"); return nil}
        
        var returnItem = [Trip]()
        
        for item in data{
            let trip = Trip()
            for i in item{
                let itm = Item()
                guard let tid = i["TID"] as? Int else {print("tid is null");return nil}
                guard let t_title = i["T_Title"] as? String else {print("t_title is null");return nil}
                guard let cateogry = i["Category"] as? String else {print("category is null");return nil}
                guard let i_content = i["I_Content"] as? String else {print("i_content is null");return nil}
                guard let i_image = i["I_Image"] as? String else {print("i_image is null");return nil}
                guard let i_lat = i["I_Lat"] as? Double else {print("i_lat is null");return nil}
                guard let i_longt = i["I_Longt"] as? Double else {print("i_longt is null");return nil}
                guard let item_order = i["Item_order"] as? Int else {print("item_order is null");return nil}
                guard let trends = i["trends"] as? Int else {print("trends is null");return nil}
                
                trip.TID = tid
                trip.T_Title = t_title
                trip.Category = cateogry
                itm.I_Content = i_content
                itm.I_Image = i_image
                itm.I_Lat = i_lat
                itm.I_Longt = i_longt
                itm.Item_order = item_order
                trip.trends = trends
                trip.naturalLanguage = (i["naturalLanguage"] as? String) ?? nil
                
                trip.Items.append(itm)
                
            }
            returnItem.append(trip)
        }
        return returnItem
    }
    
}
