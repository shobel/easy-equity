//
//  AnalystsRating.swift
//  stonks
//
//  Created by Samuel Hobel on 10/11/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import Foundation

struct AnalystsRating {
    
    var overallScore:Double {
        return (buyPercent + holdPercent*0.5)/10.0
    }
    var buyPercent:Double
    var holdPercent:Double
    var sellPercent:Double
    
    var targetPrice: Double
}
