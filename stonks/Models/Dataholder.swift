//
//  Dataholder.swift
//  stonks
//
//  Created by Samuel Hobel on 9/30/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import Foundation

class Dataholder {
    
    public static var allTickers: [Company] = []
    public static var selectedCompany:Company?
    public static var watchlistManager: WatchlistManager = WatchlistManager()
    public static var userScoreSettings: ScoreSettings = ScoreSettings()
    
}
