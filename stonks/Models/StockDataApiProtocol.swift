//
//  StockDataApiProtocol.swift
//  stonks
//
//  Created by Samuel Hobel on 9/28/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import Foundation

protocol StockDataApiProtocol {
    
    func getChart(timeInterval: Constants.TimeIntervals)
    
    func getQuote()
    
    func getCompanyData()
    
    func getEarningsData()
    
    func getNews()
    
    func getCompanyLogo()
}
