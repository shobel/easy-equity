//
//  MyRestAPI.swift
//  stonks
//
//  Created by Samuel Hobel on 7/16/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import Foundation
import SwiftyJSON
import ObjectMapper
import Firebase

class MyRestAPI: HTTPRequest {
    
    private var apiurl = "http://192.168.1.8:3000/api"
    //private var apiurl = "http://localhost:3000/api"
    
    private var userEndpoint = "/user"
    private var stockEndpoint = "/stocks"
    private var marketEndpoint = "/market"
    private var authEndpoint = "/auth"
    
    public enum ChartTimeFrames : String {
        case daily, weekly, monthly
    }
    
    public override init(){
        super.init()
    }
    
    public func clearKeychain() {
        KeychainItem.deleteAllKeychainIdentifiers()
    }
    
    public func signOutAndClearKeychain(){
        let body = [
            "email": KeychainItem.currentEmail
        ]
        let queryURL = buildQuery(url: apiurl + authEndpoint + "/signout", params: [:])
        self.postRequest(queryURL: queryURL, body: body) { (data) in
            self.clearKeychain()
        }
    }

    public func signInWithAppleToken(token:String, completionHandler: @escaping (JSON)->Void){
        let body = [
            "token": token
        ]
        let queryURL = buildQuery(url: apiurl + authEndpoint + "/signinwithappletoken", params: [:])
        //this post request should always succeed, save tokens, and take u to landing
        self.postRequest(queryURL: queryURL, body: body) { (data) in
            self.saveTokenObjInKeychain(data)
            completionHandler(data)
        }
    }
    
    public func getNewIdTokenWithRefreshToken(completionHandler: @escaping (JSON)->Void){
        let body = [
            "refreshToken": KeychainItem.currentRefreshToken
        ]
        let queryURL = buildQuery(url: apiurl + authEndpoint + "/getnewidtokenwithrefreshtoken", params: [:])
        httpPostQuery(queryURL: queryURL, token: KeychainItem.currentUserIdentifier, body: body) { (data, response, error) -> Void in
            if let httpResponse = response as? HTTPURLResponse {
                //if refresh token has been revoked, user needs to login again
                if httpResponse.statusCode == 401 || httpResponse.statusCode == 400 {
                    DispatchQueue.main.async {
                        UIApplication.shared.windows.first!.rootViewController?.showAuthViewController()
                    }
                } else {
                    completionHandler(JSON(data!))
                }
            }
        }
    }
    
    public func getWatchlistForCurrentUser(completionHandler: @escaping ()->Void){
        let queryURL = buildQuery(url: apiurl + userEndpoint + "/watchlist", params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            var companies:[Company] = []
            let json = JSON(data)
            for i in 0..<json.count{
                let company = Company(symbol: json[i]["symbol"].string!, fullName: json[i]["companyName"].string!)
                companies.append(company)
            }
            Dataholder.watchlistManager.setWatchlist(companies)
            completionHandler()
        }
    }
    
    public func addToWatchlist(symbol:String, completionHandler: @escaping (JSON)->Void){
        let queryURL = buildQuery(url: apiurl + userEndpoint + "/watchlist/add/" + symbol, params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            completionHandler(data)
        }
    }
    
    public func removeFromWatchlist(symbol:String, completionHandler: @escaping (JSON)->Void){
        let queryURL = buildQuery(url: apiurl + userEndpoint + "/watchlist/remove/" + symbol, params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            completionHandler(data)
        }
    }
    
    public func listCompanies(completionHandler: @escaping ([Company])->Void){
        let queryURL = buildQuery(url: apiurl + stockEndpoint + "/companies", params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            let json = JSON(data)
            var companies:[Company] = []
            for i in 0..<json.count{
                let company = Company(symbol: json[i]["symbol"].string!, fullName: json[i]["companyName"].string!)
                companies.append(company)
            }
            completionHandler(companies)
        }
    }
    
    public func getQuote(symbol:String, completionHandler: @escaping (Quote)->Void){
        let queryURL = buildQuery(url: apiurl + stockEndpoint + "/quote", params: ["symbol":symbol])
        self.getRequest(queryURL: queryURL) { (data) in
            let json = JSON(data)
            var quote:Quote = Quote()
            if let q = Mapper<Quote>().map(JSONString: json.string!){
                quote = q
            }
            completionHandler(quote)
        }
    }
    
    public func getQuoteAndIntradayChart(symbol:String, completionHandler: @escaping (Quote, [Candle])->Void){
        let queryURL = buildQuery(url: apiurl + stockEndpoint + "/charts/quote-and-intraday/" + symbol, params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            let json = JSON(data)
            var quote:Quote = Quote()
            if let q = Mapper<Quote>().map(JSONString: json["quote"].rawString()!){
                quote = q
            }
            var candles:[Candle] = []
            let jsonCandleList = json["intradayChart"]
            for i in 0..<jsonCandleList.count{
                let jsoncandle = jsonCandleList[i]
                var candle = Candle()
                candle.close = jsoncandle["close"].double ?? 0
                candle.open = jsoncandle["open"].double ?? 0
                candle.high = jsoncandle["high"].double ?? 0
                candle.low = jsoncandle["low"].double ?? 0
                candle.volume = jsoncandle["marketVolume"].double ?? 0
                candle.datetime = jsoncandle["label"].string ?? ""
                candle.dateLabel = jsoncandle["date"].string ?? ""
                candles.append(candle)
            }
            completionHandler(quote, candles)
        }
    }
    
    public func getNonIntradayChart(symbol:String, timeframe:ChartTimeFrames, completionHandler: @escaping ([Candle])->Void){
        let queryURL = buildQuery(url: apiurl + stockEndpoint + "/charts/" + timeframe.rawValue + "/" + symbol, params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            let json = JSON(data)
            var candles:[Candle] = []
            for i in 0..<json.count{
                let jsoncandle = json[i]
                candles.append(Candle.createNonIntradayCandleFromJson(jsoncandle: jsoncandle))
            }
            if candles[0].datetime! > candles[candles.count - 1].datetime! {
                completionHandler(candles.reversed())
            } else {
                completionHandler(candles)
            }
        }
    }
    
    public func getQuotes(symbols:[String], completionHandler: @escaping ([Quote])->Void){
        let queryURL = buildQuery(url: apiurl + stockEndpoint + "/quotes", params: ["symbols":symbols.joined(separator: ",")])
        self.getRequest(queryURL: queryURL) { (data) in
            let json = JSON(data)
            var quotes:[Quote] = []
            for (symbol,_):(String, JSON) in json {
                let JSONString:String = json[symbol].rawString()!
                var quote:Quote = Quote()
                if let q = Mapper<Quote>().map(JSONString: JSONString){
                    quote = q
                }
                quotes.append(quote)
            }
            completionHandler(quotes)
        }
    }
    
    public func getQuotesAndSimplifiedCharts(symbols:[String], completionHandler: @escaping ([Quote])->Void){
        let queryURL = buildQuery(url: apiurl + stockEndpoint + "/quotes-and-simplified-charts", params: ["symbols":symbols.joined(separator: ",")])
        self.getRequest(queryURL: queryURL) { (data) in
            let json = JSON(data)
            var quotes:[Quote] = []
            for (symbol,_):(String, JSON) in json {
                let quoteJSONString:String = json[symbol]["latestQuote"].rawString()!
                var quote:Quote = Quote()
                if let q = Mapper<Quote>().map(JSONString: quoteJSONString){
                    quote = q
                }
                let simplifiedChartJSON = json[symbol]["simplifiedChart"]
                var simplifiedChart:[DatedValue] = []
                for i in 0..<simplifiedChartJSON.count {
                    let minute:String = simplifiedChartJSON[i]["minute"].string!
                    let value:Double = simplifiedChartJSON[i]["close"].double!
                    let datedValue:DatedValue = DatedValue(date: Date(), datestring: minute, value: value)
                    simplifiedChart.append(datedValue)
                }
                quote.simplifiedChart = simplifiedChart
                quotes.append(quote)
            }
            completionHandler(quotes)
        }
    }
    
    public func getAllFreeData(symbol:String, completionHandler: @escaping (GeneralInfo, KeyStats, [News], PriceTarget, [Earnings], Recommendations, AdvancedStats, [CashFlow], [Income], Estimates, [Insider], PriceTargetTopAnalysts?)->Void){
        let queryURL = buildQuery(url: apiurl + stockEndpoint + "/allfree/" + symbol, params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            let json = JSON(data)
            let companyLogoPeersJSON = json["companyLogoPeers"].rawString()!
            let generalInfo:GeneralInfo = Mapper<GeneralInfo>().map(JSONString: companyLogoPeersJSON) ?? GeneralInfo()
            let keystatsJSON = json["keystats"].rawString()!
            let keystats:KeyStats = Mapper<KeyStats>().map(JSONString: keystatsJSON) ?? KeyStats()
            let advancedJSON = json["advanced"].rawString()!
            let advancedStats:AdvancedStats = Mapper<AdvancedStats>().map(JSONString: advancedJSON) ?? AdvancedStats()
            let newsJSON = json["news"]
            var newsList:[News] = []
            for i in 0..<newsJSON.count{
                let s:String = newsJSON[i].rawString()!
                if let n = Mapper<News>().map(JSONString: s){
                    if Constants.demo || n.lang == "en" {
                        newsList.append(n)
                    }
                }
            }
            let priceTargetJSON = json["priceTarget"].rawString()!
            let priceTarget:PriceTarget = Mapper<PriceTarget>().map(JSONString: priceTargetJSON) ?? PriceTarget()
            let recommendationsJSON = json["recommendations"].rawString()!
            let recommendations:Recommendations = Mapper<Recommendations>().map(JSONString: recommendationsJSON) ?? Recommendations()
            let earningsJSON = json["earnings"]
            var earningsList:[Earnings] = []
            for i in 0..<earningsJSON.count{
                let s:String = earningsJSON[i].rawString()!
                if let e = Mapper<Earnings>().map(JSONString: s){
                    earningsList.append(e)
                }
            }
            let incomeJSON = json["incomes"]
            var incomeList:[Income] = []
            for i in 0..<incomeJSON.count{
                let s:String = incomeJSON[i].rawString()!
                if let income = Mapper<Income>().map(JSONString: s){
                    incomeList.append(income)
                }
            }
            let cashFlowJSON = json["cashflows"]
            var cashFlowList:[CashFlow] = []
            for i in 0..<cashFlowJSON.count{
                let s:String = cashFlowJSON[i].rawString()!
                if let cf = Mapper<CashFlow>().map(JSONString: s){
                    cashFlowList.append(cf)
                }
            }
            let estimatesJSON = json["estimates"].rawString()!
            let estimates:Estimates = Mapper<Estimates>().map(JSONString: estimatesJSON) ?? Estimates()
            let insidersJSON = json["insiders"]
            var insiderList:[Insider] = []
            for i in 0..<insidersJSON.count{
                let s:String = insidersJSON[i].rawString()!
                if let insider = Mapper<Insider>().map(JSONString: s){
                    insiderList.append(insider)
                }
            }
            let tipranksJSON = json["tipranksAnalysts"].rawString()!
            let tipranks:PriceTargetTopAnalysts? = Mapper<PriceTargetTopAnalysts>().map(JSONString: tipranksJSON) ?? nil
            completionHandler(generalInfo, keystats, newsList, priceTarget, earningsList, recommendations, advancedStats, cashFlowList, incomeList, estimates, insiderList, tipranks)
        }
    }
    
    public func getPremiumData(symbol:String, completionHandler: @escaping (Kscore, BrainSentiment)->Void){
        let queryURL = buildQuery(url: apiurl + stockEndpoint + "/premium/all/" + symbol, params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            let json = JSON(data)
            let kscoresJSON = json["kscore"].rawString()!
            var kscore:Kscore = Kscore()
            if let k = Mapper<Kscore>().map(JSONString: kscoresJSON){
                kscore = k
            }
            let brainSentimentJSON = json["brainSentiment"].rawString()!
            var brainSentiment:BrainSentiment = BrainSentiment()
            if let b = Mapper<BrainSentiment>().map(JSONString: brainSentimentJSON){
                brainSentiment = b
            }
            completionHandler(kscore, brainSentiment)
        }
    }
    
    public func getTop10s(completionHandler: @escaping (Top10s)->Void){
        let queryURL = buildQuery(url: apiurl + marketEndpoint + "/top10", params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            let json = JSON(data)
            let keys:[String] = ["gainers", "losers", "mostactive"]
            var top10s:Top10s = Top10s(gainers: [], losers: [], mostactive: [])
            for key in keys {
                var quotes:[SimpleQuote] = []
                let jsonList = json[key]
                for i in 0..<jsonList.count{
                    let simpleQuote =  SimpleQuote(symbol: jsonList[i]["symbol"].string!, companyName: jsonList[i]["companyName"].string!, latestPrice: jsonList[i]["latestPrice"].double!, changePercent: jsonList[i]["changePercent"].double!, change: jsonList[i]["change"].double!, volume: jsonList[i]["latestVolume"].double!)
                     quotes.append(simpleQuote)
                 }
                top10s.setList(key: key, quotes: quotes)
            }
            completionHandler(top10s)
        }
    }
    
    public func getMarketNews(completionHandler: @escaping ([News])->Void){
        let queryURL = buildQuery(url: apiurl + marketEndpoint + "/news", params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            let json = JSON(data)
            var newsList:[News] = []
            for i in 0..<json.count{
                let JSONString:String = json[i].rawString()!
                if let n = Mapper<News>().map(JSONString: JSONString){
                    if Constants.demo || n.lang == "en" {
                        newsList.append(n)
                    }
                }
            }
            completionHandler(newsList)
        }
    }
    
    public func getTiprankSymbols(completionHandler: @escaping ([PriceTargetTopAnalysts])->Void){
        let queryURL = buildQuery(url: apiurl + marketEndpoint + "/tipranks/symbols", params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            let json = JSON(data)
            var symbols:[PriceTargetTopAnalysts] = []
            for i in 0..<json.count{
                let JSONString:String = json[i].rawString()!
                if let n = Mapper<PriceTargetTopAnalysts>().map(JSONString: JSONString){
                    symbols.append(n)
                }
            }
            completionHandler(symbols)
        }
    }
    
    
    private func getRequest(queryURL:String, completion: @escaping (JSON) -> Void) {
        httpGetQuery(queryURL: queryURL, token: KeychainItem.currentUserIdentifier) { (data, response, error) -> Void in
            if let httpResponse = response as? HTTPURLResponse {
                //if token is invalid, get a new token
                if httpResponse.statusCode == 401 || httpResponse.statusCode == 400 {
                    self.getNewIdTokenWithRefreshToken() { (json) -> Void in
                        self.saveTokenObjInKeychain(json)
                        self.getRequest(queryURL: queryURL, completion: { (json2:JSON) in
                            completion(json2)
                        })
                    }
//                    Auth.auth().currentUser?.getIDToken() { (token, authError) in
//                        if authError == nil && token != nil {
//                            self.saveUserTokenInKeychain(token!)
//                            //resend query
//                            self.httpGetQuery(queryURL: queryURL, token: KeychainItem.currentUserIdentifier) { (data2, response2, error2) -> Void in
//                                if let httpResponse2 = response2 as? HTTPURLResponse {
//                                    if httpResponse2.statusCode == 200 {
//                                        completion(JSON(data2!))
//                                    }
//                                }
//                            }
//                        }
//                    }
                } else if httpResponse.statusCode == 429 {
                    print("Rate limit reached")
                } else if error == nil && data !=  nil {
                    completion(JSON(data!))
                }
            }
        }
    }
    
    private func postRequest(queryURL:String, body:[String:Any], completion: @escaping (JSON) -> Void) {
        httpPostQuery(queryURL: queryURL, token: KeychainItem.currentUserIdentifier, body: body) { (data, response, error) -> Void in
            if let httpResponse = response as? HTTPURLResponse {
                //if token is invalid, get a new token
                if httpResponse.statusCode == 401 || httpResponse.statusCode == 400 {
                    self.getNewIdTokenWithRefreshToken() { (json) -> Void in
                        self.saveTokenObjInKeychain(json)
                        self.getRequest(queryURL: queryURL, completion: { (json2:JSON) in
                            completion(json2)
                        })
                    }
//                    Auth.auth().currentUser?.getIDToken() { (token, authError) in
//                        if authError == nil && token != nil {
//                            self.saveUserTokenInKeychain(token!)
//                            //resend query
//                            self.httpPostQuery(queryURL: queryURL, token: KeychainItem.currentUserIdentifier, body: body) { (data2, response2, error2) -> Void in
//                                if let httpResponse2 = response2 as? HTTPURLResponse {
//                                    if httpResponse2.statusCode == 200 {
//                                        completion(JSON(data!))
//                                    }
//                                }
//                            }
//                        }
//                    }
                } else if error == nil && data !=  nil {
                    completion(JSON(data!))
                }
            }
        }
    }
    
    private func saveTokenObjInKeychain(_ tokenObj: JSON) {
        if let idToken = tokenObj["idToken"].string, let refreshToken = tokenObj["refreshToken"].string {
            do {
                try KeychainItem(service: Bundle.main.bundleIdentifier!, account: "userIdentifier").saveItem(idToken)
                try KeychainItem(service: Bundle.main.bundleIdentifier!, account: "refreshToken").saveItem(refreshToken)
            } catch {
                print("Unable to save userIdentifier to keychain.")
            }
        }
    }
    

}
