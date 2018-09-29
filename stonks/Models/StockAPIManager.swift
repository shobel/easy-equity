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
    public static var stockDataAPI = StockDataApiTypes.IEXTrading
    public var stockDataApiInstance: StockDataAPI!
    public var currentTicker: String = "FB"

    public enum StockDataApiTypes {
        case IEXTrading
    }
    
    private init(){}
    
    public func getStockDataAPI() -> StockDataAPI {
        return StockDataApiFactory.getStockDataApi()
    }
    
    public func getCurrentTicker() -> String {
        return self.currentTicker
    }
    
    public func setCurrentTicker(ticker:String) {
        self.currentTicker = ticker
    }
    
}
