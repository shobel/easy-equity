//
//  FinvizAPI.swift
//  stonks
//
//  Created by Samuel Hobel on 10/13/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import Foundation
import SwiftSoup

class FinvizAPI: HTTPRequest {
    
    private var baseURL = "https://finviz.com/quote.ashx?t="
    private var statTableKeys = ["Forward P/E", "PEG", "RSI (14)", "Target Price", "Earnings"]
    
    /* web screhppin */
    public func getData(forTickers: [String], completionHandler: @escaping ([String:[String:Any?]])->Void) {
        //let dict = randomRatings(forTickers: forTickers)
        for t in forTickers {
            let query = baseURL + t
            sendQuery(queryURL: query, completionHandler: { (data, response, error) in
                let htmlResponseString = String(data: data!, encoding: .utf8)
                do {
                    let doc: Document = try SwiftSoup.parse(htmlResponseString!)
                    var stats = self.getKeyStats(doc: doc)
                    let rating = self.getRatings(doc: doc)
                    
                    if let tp = stats["Target Price"] {
                        rating.targetPrice = Double(tp) ?? 0.0
                    }
                    var tickerDict: [String:Any?] = [:]
                    tickerDict.merge(stats) { (current, _) in current }
                    tickerDict.merge(["ratings": rating]) { (current, _) in current }
                    completionHandler([t: tickerDict])
                } catch Exception.Error(_, let message) {
                    print(message)
                } catch {
                    print("error")
                }
            })
        }
    }
    
    private func getKeyStats(doc:Document) -> [String:String] {
        var dict:[String:String] = [:]
        do {
            let tableBody: Element = try doc.getElementsByClass("snapshot-table2").first()!.children().first()!
            let rows: Elements = tableBody.children()
            for row in rows {
                let cells = row.children()
                for cell in cells {
                    let key = try cell.text()
                    if statTableKeys.contains(key){
                        let value = try (cell.nextElementSibling()?.text())!
                        dict[key] = value
                        //print(value)
                    }
                }
            }
        } catch Exception.Error(_, let message){
            print(message)
        } catch {
            print(error)
        }
        return dict
    }
    
    private func getRatings(doc:Document) -> AnalystsRating {
        let analystRating = AnalystsRating()
        do {
            let table:Elements = try doc.getElementsByClass("fullview-ratings-outer")
            if let tableBody:Element = table.first()?.children().first() {
                let rows: Elements = tableBody.children()
                for row in rows {
                    let cells = row.child(0).child(0).child(0).child(0).children()
                    for cell in cells {
                        var ratingText = try cell.text()
                        if ratingText.contains("→") {
                            ratingText = ratingText.components(separatedBy: "→")[1].trimmingCharacters(in: .whitespaces)
                        }
                        analystRating.addRating(ratingText)
                    }
                }
            }
        } catch Exception.Error(_, let message){
            print(message)
        } catch {
            print(error)
        }
        return analystRating
    }
    
    private func randomRatings(forTickers: [String]) -> [String:AnalystsRating] {
        var dict:[String:AnalystsRating] = [:]
        for c in forTickers {
            let buyCount = Double.random(in: 0.0...100)
            let weakBuyCount = Double.random(in: 0.0...(100 - buyCount))
            let holdCount = Double.random(in: 0.0...(100 - buyCount - weakBuyCount))
            let weakSellCount = Double.random(in: 0.0...(100 - buyCount - weakBuyCount - holdCount))
            let sellCount = Double.random(in: 0.0...(100 - buyCount - weakBuyCount - holdCount - weakSellCount))
            let targetPrice = Double.random(in: 0.0...2500)
            let rating: AnalystsRating = AnalystsRating(buyCount: buyCount, weakBuyCount: weakBuyCount, holdCount: holdCount, weakSellCount: weakSellCount, sellCount: sellCount, total: 100)
            rating.targetPrice = targetPrice
            dict[c] = rating
        }
        return dict
    }
}
