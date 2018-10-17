//
//  StockAPIManager.swift
//  stonks
//
//  Created by Samuel Hobel on 9/28/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import Foundation

class StockAPIManager {
    
    public static let shared = StockAPIManager()
    
    public var stockDataApiInstance: StockDataApiProtocol {
        switch (Configuration.stockDataResource) {
        case Configuration.StockDataApiTypes.IEXTrading:
            return IEXTrading()
        }
    }
    
    private init(){}
    
}
