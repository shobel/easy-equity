//
//  NetworkManager.swift
//  stonks
//
//  Created by Samuel Hobel on 7/17/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import Foundation

class NetworkManager {
    
    private static var myRestApi: MyRestAPI = MyRestAPI()
    
    public static func getMyRestApi() -> MyRestAPI {
        return NetworkManager.myRestApi
    }
    
    
}
