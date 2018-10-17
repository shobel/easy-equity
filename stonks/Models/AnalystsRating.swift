//
//  AnalystsRating.swift
//  stonks
//
//  Created by Samuel Hobel on 10/11/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import Foundation

class AnalystsRating {
    
    var ratingCounts: [Constants.FinvizRatingCategory:Double] = [
        .buy: 0.0,
        .weakBuy: 0.0,
        .hold: 0.0,
        .weakSell: 0.0,
        .sell: 0.0
    ]
    
    var targetPrice:Double = 0.0
    var totalRatings:Double = 0.0
    
    public func addRating(_ text:String){
        let text = text.replacingOccurrences(of: "-", with: " ")
        if let rating = Constants.finvizKeywordsDict[text] {
            let oldCount = ratingCounts[rating]
            ratingCounts[rating] = oldCount! + 1
            totalRatings += 1
        }
    }
    
    var overallScore:Double {
        let score = (buyPercent + weakBuyPercent*0.75 + holdPercent*0.5 + weakSellPercent*0.25)*10
        return (score*10).rounded()/10
    }

    var buyPercent:Double {
        if totalRatings > 0 {
            return ratingCounts[.buy]! / totalRatings
        }
        return 0
    }
    
    var weakBuyPercent:Double {
        if totalRatings > 0 {
            return ratingCounts[.weakBuy]! / totalRatings
        }
        return 0
    }
    
    var holdPercent:Double {
        if totalRatings > 0 {
            return ratingCounts[.hold]! / totalRatings
        }
        return 0
    }
    
    var weakSellPercent: Double {
        if totalRatings > 0 {
            return ratingCounts[.weakSell]! / totalRatings
        }
        return 0
    }
    
    var sellPercent:Double {
        if totalRatings > 0 {
            return ratingCounts[.sell]! / totalRatings
        }
        return 0
    }
    
    init(){}
    
    init(buyCount: Double, weakBuyCount: Double, holdCount: Double, weakSellCount: Double, sellCount: Double, total: Double){
        ratingCounts = [
            .buy: buyCount,
            .weakBuy: weakBuyCount,
            .hold: holdCount,
            .weakSell: weakSellCount,
            .sell: sellCount
        ]
        totalRatings = total
    }
    
}
