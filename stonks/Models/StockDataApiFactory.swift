//
//  StockDataApiFactory.swift
//  stonks
//
//  Created by Samuel Hobel on 9/28/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import Foundation

class StockDataApiFactory {
    
    public static func getStockDataApi() -> StockDataAPI {
        switch (StockAPIManager.stockDataAPI) {
            case StockAPIManager.StockDataApiTypes.IEXTrading:
                return IEXTrading()
        }
    }
    
}
