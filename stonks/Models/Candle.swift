//
//  Candle.swift
//  stonks
//
//  Created by Samuel Hobel on 9/28/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import Foundation

class Candle {
    
    private var date: String
    private var volume: Double
    private var high: Double
    private var low: Double
    private var open: Double
    private var close: Double
    
    init(date:String, volume:Double, high:Double, low:Double, open:Double, close:Double) {
        self.date = date
        self.volume = volume
        self.high = high
        self.low = low
        self.open = open
        self.close = close
    }
}
