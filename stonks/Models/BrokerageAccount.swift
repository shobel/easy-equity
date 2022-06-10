//
//  BrokerageAccount.swift
//  stonks
//
//  Created by Samuel Hobel on 6/1/22.
//  Copyright © 2022 Samuel Hobel. All rights reserved.
//

import Foundation

import ObjectMapper

struct BrokerageAccount:Mappable {
    public var institutionName:String?
    public var institutionId:String?
    public var accountId:String?
    public var accountName:String?
    public var accountType:String?
    public var balance:AccountBalance?
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        institutionName <- map["institutionName"]
        institutionId <- map["institutionId"]
        accountId <- map["accountId"]
        accountName <- map["accountName"]
        accountType <- map["accountType"]
        balance <- map["balances"]
    }
    
    func asDictionary() -> [String: AnyObject] {
        return [
            "institutionName": institutionName as AnyObject,
            "institutionId": institutionId as AnyObject,
            "accountId": accountId as AnyObject,
            "accountName": accountName as AnyObject,
            "accountType": accountType as AnyObject,
            "balance": balance as AnyObject
        ]
    }
}
