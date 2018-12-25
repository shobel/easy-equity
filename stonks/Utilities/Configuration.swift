//
//  Configuration.swift
//  stonks
//
//  Created by Samuel Hobel on 10/14/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import Foundation

struct Configuration {
    
    public enum StockDataApiTypes {
        case IEXTrading
    }
    
    public static var stockDataResource = StockDataApiTypes.IEXTrading
}
