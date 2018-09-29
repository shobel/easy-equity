//
//  Candle.swift
//  stonks
//
//  Created by Samuel Hobel on 9/28/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import Foundation

class Candle {
    
    private var high: Float
    private var low: Float
    private var open: Float
    private var close: Float
    
    init(high: Float, low: Float, open: Float, close: Float) {
        self.high = high
        self.low = low
        self.open = open
        self.close = close
    }
}
