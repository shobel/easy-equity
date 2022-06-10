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
    
    //private var apiurl = "https://stoccoon.com/api"
    private var apiurl = "http://192.168.1.104:3000/api" //192.168.1.113
    
    private var appEndpoint = "/app"
    private var userEndpoint = "/user"
    private var stockEndpoint = "/stocks"
    private var marketEndpoint = "/market"
    private var authEndpoint = "/auth"
        
    public var networkDelegate:NetworkDelegate?
    
    public enum ChartTimeFrames : String {
        case daily, weekly, monthly
    }
    
    public override init(){
        super.init()
    }
    
    public func getBalanceHistory(completionHandler: @escaping ([DateAndBalance])->Void) {
        let queryURL = buildQuery(url: apiurl + userEndpoint + "/get-linked-account-balance-history", params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            let json = JSON(data)
            let balanceHistoryJson = json["balanceHistory"]
            var balanceHistory:[DateAndBalance] = []
            for i in 0..<balanceHistoryJson.count{
                if let b = Mapper<DateAndBalance>().map(JSONString: balanceHistoryJson[i].rawString()!){
                    balanceHistory.append(b)
                }
            }
            completionHandler(balanceHistory)
        }
    }
    
    public func getLinkedAccountAndHoldings(completionHandler: @escaping (BrokerageAccount?, [Holding])->Void) {
        let queryURL = buildQuery(url: apiurl + userEndpoint + "/get-linked-account-and-holdings", params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            let json = JSON(data)
            let accountJson = json["account"]
            let JSONString:String? = accountJson.rawString()
            if JSONString == nil {
                completionHandler(nil, [])
                return
            }
            let account = Mapper<BrokerageAccount>().map(JSONString: JSONString!)
            let holdingsJson = json["holdings"]
            var holdings:[Holding] = []
            for i in 0..<holdingsJson.count{
                if let h = Mapper<Holding>().map(JSONString: holdingsJson[i].rawString()!){
                    holdings.append(h)
                }
            }
            completionHandler(account, holdings)
        }
    }
    
    public func unlinkPlaidAccount(completionHandler: @escaping ()->Void) {
        let queryURL = buildQuery(url: apiurl + userEndpoint + "/unlink-account", params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            let json = JSON(data)
            completionHandler()
        }
    }
    
    public func createPlaidLinkToken(completionHandler: @escaping (String?)->Void) {
        let queryURL = buildQuery(url: apiurl + userEndpoint + "/create-link-token", params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            let json = JSON(data)
            completionHandler(json["linkToken"].rawString())
        }
    }
    
    public func handleLinkedAccount(_ publicToken:String, account: BrokerageAccount, completionHandler: @escaping ()->Void){
        let body = [
            "publicToken": publicToken,
            "account": account.asDictionary()
        ] as [String : Any]
        let queryURL = buildQuery(url: apiurl + userEndpoint + "/set-linked-account", params: [:])
        self.postRequest(queryURL: queryURL, body: body) { (data) in
            let json = JSON(data)
            completionHandler()
        }
    }
    
    public func verifyReceipt(_ receipt:String, productid:String, completionHandler: @escaping (Int?)->Void){
        let body = [
            "receipt": receipt,
            "productid": productid
        ]
        let queryURL = buildQuery(url: apiurl + userEndpoint + "/verifyReceipt", params: [:])
        self.postRequest(queryURL: queryURL, body: body) { (data) in
            let json = JSON(data)
            if let credits = json["credits"].int {
                completionHandler(credits)
            }
        }
    }
    
    public func clearKeychain() {
        KeychainItem.deleteAllKeychainIdentifiers()
    }
    
    public func signOutAndClearKeychain(){
        let body = [
            "userid": KeychainItem.currentUserIdentifier
        ]
        let queryURL = buildQuery(url: apiurl + authEndpoint + "/signout", params: [:])
        self.postRequest(queryURL: queryURL, body: body) { (data) in
            self.clearKeychain()
        }
    }

    public func signInWithAppleToken(token:String, completionHandler: @escaping (JSON?)->Void){
        let body = [
            "token": token
        ]
        let queryURL = buildQuery(url: apiurl + authEndpoint + "/signinwithappletoken", params: [:])
        //this post request should always succeed, save tokens, and take u to landing
        self.postRequest(queryURL: queryURL, body: body) { (data) in
            if (data.dictionary == nil || data.dictionary!.isEmpty) {
                completionHandler(nil)
            } else {
                self.saveTokenObjInKeychain(data)
                completionHandler(data)
            }
        }
    }
    
    public func createUser(_ withEmail:String, completionHandler: @escaping ()->Void) {
        let queryURL = buildQuery(url: apiurl + userEndpoint + "/createUser/" + withEmail, params: [:])
        //this post request should always succeed, save tokens, and take u to landing
        self.getRequest(queryURL: queryURL) { (data) in
            let json = JSON(data)
            completionHandler()
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
    
    public func getProducts(completionHandler: @escaping ([Product])->Void){
        let queryURL = buildQuery(url: apiurl + appEndpoint + "/products", params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            var products:[Product] = []
            let json = JSON(data)
            for (_,product):(String, JSON) in json {
                let JSONString:String = product.rawString()!
                if let p = Mapper<Product>().map(JSONString: JSONString){
                    products.append(p)
                }
            }
            completionHandler(products)
        }
    }
    
    public func getTopAnalystsSubscription(completionHandler: @escaping (Int?)->Void) {
        let queryURL = buildQuery(url: apiurl + userEndpoint + "/top-analysts-subscription", params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            let json = JSON(data)
            let date = json["date"].int
            completionHandler(date)
        }
    }
    
    public func subscribeTopAnalysts(completionHandler: @escaping (Int?, Int?, String?)->Void) {
        let queryURL = buildQuery(url: apiurl + userEndpoint + "/subscribe-top-analysts", params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            let json = JSON(data)
            if json["error"].string != nil && json["credits"].int != nil {
                completionHandler(nil, json["credits"].intValue, json["error"].stringValue)
            } else if json["data"].int != nil && json["credits"].int != nil {
                completionHandler(json["data"].int, json["credits"].intValue, nil)
            }
        }
    }
    
    public func getSelectedScore(completionHandler: @escaping (String) -> Void) {
        let queryURL = buildQuery(url: apiurl + userEndpoint + "/get-selected-score", params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            let json = JSON(data)
            var selectedScore = ""
            if json["selectedScore"].string != nil {
                selectedScore = json["selectedScore"].string ?? ""
            }
            completionHandler(selectedScore)
        }
    }
        
    public func setSelectedScore(_ selectedScoreId:String) {
        let queryURL = buildQuery(url: apiurl + userEndpoint + "/set-selected-score/" + selectedScoreId, params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            print()
        }
    }
    
    public func getPremiumPackages(completionHandler: @escaping ([PremiumPackage])->Void){
        let queryURL = buildQuery(url: apiurl + appEndpoint + "/premium-packages", params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            var packages:[PremiumPackage] = []
            let json = JSON(data)
            for (_,product):(String, JSON) in json {
                let JSONString:String = product.rawString()!
                if let p = Mapper<PremiumPackage>().map(JSONString: JSONString){
                    packages.append(p)
                }
            }
            completionHandler(packages)
        }
    }
    
    public func getAnalystsPremiumPackage(completionHandler: @escaping (PremiumPackage?)->Void){
        let queryURL = buildQuery(url: apiurl + appEndpoint + "/analysts-premium-package", params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            let json = JSON(data)

            let JSONString:String = json.rawString()!
            if let p = Mapper<PremiumPackage>().map(JSONString: JSONString){
                completionHandler(p)
            } else {
                completionHandler(nil)
            }
        }
    }
    
    public func buyPremiumPackage(symbol:String, packageId:String, completionHandler: @escaping (PremiumDataBase?, Int?, String?)->Void) {
        let queryURL = buildQuery(url: apiurl + userEndpoint + "/spendCredits/" + symbol + "/" + packageId, params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            let json = JSON(data)
            if json["error"].string != nil && json["credits"].int != nil {
                completionHandler(nil, json["credits"].intValue, json["error"].stringValue)
                return
            } else if json["data"].dictionary != nil && json["credits"].int != nil {
                let JSONString:String = json["data"].rawString()!
                if packageId == Constants.premiumPackageIds.PREMIUM_BRAIN_LANGUAGE_METRICS_ALL {
                    if let p = Mapper<BrainLanguage>().map(JSONString: JSONString){
                        completionHandler(p, json["credits"].intValue, nil)
                        return
                    }
                } else if packageId == Constants.premiumPackageIds.PREMIUM_BRAIN_RANKING_21_DAYS {
                    if let p = Mapper<Brain21DayRanking>().map(JSONString: JSONString){
                        completionHandler(p, json["credits"].intValue, nil)
                        return
                    }
                } else if packageId == Constants.premiumPackageIds.PREMIUM_BRAIN_SENTIMENT_30_DAYS {
                    if let p = Mapper<BrainSentiment>().map(JSONString: JSONString){
                        completionHandler(p, json["credits"].intValue, nil)
                        return
                    }
                } else if packageId == Constants.premiumPackageIds.PREMIUM_KAVOUT_KSCORE {
                    if let p = Mapper<Kscore>().map(JSONString: JSONString){
                        completionHandler(p, json["credits"].intValue, nil)
                        return
                    }
                } else if packageId == Constants.premiumPackageIds.STOCKTWITS_SENTIMENT {
                    if let p = Mapper<StocktwitsSentiment>().map(JSONString: JSONString){
                        completionHandler(p, json["credits"].intValue, nil)
                        return
                    }
                } else if packageId == Constants.premiumPackageIds.PREMIUM_PRECISION_ALPHA_PRICE_DYNAMICS {
                    if let p = Mapper<PrecisionAlphaDynamics>().map(JSONString: JSONString){
                        completionHandler(p, json["credits"].intValue, nil)
                        return
                    }
                } else if packageId == Constants.premiumPackageIds.EXTRACT_ALPHA_CROSS_ASSET_MODEL {
                    if let p = Mapper<CrossAsset>().map(JSONString: JSONString){
                        completionHandler(p, json["credits"].intValue, nil)
                        return
                    }
                } else if packageId == Constants.premiumPackageIds.EXTRACT_ALPHA_TACTICAL_MODEL {
                    if let p = Mapper<TacticalModel>().map(JSONString: JSONString){
                        completionHandler(p, json["credits"].intValue, nil)
                        return
                    }
                }
            }
            completionHandler(nil, nil, nil)
        }
    }
    
    public func getReceiptsForCurrentUser(completionHandler: @escaping([Receipt]) -> Void) {
        let queryURL = buildQuery(url: apiurl + userEndpoint + "/getReceipts", params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            var receipts:[Receipt] = []
            let json = JSON(data)
            for i in 0..<json.count{
                if let r = Mapper<Receipt>().map(JSONString: json[i].rawString()!){
                    receipts.append(r)
                }
            }
            completionHandler(receipts)
        }
    }
    
    public func getPremiumTransactionsForCurrentUser(completionHandler: @escaping([PremiumTransaction]) -> Void) {
        let queryURL = buildQuery(url: apiurl + userEndpoint + "/getPremiumTransactions", params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            var trans:[PremiumTransaction] = []
            let json = JSON(data)
            for i in 0..<json.count{
                if let r = Mapper<PremiumTransaction>().map(JSONString: json[i].rawString()!){
                    trans.append(r)
                }
            }
            completionHandler(trans)
        }
    }
    
    public func getWatchlistForCurrentUser(completionHandler: @escaping ([Quote])->Void){
        let queryURL = buildQuery(url: apiurl + userEndpoint + "/watchlist", params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            var companies:[Company] = []
            let json = JSON(data)
            var quotes:[Quote] = []
            for (symbol,_):(String, JSON) in json {
                if symbol == "isUSMarketOpen" {
                    Dataholder.isUSMarketOpen = json[symbol].boolValue
                } else {
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
                    
                    let company:Company = Company(symbol: quote.symbol ?? "", fullName: quote.name ?? "")
                    companies.append(company)
                                        
                }
            }
            Dataholder.watchlistManager.setWatchlist(companies)
            completionHandler(quotes)
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
    
    public func getCreditsForCurrentUser(completionHandler: @escaping (Int)->Void){
        let queryURL = buildQuery(url: apiurl + userEndpoint + "/getCredits", params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            let json = JSON(data)
            if let credits:Int = json["credits"].int {
                completionHandler(credits)
            } else {
                completionHandler(0)
            }
        }
    }
    
    public func getTweetsForTwitterAccountAndSymbol(_ username:String, symbol:String, completionHandler: @escaping ([Tweet])->Void){
        let queryURL = buildQuery(url: apiurl + userEndpoint + "/get-tweets-for-twitter-account-and-symbol/" + username + "/" + symbol, params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            let json = JSON(data)
            var arr:[Tweet] = []
            for i in 0..<json.count{
                let JSONString:String = json[i].rawString()!
                if let q = Mapper<Tweet>().map(JSONString: JSONString){
                    arr.append(q)
                }
            }
            completionHandler(arr)
        }
    }
    
    public func getTwitterAccounts(completionHandler: @escaping ([(account: TwitterAccount, cashtags:[Cashtag])])->Void){
        let queryURL = buildQuery(url: apiurl + userEndpoint + "/get-twitter-accounts", params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            let json = JSON(data)
            var arr:[(account: TwitterAccount, cashtags:[Cashtag])] = []
            for i in 0..<json.count{
                let jsonItem = json[i]
                var twitterAccount:TwitterAccount? = nil
                let JSONString:String = jsonItem["account"].rawString()!
                if let q = Mapper<TwitterAccount>().map(JSONString: JSONString){
                    twitterAccount = q
                }
                var cashtags:[Cashtag] = []
                let cashtagsJson = jsonItem["cashtags"]
                for (_,vals):(String, JSON) in cashtagsJson {
                    let JSONString:String = vals.rawString()!
                    if let q = Mapper<Cashtag>().map(JSONString: JSONString){
                        cashtags.append(q)
                    }
                }
                if let ta = twitterAccount {
                    let tuple = (account: ta, cashtags: cashtags)
                    arr.append(tuple)
                }
            }
            completionHandler(arr)
        }
    }
    
    public func removeTwitterAccount(_ username:String, completionHandler: @escaping ()->Void){
        let queryURL = buildQuery(url: apiurl + userEndpoint + "/remove-twitter-account/" + username, params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            let json = JSON(data)
            completionHandler()
        }
    }
    
    public func getTwitterAccount(_ username:String, completionHandler: @escaping (TwitterAccount?, String?)->Void){
        let queryURL = buildQuery(url: apiurl + userEndpoint + "/get-twitter-account/" + username, params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            let json = JSON(data)
            if let error = json["error"].string {
                completionHandler(nil, error)
            } else if let q = Mapper<TwitterAccount>().map(JSONString: json.rawString()!){
                completionHandler(q, nil)
            }
            completionHandler(nil, nil)
        }
    }
    
    public func addTwitterAccount(_ username:String, completionHandler: @escaping (TwitterAccount?, [Cashtag])->Void){
        let queryURL = buildQuery(url: apiurl + userEndpoint + "/add-twitter-account/" + username, params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            let json = JSON(data)
            var twitterAccount:TwitterAccount? = nil
            let JSONString:String = json["account"].rawString()!
            if let q = Mapper<TwitterAccount>().map(JSONString: JSONString){
                twitterAccount = q
            }
            var cashtags:[Cashtag] = []
            let cashtagsJson = json["cashtags"]
            for (_,vals):(String, JSON) in cashtagsJson {
                let JSONString:String = vals.rawString()!
                if let q = Mapper<Cashtag>().map(JSONString: JSONString){
                    cashtags.append(q)
                }
            }
            completionHandler(twitterAccount, cashtags)
        }
    }
    
    
    public func listCompanies(completionHandler: @escaping ([Company])->Void){
        let queryURL = buildQuery(url: apiurl + stockEndpoint + "/companies", params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            let json = JSON(data)
            var companies:[Company] = []
            for i in 0..<json.count{
                if let symbol = json[i]["symbol"].string, let companyName = json[i]["companyName"].string{
                    let company = Company(symbol: symbol, fullName: companyName)
                    companies.append(company)
                }
            }
            completionHandler(companies)
        }
    }
    
    public func getQuoteAndIntradayChart(symbol:String, completionHandler: @escaping (Quote, [Candle])->Void){
        let queryURL = buildQuery(url: apiurl + stockEndpoint + "/charts/quote-and-intraday/" + symbol, params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            let json = JSON(data)
            Dataholder.isUSMarketOpen = json["isUSMarketOpen"].boolValue
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
                candle.volume = jsoncandle["volume"].double ?? 0
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
            if candles.count > 0 && candles[0].datetime! > candles[candles.count - 1].datetime! {
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
                if symbol == "isUSMarketOpen" {
                    Dataholder.isUSMarketOpen = json[symbol].boolValue
                } else {
                    let JSONString:String = json[symbol].rawString()!
                    var quote:Quote = Quote()
                    if let q = Mapper<Quote>().map(JSONString: JSONString){
                        quote = q
                    }
                    quotes.append(quote)
                }
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
                if symbol == "isUSMarketOpen" {
                    Dataholder.isUSMarketOpen = json[symbol].boolValue
                } else {
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
            }
            completionHandler(quotes)
        }
    }
    
    public func getFirstTabData(symbol:String, completionHandler: @escaping (GeneralInfo, [Quote], Insider, Double, AdvancedStats)->Void) {
        let queryURL = buildQuery(url: apiurl + stockEndpoint + "/statsPeersInsidersAndCompany/" + symbol, params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            let json = JSON(data)
            let companyLogoPeersJSON = json["companyLogoPeers"].rawString()!
            let generalInfo:GeneralInfo = Mapper<GeneralInfo>().map(JSONString: companyLogoPeersJSON) ?? GeneralInfo()
            let peerQuotesJson = json["peerQuotes"]
            var peerQuotes:[Quote] = []
            for (symbol,_):(String, JSON) in peerQuotesJson {
                let JSONString:String = peerQuotesJson[symbol].rawString()!
                var quote:Quote = Quote()
                if let q = Mapper<Quote>().map(JSONString: JSONString){
                    quote = q
                }
                peerQuotes.append(quote)
            }
            let advancedJSON = json["advanced"].rawString()!
            let advancedStats:AdvancedStats = Mapper<AdvancedStats>().map(JSONString: advancedJSON) ?? AdvancedStats()
            let insidersJSON = json["insiders"]
            var insiders:Insider = Insider()
            let s:String = insidersJSON.rawString()!
            if let i = Mapper<Insider>().map(JSONString: s){
                insiders = i
            }
            
            let epsEstimate = json["estimates"]["estimatedEpsAvg"].doubleValue
            completionHandler(generalInfo, peerQuotes, insiders, epsEstimate, advancedStats)
        }
    }
    
    public func getSecondTabData(symbol:String, completionHandler: @escaping ([News], [SocialSentimentFMP], NewsSentiment)->Void) {
        let queryURL = buildQuery(url: apiurl + stockEndpoint + "/newsAndSocial/" + symbol, params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            let json = JSON(data)
            let newsJSON = json["news"]
            var newsList:[News] = []
            for i in 0..<newsJSON.count{
                let s:String = newsJSON[i].rawString()!
                if let n = Mapper<News>().map(JSONString: s){
                    newsList.append(n)
                }
            }
            
            let ssJSON = json["socialSentiment"]
            var sslist:[SocialSentimentFMP] = []
            for i in 0..<ssJSON.count{
                let s:String = ssJSON[i].rawString()!
                if let n = Mapper<SocialSentimentFMP>().map(JSONString: s){
                    sslist.append(n)
                }
            }
            let newsSentJson = json["newsSentiment"].rawString()!
            let ns:NewsSentiment = Mapper<NewsSentiment>().map(JSONString: newsSentJson) ?? NewsSentiment()
            completionHandler(newsList, sslist, ns)
        }
    }
    
    public func getThirdTabData(symbol:String, completionHandler: @escaping ([Earnings], [CashFlow], [CashFlow], [Income], [Income], [BalanceSheet], [BalanceSheet])->Void) {
        let queryURL = buildQuery(url: apiurl + stockEndpoint + "/financials/" + symbol, params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            let json = JSON(data)
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
            let incomeAnnualJSON = json["incomesAnnual"]
            var incomeAnnualList:[Income] = []
            for i in 0..<incomeAnnualJSON.count{
                let s:String = incomeAnnualJSON[i].rawString()!
                if let income = Mapper<Income>().map(JSONString: s){
                    incomeAnnualList.append(income)
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
            let cashFlowAnnualJSON = json["cashflowsAnnual"]
            var cashFlowAnnualList:[CashFlow] = []
            for i in 0..<cashFlowAnnualJSON.count{
                let s:String = cashFlowAnnualJSON[i].rawString()!
                if let cf = Mapper<CashFlow>().map(JSONString: s){
                    cashFlowAnnualList.append(cf)
                }
            }
            
            let bsJSON = json["balanceSheets"]
            var bsList:[BalanceSheet] = []
            for i in 0..<bsJSON.count{
                let s:String = bsJSON[i].rawString()!
                if let bs = Mapper<BalanceSheet>().map(JSONString: s){
                    bsList.append(bs)
                }
            }
            let bsaJSON = json["balanceSheetsAnnual"]
            var bsaList:[BalanceSheet] = []
            for i in 0..<bsaJSON.count{
                let s:String = bsaJSON[i].rawString()!
                if let bsa = Mapper<BalanceSheet>().map(JSONString: s){
                    bsaList.append(bsa)
                }
            }
            completionHandler(earningsList, cashFlowList, cashFlowAnnualList, incomeList, incomeAnnualList, bsList, bsaList)
        }
    }
    
    public func getFourthTabData(symbol:String, completionHandler: @escaping (PriceTarget, Recommendations, PriceTargetTopAnalysts?, [ExpertAndRatingForStock], [SimpleTimeAndPrice], [SimpleTimeAndPrice])->Void) {
        let queryURL = buildQuery(url: apiurl + stockEndpoint + "/analysts/" + symbol, params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            let json = JSON(data)
            let priceTargetJSON = json["priceTarget"].rawString()!
            let priceTarget:PriceTarget = Mapper<PriceTarget>().map(JSONString: priceTargetJSON) ?? PriceTarget()
            let recommendationsJSON = json["recommendations"].rawString()!
            let recommendations:Recommendations = Mapper<Recommendations>().map(JSONString: recommendationsJSON) ?? Recommendations()
            let tipranksJSON = json["tipranksAnalysts"].rawString()!
            let tipranks:PriceTargetTopAnalysts? = Mapper<PriceTargetTopAnalysts>().map(JSONString: tipranksJSON) ?? nil
            
            let tipranksAllJSON = json["tipranksAnalystsAll"]
            var tipranksAllAnalystsList:[ExpertAndRatingForStock] = []
            for i in 0..<tipranksAllJSON.count{
                let s:String = tipranksAllJSON[i].rawString()!
                if let expertAndRatings = Mapper<ExpertAndRatingForStock>().map(JSONString: s){
                    tipranksAllAnalystsList.append(expertAndRatings)
                }
            }
            
            let priceTargetsOverTimeJSON = json["priceTargetsOverTime"]
            var priceTargetsOverTime:[SimpleTimeAndPrice] = []
            for i in 0..<priceTargetsOverTimeJSON.count{
                let s:String = priceTargetsOverTimeJSON[i].rawString()!
                if let pt = Mapper<SimpleTimeAndPrice>().map(JSONString: s){
                    priceTargetsOverTime.append(pt)
                }
            }
            
            let bestPriceTargetsOverTimeJSON = json["bestPriceTargetsOverTime"]
            var bestPriceTargetsOverTime:[SimpleTimeAndPrice] = []
            for i in 0..<bestPriceTargetsOverTimeJSON.count{
                let s:String = bestPriceTargetsOverTimeJSON[i].rawString()!
                if let pt = Mapper<SimpleTimeAndPrice>().map(JSONString: s){
                    bestPriceTargetsOverTime.append(pt)
                }
            }
            completionHandler(priceTarget, recommendations, tipranks, tipranksAllAnalystsList, priceTargetsOverTime, bestPriceTargetsOverTime)
        }
    }
    
    public func getAllFreeData(symbol:String, completionHandler: @escaping (GeneralInfo, [Quote], KeyStats, [News], PriceTarget, [Earnings], Recommendations, AdvancedStats, [CashFlow], [CashFlow], [Income], [Income], Insider, PriceTargetTopAnalysts?, [ExpertAndRatingForStock], [SimpleTimeAndPrice], [SimpleTimeAndPrice])->Void){
        let queryURL = buildQuery(url: apiurl + stockEndpoint + "/allfree/" + symbol, params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            let json = JSON(data)
            let companyLogoPeersJSON = json["companyLogoPeers"].rawString()!
            let generalInfo:GeneralInfo = Mapper<GeneralInfo>().map(JSONString: companyLogoPeersJSON) ?? GeneralInfo()
            let peerQuotesJson = json["peerQuotes"]
            var peerQuotes:[Quote] = []
            for (symbol,_):(String, JSON) in peerQuotesJson {
                let JSONString:String = peerQuotesJson[symbol].rawString()!
                var quote:Quote = Quote()
                if let q = Mapper<Quote>().map(JSONString: JSONString){
                    quote = q
                }
                peerQuotes.append(quote)
            }
            let keystatsJSON = json["keystats"].rawString()!
            let keystats:KeyStats = Mapper<KeyStats>().map(JSONString: keystatsJSON) ?? KeyStats()
            let advancedJSON = json["advanced"].rawString()!
            let advancedStats:AdvancedStats = Mapper<AdvancedStats>().map(JSONString: advancedJSON) ?? AdvancedStats()
            let newsJSON = json["news"]
            var newsList:[News] = []
            for i in 0..<newsJSON.count{
                let s:String = newsJSON[i].rawString()!
                if let n = Mapper<News>().map(JSONString: s){
                    newsList.append(n)
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
            let incomeAnnualJSON = json["incomesAnnual"]
            var incomeAnnualList:[Income] = []
            for i in 0..<incomeAnnualJSON.count{
                let s:String = incomeAnnualJSON[i].rawString()!
                if let income = Mapper<Income>().map(JSONString: s){
                    incomeAnnualList.append(income)
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
            let cashFlowAnnualJSON = json["cashflowsAnnual"]
            var cashFlowAnnualList:[CashFlow] = []
            for i in 0..<cashFlowAnnualJSON.count{
                let s:String = cashFlowAnnualJSON[i].rawString()!
                if let cf = Mapper<CashFlow>().map(JSONString: s){
                    cashFlowAnnualList.append(cf)
                }
            }
            let insidersJSON = json["insiders"]
            var insiders:Insider = Insider()
            let s:String = insidersJSON.rawString()!
            if let i = Mapper<Insider>().map(JSONString: s){
                insiders = i
            }
            let tipranksJSON = json["tipranksAnalysts"].rawString()!
            let tipranks:PriceTargetTopAnalysts? = Mapper<PriceTargetTopAnalysts>().map(JSONString: tipranksJSON) ?? nil
            
            let tipranksAllJSON = json["tipranksAnalystsAll"]
            var tipranksAllAnalystsList:[ExpertAndRatingForStock] = []
            for i in 0..<tipranksAllJSON.count{
                let s:String = tipranksAllJSON[i].rawString()!
                if let expertAndRatings = Mapper<ExpertAndRatingForStock>().map(JSONString: s){
                    tipranksAllAnalystsList.append(expertAndRatings)
                }
            }
            
            let priceTargetsOverTimeJSON = json["priceTargetsOverTime"]
            var priceTargetsOverTime:[SimpleTimeAndPrice] = []
            for i in 0..<priceTargetsOverTimeJSON.count{
                let s:String = priceTargetsOverTimeJSON[i].rawString()!
                if let pt = Mapper<SimpleTimeAndPrice>().map(JSONString: s){
                    priceTargetsOverTime.append(pt)
                }
            }
            
            let bestPriceTargetsOverTimeJSON = json["bestPriceTargetsOverTime"]
            var bestPriceTargetsOverTime:[SimpleTimeAndPrice] = []
            for i in 0..<bestPriceTargetsOverTimeJSON.count{
                let s:String = bestPriceTargetsOverTimeJSON[i].rawString()!
                if let pt = Mapper<SimpleTimeAndPrice>().map(JSONString: s){
                    bestPriceTargetsOverTime.append(pt)
                }
            }
            
            completionHandler(generalInfo, peerQuotes, keystats, newsList, priceTarget, earningsList, recommendations, advancedStats, cashFlowList, cashFlowAnnualList, incomeList, incomeAnnualList, insiders, tipranks, tipranksAllAnalystsList, priceTargetsOverTime, bestPriceTargetsOverTime)
        }
    }
    
    public func getPackageDataForSymbols(_ symbols:[String], packageId:String, completionHandler: @escaping (JSON)->Void) {
        let queryURL = buildQuery(url: apiurl + userEndpoint + "/premium-for-symbols/", params: [
                "symbols":symbols.joined(separator: ","),
                "premiumId": packageId
            ])
        self.getRequest(queryURL: queryURL) { (data) in
            let json = JSON(data)
            completionHandler(json)
        }
    }
                
    public func getPremiumData(symbol:String, completionHandler: @escaping ([String:PremiumDataBase?])->Void){
        let queryURL = buildQuery(url: apiurl + userEndpoint + "/premium/" + symbol, params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            let json = JSON(data)
            
            var dic:[String:PremiumDataBase] = [:]
            if !(json.dictionary?.isEmpty ?? true) {
                for (id, data):(String, JSON) in json {
                    switch id {
                    case Constants.premiumPackageIds.PREMIUM_BRAIN_LANGUAGE_METRICS_ALL:
                        if let x = Mapper<BrainLanguage>().map(JSONString: data.rawString()!){
                            dic[id] = x as PremiumDataBase
                        }
                        break
                    case Constants.premiumPackageIds.PREMIUM_KAVOUT_KSCORE:
                        if let x = Mapper<Kscore>().map(JSONString: data.rawString()!){
                            dic[id] = x as PremiumDataBase
                        }
                        break
                    case Constants.premiumPackageIds.PREMIUM_BRAIN_RANKING_21_DAYS:
                        if let x = Mapper<Brain21DayRanking>().map(JSONString: data.rawString()!){
                            dic[id] = x as PremiumDataBase
                        }
                        break
                    case Constants.premiumPackageIds.PREMIUM_BRAIN_SENTIMENT_30_DAYS:
                        if let x = Mapper<BrainSentiment>().map(JSONString: data.rawString()!){
                            dic[id] = x as PremiumDataBase
                        }
                        break
                    case Constants.premiumPackageIds.STOCKTWITS_SENTIMENT:
                        if let x = Mapper<StocktwitsSentiment>().map(JSONString: data.rawString()!){
                            dic[id] = x as PremiumDataBase
                        }
                        break
                    case Constants.premiumPackageIds.PREMIUM_PRECISION_ALPHA_PRICE_DYNAMICS:
                        if let x = Mapper<PrecisionAlphaDynamics>().map(JSONString: data.rawString()!){
                            dic[id] = x as PremiumDataBase
                        }
                        break
                    case Constants.premiumPackageIds.EXTRACT_ALPHA_CROSS_ASSET_MODEL:
                        if let x = Mapper<CrossAsset>().map(JSONString: data.rawString()!){
                            dic[id] = x as PremiumDataBase
                        }
                        break
                    case Constants.premiumPackageIds.EXTRACT_ALPHA_TACTICAL_MODEL:
                        if let x = Mapper<TacticalModel>().map(JSONString: data.rawString()!){
                            dic[id] = x as PremiumDataBase
                        }
                        break
                    default:
                        break
                    }
                }
            }
            completionHandler(dic)
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
                    let simpleQuote = SimpleQuote(symbol: jsonList[i]["symbol"].string!, companyName: jsonList[i]["companyName"].string!, latestPrice: jsonList[i]["latestPrice"].double!, changePercent: jsonList[i]["changePercent"].double!, change: jsonList[i]["change"].double!, volume: jsonList[i]["latestVolume"].double!)
                     quotes.append(simpleQuote)
                 }
                top10s.setList(key: key, quotes: quotes)
            }
            completionHandler(top10s)
        }
    }
    
    public func getMarketSocials(completionHandler: @escaping ([SocialSentimentFMP], [SocialSentimentChangeFMP], [SocialSentimentChangeFMP])->Void){
        let queryURL = buildQuery(url: apiurl + marketEndpoint + "/socials", params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            let json = JSON(data)
            var trending:[SocialSentimentFMP] = []
            var changeTwitter:[SocialSentimentChangeFMP] = []
            var changeStocktwits:[SocialSentimentChangeFMP] = []
            let trendingJson = json["trending"]
            for i in 0..<trendingJson.count{
                let s:String = trendingJson[i].rawString()!
                if let pt = Mapper<SocialSentimentFMP>().map(JSONString: s){
                    trending.append(pt)
                }
            }
            
            let twitterChangeJson = json["twitterChange"]
            for i in 0..<twitterChangeJson.count{
                let s:String = twitterChangeJson[i].rawString()!
                if let pt = Mapper<SocialSentimentChangeFMP>().map(JSONString: s){
                    changeTwitter.append(pt)
                }
            }

            let stocktwitsChangeJson = json["stocktwitsChange"]
            for i in 0..<stocktwitsChangeJson.count{
                let s:String = stocktwitsChangeJson[i].rawString()!
                if let pt = Mapper<SocialSentimentChangeFMP>().map(JSONString: s){
                    changeStocktwits.append(pt)
                }
            }
            completionHandler(trending, changeTwitter, changeStocktwits)
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
                    newsList.append(n)
                }
            }
            completionHandler(newsList)
        }
    }
    
    public func getTiprankSymbols(_ numAnalystThreshold:String?, completionHandler: @escaping ([PriceTargetTopAnalysts])->Void){
        let queryURL = buildQuery(url: apiurl + userEndpoint + "/tipranks/symbols", params: [
            "numAnalystThreshold": numAnalystThreshold ?? ""
            ])
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
    
    public func getFidelityAnalysts(completionHandler: @escaping ([FidelityScore])->Void){
        let queryURL = buildQuery(url: apiurl + marketEndpoint + "/fidelity/scores", params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            let json = JSON(data)
            var scores:[FidelityScore] = []
            for i in 0..<json.count{
                let JSONString:String = json[i].rawString()!
                if let n = Mapper<FidelityScore>().map(JSONString: JSONString){
                    scores.append(n)
                }
            }
            completionHandler(scores)
        }
    }
    
    public func getStocktwitsPostsTrending(summary:String, completionHandler: @escaping ([StocktwitsPost])->Void){
        let queryURL = buildQuery(url: apiurl + marketEndpoint + "/stocktwits-trending-symbols/" + summary, params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            let json = JSON(data)
            var posts:[StocktwitsPost] = []
            for i in 0..<json.count{
                let JSONString:String = json[i].rawString()!
                if let n = Mapper<StocktwitsPost>().map(JSONString: JSONString){
                    posts.append(n)
                }
            }
            completionHandler(posts)
        }
    }
    
    public func getStocktwitsPostsForSymbol(symbol:String, completionHandler: @escaping ([StocktwitsPost])->Void){
        let queryURL = buildQuery(url: apiurl + userEndpoint + "/stocktwits-for-symbol/" + symbol, params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            let json = JSON(data)
            var posts:[StocktwitsPost] = []
            for i in 0..<json.count{
                let JSONString:String = json[i].rawString()!
                if let n = Mapper<StocktwitsPost>().map(JSONString: JSONString){
                    posts.append(n)
                }
            }
            completionHandler(posts)
        }
    }
    
    public func getScoresWithUserSettingsApplied(completionHandler: @escaping ([SimpleScore])->Void){
        let queryURL = buildQuery(url: apiurl + userEndpoint + "/scores-settings-applied", params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            let json = JSON(data)
            var scores:[SimpleScore] = []
            for i in 0..<json.count{
                let JSONString:String = json[i].rawString()!
                if let n = Mapper<SimpleScore>().map(JSONString: JSONString){
                    scores.append(n)
                }
            }
            completionHandler(scores)
        }
    }
    
    public func getScoresForSymbolsWithUserSettingsApplied(symbols:[String], completionHandler: @escaping ([SimpleScore])->Void){
        let queryURL = buildQuery(url: apiurl + userEndpoint + "/scores-settings-applied-for-symbols", params: ["symbols":symbols.joined(separator: ",")])
        self.getRequest(queryURL: queryURL) { (data) in
            let json = JSON(data)
            var scores:[SimpleScore] = []
            for i in 0..<json.count{
                let JSONString:String = json[i].rawString()!
                if let n = Mapper<SimpleScore>().map(JSONString: JSONString){
                    scores.append(n)
                }
            }
            completionHandler(scores)
        }
    }
    
    public func getScoresForSymbolWithUserSettingsApplied(symbol:String, completionHandler: @escaping (Scores, ScoreSettings)->Void){
        let queryURL = buildQuery(url: apiurl + userEndpoint + "/scores-settings-applied-for-symbol/" + symbol, params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            let json = JSON(data)
            let scoresJSON = json["scores"].rawString()!
            let scores:Scores = Mapper<Scores>().map(JSONString: scoresJSON) ?? Scores()
            let settingsJSON = json["userSettings"].rawString()!
            let settings:ScoreSettings = Mapper<ScoreSettings>().map(JSONString: settingsJSON) ?? ScoreSettings()
            completionHandler(scores, settings)
        }
    }
    
    public func setScoresSettings(scoreSettings:ScoreSettings, completionHandler: @escaping (Bool)->Void){
        let queryURL = buildQuery(url: apiurl + userEndpoint + "/set-score-settings", params: [:])
        let body = [
            "settings": scoreSettings.asDictionary()
        ]
        self.postRequest(queryURL: queryURL, body: body) { (data) in
            let json = JSON(data)
            let success = json["result"].bool ?? false
            completionHandler(success)
        }
    }
    
    public func addUserIssue(message:String, email:String, completionHandler: @escaping ()->Void){
        let queryURL = buildQuery(url: apiurl + userEndpoint + "/add-issue", params: [:])
        let body = [
            "issue": message,
            "email": email
        ]
        self.postRequest(queryURL: queryURL, body: body) { (data) in
            completionHandler()
        }
    }
    
    public func getEmailFromFirstUserIssue(completionHandler: @escaping (String)->Void){
        let queryURL = buildQuery(url: apiurl + userEndpoint + "/get-email-from-latest-issue", params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            let json = JSON(data)
            let email = json["email"].string ?? ""
            completionHandler(email)
        }
    }
    
    public func getMarketAndEconomyData(completionHandler: @escaping (Int, [FearGreedIndicator], [SectorPerformance], [EconomyWeekly], [EconomyMonthly], [Double], String, String)->Void){
        let queryURL = buildQuery(url: apiurl + marketEndpoint + "/market-economy", params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            let json = JSON(data)
            var indicators:[FearGreedIndicator] = []
            let fearGreedJSON = json["fearGreed"]
            let indicatorsJSON = fearGreedJSON["indicators"]
            for i in 0..<indicatorsJSON.count{
                let JSONString:String = indicatorsJSON[i].rawString()!
                if let n = Mapper<FearGreedIndicator>().map(JSONString: JSONString){
                    indicators.append(n)
                }
            }
            let nowValue = fearGreedJSON["timeline"]["now"].string!
            
            let sectorJSON = json["sectorPerformance"]
            var sectorPerformances:[SectorPerformance] = []
            for i in 0..<sectorJSON.count{
                let sp:JSON = sectorJSON[i]
                let sectorPerformance:SectorPerformance = SectorPerformance(name: sp["name"].string ?? "", performance: sp["performance"].double ?? 0.0, updated: sp["lastUpdated"].int ?? 0)
                sectorPerformances.append(sectorPerformance)
            }
            
            let economy = json["economy"]
            let weekly = economy["weekly"]
            var weeklyEconomy:[EconomyWeekly] = []
            for i in 0..<weekly.count{
                let JSONString:String = weekly[i].rawString()!
                if let n = Mapper<EconomyWeekly>().map(JSONString: JSONString){
                    weeklyEconomy.append(n)
                }
            }
            let monthly = economy["monthly"]
            var monthlyEconomy:[EconomyMonthly] = []
            for i in 0..<monthly.count{
                let JSONString:String = monthly[i].rawString()!
                if let n = Mapper<EconomyMonthly>().map(JSONString: JSONString){
                    monthlyEconomy.append(n)
                }
            }
            
            let quarterly = economy["quarterly"]
            var gdps:[Double] = []
            var gdpStartDate = ""
            var gdpEndDate = ""
            for i in 0..<quarterly.count {
                if i == 0 {
                    gdpEndDate = quarterly[i]["id"].string ?? ""
                }
                if i == quarterly.count - 1 {
                    gdpStartDate = quarterly[i]["id"].string ?? ""
                }
                let q = quarterly[i]["realGDP"].double!
                gdps.append(q)
            }
            completionHandler(Int(nowValue) ?? 0, indicators, sectorPerformances, weeklyEconomy, monthlyEconomy, gdps, gdpStartDate, gdpEndDate)
        }
    }
    
    public func getSettingsAndVariables(completionHandler: @escaping (ScoreSettings, [String:String], [String:[String]])->Void){
        let queryURL = buildQuery(url: apiurl + userEndpoint + "/variables-and-score-settings", params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            let json = JSON(data)
            var scoreSettings:ScoreSettings = ScoreSettings()
            let scoreSettingsJSON = json["scoreSettings"].rawString()!
            if let s = Mapper<ScoreSettings>().map(JSONString: scoreSettingsJSON){
                scoreSettings = s
            }
            var variableNamesMap:[String:String] = [:]
            let vnmJsonString = json["variableNames"].rawString()!
            if let data = vnmJsonString.data(using: .utf8) {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:String]
                    if let vmp = json {
                        variableNamesMap = vmp
                    }
                } catch {
                    print("Something went wrong")
                }
            }
            var variables:[String:[String]] = [:]
            variables["future"] = json["future"].rawValue as? [String]
            variables["past"] = json["past"].rawValue as? [String]
            variables["health"] = json["health"].rawValue as? [String]
            variables["valuation"] = json["valuation"].rawValue as? [String]
            variables["technical"] = json["technical"].rawValue as? [String]

            completionHandler(scoreSettings, variableNamesMap, variables)
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
            } else {
                self.networkDelegate?.networkError()
                completion(JSON())
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
            } else {
                self.networkDelegate?.networkError()
                completion(JSON())
            }
        }
    }
    
    private func saveTokenObjInKeychain(_ tokenObj: JSON) {
        if let idToken = tokenObj["idToken"].string, let refreshToken = tokenObj["refreshToken"].string {
            do {
                if let email = tokenObj["email"].string {
                    try KeychainItem(service: Bundle.main.bundleIdentifier!, account: "userEmail").saveItem(email)
                }
                try KeychainItem(service: Bundle.main.bundleIdentifier!, account: "userIdentifier").saveItem(idToken)
                try KeychainItem(service: Bundle.main.bundleIdentifier!, account: "refreshToken").saveItem(refreshToken)
            } catch {
                print("Unable to save userIdentifier to keychain.")
            }
        }
    }

}
