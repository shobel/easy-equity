//
//  IconItem.swift
//  stonks
//
//  Created by Samuel Hobel on 9/11/19.
//  Copyright © 2019 Samuel Hobel. All rights reserved.
//

import Foundation
import Parchment

struct IconItem: PagingItem, Hashable, Comparable {
    
    let icon: String
    let index: Int
    let image: UIImage?
    
    init(icon: String, index: Int) {
        self.icon = icon
        self.index = index
        self.image = UIImage(named: icon)
    }
    
//    var hashValue: Int {
//        return icon.hashValue
//    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(icon.hashValue)
    }
    
    static func <(lhs: IconItem, rhs: IconItem) -> Bool {
        return lhs.index < rhs.index
    }
    
    static func ==(lhs: IconItem, rhs: IconItem) -> Bool {
        return (
            lhs.index == rhs.index &&
                lhs.icon == rhs.icon
        )
    }
}
