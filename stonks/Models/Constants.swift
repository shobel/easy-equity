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
    
    public static var c1 = UIColor(red: 234.0/255.0, green: 0.0/255.0, blue: 97.0/255.0, alpha: 1.0)
    public static var c2 = UIColor(red: 199.0/255.0, green: 0.0/255.0, blue: 172.0/255.0, alpha: 1.0)
    public static var green = UIColor(red: 9.0/255.0, green: 196.0/255.0, blue: 122.0/255.0, alpha: 1.0)
    public static var red = UIColor(red: 234.0/255.0, green: 0.0/255.0, blue: 97.0/255.0, alpha: 1.0)
}
