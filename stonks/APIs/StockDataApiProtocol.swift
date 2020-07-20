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
    func getDailyChart(ticker:String, timeInterval: Constants.TimeIntervals, completionHandler: @escaping ([Candle])->Void)
    
    func getWeeklyChart(ticker:String, timeInterval: Constants.TimeIntervals, completionHandler: @escaping ([Candle])->Void)
    
    func getMonthlyChart(ticker:String, timeInterval: Constants.TimeIntervals, completionHandler: @escaping ([Candle])->Void)
    
    func getChartForDate(ticker: String, date: String, completionHandler: @escaping ([Candle])->Void)
    
    func getQuote(ticker: String)
    
    //iexendpointsL quote
    //Takes a list of tickers and a callback function that takes an array of quotes
    //Quote object contains the ticker
    func getQuotes(tickers: [String], completionHandler: @escaping ([Quote])->Void)
    
    //iexendpoints: logo, company
    //takes the ticker of interest and callback that takes the dictionary returned
    //dictionary should contain logo, description, and ceo
    func getCompanyGeneralInfo(ticker: String, completionHandler: @escaping (GeneralInfo, String)->Void)
    
    func listCompanies(completionHandler: @escaping ()->Void)
    
    //iexendpoints: stats
    func getKeyStats(ticker: String, completionHandler: @escaping (KeyStats)->Void)
    
    //iexendpoints: news
    func getNews(ticker: String, completionHandler: @escaping ([News])->Void)
    
    /** EXPENSIVE ENDPOINTS BELOW **/
    //iexendpoints: company, logo, stats, news, price-target, earnings, recommendation-trends
    // advanced-stats, financials, estimates
    func getAllData(ticker: String, completionHandler:
        @escaping (GeneralInfo, String, KeyStats, [News], PriceTarget, [Earnings], [Recommendations], AdvancedStats, Financials, Estimates)->Void)
    
    //iexendpoints: price-target -> 500
    func getPriceTarget(ticker: String, completionHandler: @escaping (PriceTarget)->Void)
    
    //iexendpoints: earnings -> 1,000
    func getEarnings(ticker: String, completionHandler: @escaping ([Earnings])->Void)
    
    //iexendpoints: recommendation-trends -> 1,000
    func getRecommendations(ticker: String, completionHandler: @escaping ([Recommendations])->Void)
    
    //iexendpoints: advanced-stats -> 3,005
    func getAdvancedStats(ticker: String, completionHandler: @escaping (AdvancedStats)->Void)
    
    //iexendpoints: financials -> 5,000
    func getFinancials(ticker: String, completionHandler: @escaping (Financials)->Void)
    
    //iexendpoints: estimates -> 10,000
    func getEstimates(ticker: String, completionHandler: @escaping (Estimates)->Void)
}
