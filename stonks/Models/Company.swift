//
//  Company.swift
//  stonks
//
//  Created by Samuel Hobel on 9/27/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import Foundation

class Company{
    
    private var ticker:String
    private var dailyData:[Date:Float]?
    private var minuteData:[String:Float]?
    
    init(ticker: String){
        self.ticker = ticker
    }
}
