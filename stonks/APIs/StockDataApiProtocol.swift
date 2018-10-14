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
    
    func getQuote(ticker: String)
    
    //Takes a list of tickers and a callback function that takes a dictionary of tickers and prices
    func getQuotes(tickers: [String], completionHandler: @escaping ([Quote])->Void)
    
    //endpoints: logo, company, news, key stats, dividends, earnings, financials
    func getCompanyData()
    
    func getEarningsData()
    
    func getNews()
    
    func getCompanyLogo()
    
    func listCompanies()
    //func listCompanies(completionHandler: @escaping ()->Void)
}
