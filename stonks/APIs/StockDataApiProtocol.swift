//
//  StockDataApiProtocol.swift
//  stonks
//
//  Created by Samuel Hobel on 9/28/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import Foundation

protocol StockDataApiProtocol {
    
    //iexendpoints: charts
    //Takes a time interval and callback that will take an array of candles
    //Candle object contains the datetime
    func getChart(ticker:String, timeInterval: Constants.TimeIntervals, completionHandler: @escaping ([Candle])->Void)
    
    func getChartForDate(ticker: String, date: String, completionHandler: @escaping ([Candle])->Void)
    
    func getQuote(ticker: String)
    
    //iexendpointsL quote
    //Takes a list of tickers and a callback function that takes an array of quotes
    //Quote object contains the ticker
    func getQuotes(tickers: [String], completionHandler: @escaping ([Quote])->Void)
    
    //iexendpoints: logo, company
    //takes the ticker of interest and callback that takes the dictionary returned
    //dictionary should contain logo, description, and ceo
    func getCompanyData(ticker: String, completionHandler: @escaping ([String:String])->Void)
    
    //iexendpoints: keystats, financials, dividends
    func getFinancialsAndStats()
    
    //iexendpoints: earnings
    func getEarningsData()
    
    //iexendpoints: news
    func getNews()
    
    func listCompanies()
    //func listCompanies(completionHandler: @escaping ()->Void)
}
