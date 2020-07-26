//
//  IEXTrading.swift
//  stonks
//
//  Created by Samuel Hobel on 9/28/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import Foundation
import SwiftyJSON
import ObjectMapper
class IEXTrading: HTTPRequest, StockDataApiProtocol {
    
    private var stockURL = "https://cloud.iexapis.com/stable/stock/" //prod
    private var batchURL = "https://cloud.iexapis.com/stable/stock/market/batch" //prod
    private var listURL = "https://cloud.iexapis.com/stable/ref-data/symbols" //prod
    private var token = "pk_51788eed4b6041a785bee74fe45dc738" //prod
    
    public override init(){
        super.init()
        if Constants.demo {
            self.stockURL = "https://sandbox.iexapis.com/stable/stock/" //dev
            self.batchURL = "https://sandbox.iexapis.com/stable/stock/market/batch" //dev
            self.listURL = "https://sandbox.iexapis.com/stable/ref-data/symbols" //dev
            self.token = "Tpk_9d0624f076804597a3983357fec689d7" //dev
        }
    }

    private var queries = (
        chart: "chart",
        company: "company",
        earnings: "earnings",
        logo: "logo",
        news: "news",
        quote: "quote"
    )
    
    private var stockTypes = (
        common: "cs",
        exchangeTraded: "et"
    )
    
    private var timeFrames = [
        Constants.TimeIntervals.day: "1d",
        Constants.TimeIntervals.one_month: "1m",
        Constants.TimeIntervals.three_month: "3m",
        Constants.TimeIntervals.six_month: "6m",
        Constants.TimeIntervals.one_year: "1y",
        Constants.TimeIntervals.five_year: "5y",
        Constants.TimeIntervals.max: "max"
    ]
    
    //iexendpoints: logo and company
    func getCompanyGeneralInfo(ticker: String, completionHandler: @escaping (GeneralInfo, String)->Void) {
        let params = [
            "symbols": ticker,
            "types": "logo,company",
            "token": token
        ]
        let queryURL = buildQuery(url: batchURL, params: params)
        sendQuery(queryURL: queryURL, completionHandler: { (data, response, error) -> Void in
            if let data = data {
                let json = JSON(data)
                let JSONString:String = json[ticker]["company"].rawString()!
                var generalInfo:GeneralInfo = GeneralInfo()
                if let g = Mapper<GeneralInfo>().map(JSONString: JSONString){
                    generalInfo = g
                }
                let logo = json[ticker]["logo"]["url"].string!
                completionHandler(generalInfo, logo)
            }
        })

    }
    
    func getDailyChart(ticker: String, timeInterval: Constants.TimeIntervals, completionHandler: @escaping ([Candle]) -> Void) {
        let params:[String] = [stockURL, ticker, queries.chart, timeFrames[timeInterval]!]
        let queryURL = params.joined(separator: "/")
        let finalQuery = buildQuery(url: queryURL + "?", params: ["token": token])
        
        sendQuery(queryURL: finalQuery, completionHandler: { (data, response, error) -> Void in
            if let data = data {
                let json = JSON(data)
                var candles:[Candle] = []
                var candle:Candle
                for i in 0..<json.count{
                    if let date = json[i]["label"].string,
                        let volume = json[i]["volume"].double,
                        let high = json[i]["high"].double,
                        let low = json[i]["low"].double,
                        let open = json[i]["open"].double,
                        let close = json[i]["close"].double {
                        let dateString = NumberFormatter.formatDate(date)
                        candle = Candle(datetime: dateString, volume: volume, high: high, low: low, open: open, close: close)
                        candles.append(candle)
                    }
                }
                //print(json)
                completionHandler(candles)
            }
        })
    }
    
    func getWeeklyChart(ticker: String, timeInterval: Constants.TimeIntervals, completionHandler: @escaping ([Candle]) -> Void) {
        
    }
    
    func getMonthlyChart(ticker: String, timeInterval: Constants.TimeIntervals, completionHandler: @escaping ([Candle]) -> Void) {
        
    }
    
    func getChartForDate(ticker: String, date: String, completionHandler: @escaping ([Candle]) -> Void) {
        var params:[String];
        if (date == ""){
            params = [stockURL, ticker, "intraday-prices"]
        } else {
            params = [stockURL, ticker, queries.chart, "date", date]
        }
        let queryURL = params.joined(separator: "/")
        let finalQuery = buildQuery(url: queryURL + "?", params: ["token": token])
        
        sendQuery(queryURL: finalQuery, completionHandler: { (data, response, error) -> Void in
            if let data = data {
                let json = JSON(data)
                var candles:[Candle] = []
                var candle:Candle
                for i in 0..<json.count{
                    if let date = json[i]["label"].string,
                        let volume = json[i]["volume"].double,
                        let high = json[i]["high"].double,
                        let low = json[i]["low"].double,
                        let open = json[i]["open"].double,
                        let close = json[i]["close"].double {
                        let dateString = NumberFormatter.formatDate(date)
                        candle = Candle(datetime: dateString, volume: volume, high: high, low: low, open: open, close: close)
                        candles.append(candle)
                    }
                }
                //print(json)
                completionHandler(candles)
            }
        })
    }
    
    
    func getQuotes(tickers: [String], completionHandler: @escaping ([Quote])->Void){
        let params = [
            "symbols": tickers.joined(separator: ","),
            "types": "quote",
            "token": token
        ]
        let queryURL = buildQuery(url: batchURL, params: params)
        sendQuery(queryURL: queryURL, completionHandler: { (data, response, error) -> Void in
            if let data = data {
                let json = JSON(data)
                var quotes:[Quote] = []
                for (ticker,_):(String, JSON) in json {
                    let JSONString:String = json[ticker]["quote"].rawString()!
                    var quote:Quote = Quote()
                    if let q = Mapper<Quote>().map(JSONString: JSONString){
                        quote = q
                    }
                    quotes.append(quote)
                }
                completionHandler(quotes)
            }
        })
    }
    
    func listCompanies(completionHandler: @escaping () -> Void) {
        
    }
    
    func getQuote(ticker: String) {
        
    }
    
    func getKeyStats(ticker: String, completionHandler: @escaping (KeyStats) -> Void) {
        let params = [
            "symbols": ticker,
            "types": "stats",
            "token": token
        ]
        let queryURL = buildQuery(url: batchURL, params: params)
        sendQuery(queryURL: queryURL, completionHandler: { (data, response, error) -> Void in
            if let data = data {
                let json = JSON(data)
                let JSONString:String = json[ticker]["stats"].rawString()!
                var keystats:KeyStats = KeyStats()
                if let s = Mapper<KeyStats>().map(JSONString: JSONString){
                    keystats = s
                }
                completionHandler(keystats)
            }
        })
    }
    
    func getNews(ticker: String, completionHandler: @escaping ([News]) -> Void) {
        let params = [
            "symbols": ticker,
            "types": "news",
            "token": token
        ]
        let queryURL = buildQuery(url: batchURL, params: params)
        sendQuery(queryURL: queryURL, completionHandler: { (data, response, error) -> Void in
            if let data = data {
                let json = JSON(data)
                let jsonNews = json[ticker]["news"]
                var newsList:[News] = []
                for i in 0..<jsonNews.count{
                    let JSONString:String = jsonNews[i].rawString()!
                    if let n = Mapper<News>().map(JSONString: JSONString){
                        if n.lang == "en" {
                            newsList.append(n)
                        }
                    }
                }
                completionHandler(newsList)
            }
        })
    }
    
    func getAllData(ticker: String, completionHandler: @escaping (GeneralInfo, String, KeyStats, [News], PriceTarget, [Earnings], [Recommendations], AdvancedStats, Financials, Estimates) -> Void) {
        let params = [
            "symbols": ticker,
            "types": "logo,company,stats,news,price-target,recommendation-trends,earnings,advanced-stats,financials,estimates",
            "last": "20", //this last works for news and all periodical data so it needs to be high
            "token": token
        ]
        let queryURL = buildQuery(url: batchURL, params: params)
        sendQuery(queryURL: queryURL, completionHandler: { (data, response, error) -> Void in
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
              return
            }
            if let data = data {
                let json = JSON(data)
                let jsonPt:String = json[ticker]["price-target"].rawString()!
                let jsonEarnings = json[ticker]["earnings"]["earnings"]
                let jsonRec = json[ticker]["recommendation-trends"]
                let jsonAs:String = json[ticker]["advanced-stats"].rawString()!
                let jsonFinancials:String = json[ticker]["financials"]["financials"][0].rawString()!
                let jsonEstimates:String = json[ticker]["estimates"]["estimates"][0].rawString()!
                let jsonNews = json[ticker]["news"]
                let jsonStats:String = json[ticker]["stats"].rawString()!
                let jsonInfo:String = json[ticker]["company"].rawString()!
                let logo = json[ticker]["logo"]["url"].string!

                var priceTarget:PriceTarget = PriceTarget()
                var earningsList:[Earnings] = []
                var recommendations:[Recommendations] = []
                var advancedStats:AdvancedStats = AdvancedStats()
                var financials:Financials = Financials()
                var estimates:Estimates = Estimates()
                var newsList:[News] = []
                var keystats:KeyStats = KeyStats()
                var generalInfo:GeneralInfo = GeneralInfo()

                if let p = Mapper<PriceTarget>().map(JSONString: jsonPt){
                    priceTarget = p
                }
                for i in 0..<jsonEarnings.count{
                    let s:String = jsonEarnings[i].rawString()!
                    if let e = Mapper<Earnings>().map(JSONString: s){
                        earningsList.append(e)
                    }
                }
                for i in 0..<jsonRec.count{
                    let s:String = jsonRec[i].rawString()!
                    if let r = Mapper<Recommendations>().map(JSONString: s){
                        recommendations.append(r)
                    }
                }
                if let a = Mapper<AdvancedStats>().map(JSONString: jsonAs){
                    advancedStats = a
                }
                if let f = Mapper<Financials>().map(JSONString: jsonFinancials){
                    financials = f
                }
                if let e = Mapper<Estimates>().map(JSONString: jsonEstimates){
                    estimates = e
                }
                for i in 0..<jsonNews.count{
                    let s:String = jsonNews[i].rawString()!
                    if let n = Mapper<News>().map(JSONString: s){
                        if n.lang == "en" {
                            newsList.append(n)
                        }
                    }
                }
                if let s = Mapper<KeyStats>().map(JSONString: jsonStats){
                    keystats = s
                }
                if let g = Mapper<GeneralInfo>().map(JSONString: jsonInfo){
                    generalInfo = g
                }
                completionHandler(generalInfo, logo, keystats, newsList, priceTarget, earningsList, recommendations, advancedStats, financials, estimates)
            }
        })
    }
    
    func getPriceTarget(ticker: String, completionHandler: @escaping (PriceTarget) -> Void) {
        let params = [
            "symbols": ticker,
            "types": "price-target",
            "token": token
        ]
        let queryURL = buildQuery(url: batchURL, params: params)
        sendQuery(queryURL: queryURL, completionHandler: { (data, response, error) -> Void in
            if let data = data {
                let json = JSON(data)
                let JSONString:String = json[ticker]["price-target"].rawString()!
                var priceTarget:PriceTarget = PriceTarget()
                if let p = Mapper<PriceTarget>().map(JSONString: JSONString){
                    priceTarget = p
                }
                completionHandler(priceTarget)
            }
        })
    }
    
    func getEarnings(ticker: String, completionHandler: @escaping ([Earnings]) -> Void) {
        let params = [
            "symbols": ticker,
            "types": "earnings",
            "last": "4",
            "token": token
        ]
        let queryURL = buildQuery(url: batchURL, params: params)
        sendQuery(queryURL: queryURL, completionHandler: { (data, response, error) -> Void in
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
              return
            }
            if let data = data {
                let json = JSON(data)
                let jsonEarnings = json[ticker]["earnings"]["earnings"]
                var earningsList:[Earnings] = []
                for i in 0..<jsonEarnings.count{
                    let JSONString:String = jsonEarnings[i].rawString()!
                    if let e = Mapper<Earnings>().map(JSONString: JSONString){
                        earningsList.append(e)
                    }
                }
                completionHandler(earningsList)
            }
        })
    }
    
    func getRecommendations(ticker: String, completionHandler: @escaping ([Recommendations]) -> Void) {
        let params = [
            "symbols": ticker,
            "types": "recommendation-trends",
            "token": token
        ]
        let queryURL = buildQuery(url: batchURL, params: params)
        sendQuery(queryURL: queryURL, completionHandler: { (data, response, error) -> Void in
            if let data = data {
                let json = JSON(data)
                let jsonRec = json[ticker]["recommendation-trends"]
                var recommendations:[Recommendations] = []
                for i in 0..<jsonRec.count{
                    let JSONString:String = jsonRec[i].rawString()!
                    if let r = Mapper<Recommendations>().map(JSONString: JSONString){
                        recommendations.append(r)
                    }
                }
                completionHandler(recommendations)
            }
        })
    }
    
    func getAdvancedStats(ticker: String, completionHandler: @escaping (AdvancedStats) -> Void) {
        let params = [
            "symbols": ticker,
            "types": "advanced-stats",
            "token": token
        ]
        let queryURL = buildQuery(url: batchURL, params: params)
        sendQuery(queryURL: queryURL, completionHandler: { (data, response, error) -> Void in
            guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
              return
            }
            if let data = data {
                let json = JSON(data)
                let JSONString:String = json[ticker]["advanced-stats"].rawString()!
                var advancedStats:AdvancedStats = AdvancedStats()
                if let a = Mapper<AdvancedStats>().map(JSONString: JSONString){
                    advancedStats = a
                }
                completionHandler(advancedStats)
            }
        })
    }
    
    func getFinancials(ticker: String, completionHandler: @escaping (Financials) -> Void) {
        let params = [
            "symbols": ticker,
            "types": "financials",
            "token": token
        ]
        let queryURL = buildQuery(url: batchURL, params: params)
        sendQuery(queryURL: queryURL, completionHandler: { (data, response, error) -> Void in
            if let data = data {
                let json = JSON(data)
                let JSONString:String = json[ticker]["financials"]["financials"][0].rawString()!
                var financials:Financials = Financials()
                if let f = Mapper<Financials>().map(JSONString: JSONString){
                    financials = f
                }
                completionHandler(financials)
            }
        })
    }
    
    func getEstimates(ticker: String, completionHandler: @escaping (Estimates) -> Void) {
        let params = [
            "symbols": ticker,
            "types": "estimates",
            "token": token
        ]
        let queryURL = buildQuery(url: batchURL, params: params)
        sendQuery(queryURL: queryURL, completionHandler: { (data, response, error) -> Void in
            guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
              return
            }
            if let data = data {
                let json = JSON(data)
                let JSONString:String = json[ticker]["estimates"]["estimates"][0].rawString()!
                var estimates:Estimates = Estimates()
                if let e = Mapper<Estimates>().map(JSONString: JSONString){
                    estimates = e
                }
                completionHandler(estimates)
            }
        })
    }
    
}
