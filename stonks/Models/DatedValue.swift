//
//  DatedNumber.swift
//  stonks
//
//  Created by Samuel Hobel on 2/7/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import Foundation

struct DatedValue {
    
    public var date:Date!
    public var datestring:String!
    public var value:Double!
    
    init(date:Date, datestring:String, value:Double){
        self.date = date
        self.datestring = datestring
        self.value = value
    }
     
}
