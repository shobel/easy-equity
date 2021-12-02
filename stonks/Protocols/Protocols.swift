//
//  Protocols.swift
//  stonks
//
//  Created by Samuel Hobel on 3/23/21.
//  Copyright © 2021 Samuel Hobel. All rights reserved.
//

import Foundation

protocol LoadingProtocol {
    func loadingStarted()
    func loadingFinished()
}

protocol ShadowButtonDelegate {
    func creditBalanceUpdated()
    func shadowButtonTapped(_ premiumPackage:PremiumPackage?)
}

protocol NetworkDelegate {
    
    func networkError()
}

