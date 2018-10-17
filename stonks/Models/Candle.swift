//
//  Candle.swift
//  stonks
//
//  Created by Samuel Hobel on 9/28/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import Foundation

class Candle {
    
    public var datetime: String
    public var volume: Double
    public var high: Double
    public var low: Double
    public var open: Double
    public var close: Double
    
    init(date:String, volume:Double, high:Double, low:Double, open:Double, close:Double) {
        self.datetime = date
        self.volume = volume
        self.high = high
        self.low = low
        self.open = open
        self.close = close
    }
}
