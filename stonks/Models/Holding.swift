//
//  BrokerageAccount.swift
//  stonks
//
//  Created by Samuel Hobel on 6/1/22.
//  Copyright © 2022 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper

struct Holding:Mappable {
    public var account_id:String?// "qnRgN1RqDJUdpmpkZRzAsZ6Bbd6yBLt55O74kZ"
    public var close_price:Double?// 23.18
    public var close_price_as_of:String?//  "2022-05-31"
    public var cost_basis:Double?// 2235.77
    public var institution_price:Double?// 23.18
    public var institution_price_as_of:String?//  "2022-05-31"
    public var institution_value:Double?// 2318
    public var iso_currency_code:String?//  "USD"
    public var name:String?//  "Cliffs Natural Resources Inc."
    public var quantity:Double?// 100
    public var security_id:String?//  "0AZ0De04KqsreD7QDLAoS1VgMBgJXzsMBERPV"
    public var symbol:String?//  "CLF"
    public var unofficial_currency_code:String?//  null
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        account_id <- map["account_id"]
        close_price <- map["close_price"]
        close_price_as_of <- map["close_price_as_of"]
        cost_basis <- map["cost_basis"]
        institution_price <- map["institution_price"]
        institution_price_as_of <- map["institution_price_as_of"]
        institution_value <- map["institution_value"]
        iso_currency_code <- map["iso_currency_code"]
        name <- map["name"]
        quantity <- map["quantity"]
        security_id <- map["security_id"]
        symbol <- map["symbol"]
        unofficial_currency_code <- map["unofficial_currency_code"]
    }
    
}
