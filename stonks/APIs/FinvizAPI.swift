//
//  FinvizAPI.swift
//  stonks
//
//  Created by Samuel Hobel on 10/13/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import Foundation

class FinvizAPI: HTTPRequest {
    
    private var baseURL = "https://finviz.com/quote.ashx?t="
    
    public func getAnalystsRatings(forTickers: [String], completionHandler: @escaping ([String:AnalystsRating])->Void) {
        //let dict = randomRatings(forTickers: forTickers)
        for t in forTickers{
            let query = baseURL + t
            sendQuery(queryURL: query, completionHandler: { (data, response, error) in
                let responseString = String(data: data!, encoding: .utf8)
                print(responseString)
            })
        }
        //completionHandler(dict)
    }
    
    private func randomRatings(forTickers: [String]) -> [String:AnalystsRating] {
        var dict:[String:AnalystsRating] = [:]
        for c in forTickers {
            let buyRating = Double.random(in: 0.0...1.0)
            let holdRating = Double.random(in: 0.0...(1.0 - buyRating))
            let sellRating = Double.random(in: 0.0...(1.0 - buyRating - holdRating))
            let targetPrice = Double.random(in: 0.0...2500)
            let rating: AnalystsRating = AnalystsRating(buyPercent: buyRating, holdPercent: holdRating, sellPercent: sellRating, targetPrice: targetPrice)
            dict[c] = rating
        }
        return dict
    }
}
