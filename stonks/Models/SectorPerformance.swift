//
//  SectorPerformance.swift
//  stonks
//
//  Created by Samuel Hobel on 11/24/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import Foundation

struct SectorPerformance {
    public var name:String?
    public var performance:Double?
    init(name:String, performance:Double){
        self.name = name
        self.performance = performance
    }
}
