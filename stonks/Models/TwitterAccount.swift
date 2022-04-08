//
//  TwitterAccount.swift
//  stonks
//
//  Created by Samuel Hobel on 4/3/22.
//  Copyright © 2022 Samuel Hobel. All rights reserved.
//


import Foundation
import ObjectMapper

struct TwitterAccount: Mappable {
    public var profile_image_url:String?// png
    public var name:String?// "Brian McGough",
    public var followers_count:Int?//
    public var following_count:Int?//
    public var tweet_count:Int?
    public var listed_count:Int?
    public var id:Int?//"143651355",
    public var username:String?// "HedgeyeRetail",
    public var description:String?
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        profile_image_url <- map["profile_image_url"]
        name <- map["name"]
        followers_count <- map["followers_count"]
        following_count <- map["following_count"]
        tweet_count <- map["tweet_count"]
        listed_count <- map["listed_count"]
        id <- map["id"]
        username <- map["username"]
        description <- map["description"]
    }
    
}
