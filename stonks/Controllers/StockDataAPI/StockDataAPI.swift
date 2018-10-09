//
//  StockDataAPI.swift
//  stonks
//
//  Created by Samuel Hobel on 9/27/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import Foundation

class StockDataAPI: StockDataApiProtocol {
    func getChart(timeInterval: Constants.TimeIntervals) {}
    func getQuote(ticker: String) {}
    func getQuotes(tickers: [String], completionHandler: @escaping ([Quote])->Void) {}
    func getCompanyData() {}
    func getEarningsData() {}
    func getNews() {}
    func getCompanyLogo() {}
    func listCompanies() {}
    //func listCompanies(completionHandler: @escaping ()->Void) {}
    
}
