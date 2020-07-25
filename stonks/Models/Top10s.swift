//
//  Top10List.swift
//  stonks
//
//  Created by Samuel Hobel on 7/23/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import Foundation

struct Top10s {
    
    var gainers:[SimpleQuote]
    var losers:[SimpleQuote]
    var mostactive:[SimpleQuote]
    
    mutating func setList(key:String, quotes:[SimpleQuote]){
        switch(key) {
        case "gainers":
            self.gainers = quotes
        case "losers":
            self.losers = quotes
        case "mostactive":
            self.mostactive = quotes
        default:
            return
        }
    }
}
