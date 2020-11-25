//
//  EconomyWeekly.swift
//  stonks
//
//  Created by Samuel Hobel on 11/24/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper
struct EconomyWeekly: Mappable {
    
    private var initialClaims:Int? // 770244,
    private var date:String? // "2020-11-15",
    private var retailMoneyFunds:Int? // 1131,
    private var institutionalMoneyFunds:Double? //2916.1
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        initialClaims <- map["initialClaims"]
        date <- map["id"]
        retailMoneyFunds <- map["retailMoneyFunds"]
        institutionalMoneyFunds <- map["institutionalMoneyFunds"]
    }
}
