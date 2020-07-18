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
    private static let iex = IEXTrading()
    private static let alpha = AlphaVantage()
    private static let myRestAPI = MyRestAPI()
    
    public var stockDataApiInstance: StockDataApiProtocol {
        switch (Configuration.stockDataResource) {
        case .IEXTrading:
            return StockAPIManager.iex
        }
    }
    
    private init(){}
    
}
