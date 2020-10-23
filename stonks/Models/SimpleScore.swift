import Foundation
import ObjectMapper
struct SimpleScore: Mappable {
    
    public var symbol:String?
    public var companyName:String?
    public var rank:Int?
    public var industry:String?
    public var industryRank:Int?
    public var industryTotal:Int?
    public var percentile:Double?
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        symbol <- map["symbol"]
        companyName <- map["companyName"]
        rank <- map["rank"]
        industryRank <- map["industryRank"]
        industryTotal <- map["industryTotal"]
        industry <- map["industry"]
        percentile <- map["percentile"]
    }
}
