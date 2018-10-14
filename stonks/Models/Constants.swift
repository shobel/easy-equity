//
//  Constants.swift
//  stonks
//
//  Created by Samuel Hobel on 9/27/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import Foundation
import UIKit

struct Constants{

    public static var restorationIDs = (details: "companyDetails", watchlist: "watchlist", search: "companySearch")
    
    public enum TimeIntervals{
        case day, one_month, three_month, six_month, one_year, five_year
    }
    
    public enum RatingType {
        case buy, hold
    }
    
    public static var ratingColors:[RatingType:UIColor] = [
        RatingType.buy: lightGreen,
        RatingType.hold: lightOrange
    ]
    
    public static var darkPink = UIColor(red: 234.0/255.0, green: 0.0/255.0, blue: 97.0/255.0, alpha: 1.0)
    public static var lightPink = UIColor(red: 255.0/255.0, green: 140.0/255.0, blue: 173.0/255.0, alpha: 1.0)
    public static var purple = UIColor(red: 199.0/255.0, green: 0.0/255.0, blue: 172.0/255.0, alpha: 1.0)
    public static var green = UIColor(red: 9.0/255.0, green: 196.0/255.0, blue: 122.0/255.0, alpha: 1.0)
    public static var yellow = UIColor(red: 255.0/255.0, green: 202.0/255.0, blue: 39.0/255.0, alpha: 1.0)
    
    public static var lightGreen = UIColor(red: 115.0/255.0, green: 255.0/255.0, blue: 180.0/255.0, alpha: 1.0)
    public static var lightOrange = UIColor(red: 255.0/255.0, green: 240.0/255.0, blue: 183.0/255.0, alpha: 1.0)
}
