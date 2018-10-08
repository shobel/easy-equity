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
    private static var stockDataAPI = StockDataApiTypes.IEXTrading
    private var stockDataApiInstance: StockDataAPI!
    private var currentTicker: String = "FB"

    public enum StockDataApiTypes {
        case IEXTrading
    }
    
    private init(){}
    
    public func getStockDataAPI() -> StockDataAPI {
        if stockDataApiInstance != nil{
            return stockDataApiInstance
        } else {
            switch (StockAPIManager.stockDataAPI) {
            case StockAPIManager.StockDataApiTypes.IEXTrading:
                return IEXTrading()
            }
        }
    }
    
    public func getCurrentTicker() -> String {
        return self.currentTicker
    }
    
    public func setCurrentTicker(ticker:String) {
        self.currentTicker = ticker
    }
    
}
