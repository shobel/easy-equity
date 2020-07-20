//
//  MyRestAPI.swift
//  stonks
//
//  Created by Samuel Hobel on 7/16/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import Foundation
import SwiftyJSON
import ObjectMapper
import Firebase

class MyRestAPI: HTTPRequest {
    
    private var apiurl = "http://localhost:3000/api"
    private var userEndpoint = "/user"
    private var token:String = ""
    
    public override init(){
        super.init()
    }
    
    public func setToken(token:String) {
        self.token = token
    }

    public func createUser(id:String, email:String, completionHandler: @escaping (JSON)->Void){
        let body = [
            "userid": id,
            "email": email
        ]
        let queryURL = buildQuery(url: apiurl + userEndpoint + "/create", params: [:])
        self.postRequest(queryURL: queryURL, body: body) { (data) in
            completionHandler(data)
        }
    }
    
    public func addToWatchlist(symbol:String, completionHandler: @escaping (JSON)->Void){
        let queryURL = buildQuery(url: apiurl + userEndpoint + "/watchlist/add/" + symbol, params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            completionHandler(data)
        }
    }
    
    public func removeFromWatchlist(symbol:String, completionHandler: @escaping (JSON)->Void){
        let queryURL = buildQuery(url: apiurl + userEndpoint + "/watchlist/remove/" + symbol, params: [:])
        self.getRequest(queryURL: queryURL) { (data) in
            completionHandler(data)
        }
    }
    
    private func getRequest(queryURL:String, completion: @escaping (JSON) -> Void) {
        httpGetQuery(queryURL: queryURL, token: self.token) { (data, response, error) -> Void in
            if let httpResponse = response as? HTTPURLResponse {
                //if token is invalid, get a new token
                if httpResponse.statusCode == 401 || httpResponse.statusCode == 400 {
                    Auth.auth().currentUser?.getIDToken() { (token, authError) in
                        if authError == nil && token != nil {
                            self.token = token!
                            //resend query
                            self.httpGetQuery(queryURL: queryURL, token: self.token) { (data2, response2, error2) -> Void in
                                if let httpResponse2 = response2 as? HTTPURLResponse {
                                    if httpResponse2.statusCode == 200 {
                                        completion(JSON(data2!))
                                    }
                                }
                            }
                        }
                    }
                } else if error == nil && data !=  nil {
                    completion(JSON(data!))
                }
            }
        }
    }
    
    private func postRequest(queryURL:String, body:[String:Any], completion: @escaping (JSON) -> Void) {
        httpPostQuery(queryURL: queryURL, token: self.token, body: body) { (data, response, error) -> Void in
            if let httpResponse = response as? HTTPURLResponse {
                //if token is invalid, get a new token
                if httpResponse.statusCode == 401 || httpResponse.statusCode == 400 {
                    Auth.auth().currentUser?.getIDToken() { (token, authError) in
                        if authError == nil && token != nil {
                            self.token = token!
                            //resend query
                            self.httpPostQuery(queryURL: queryURL, token: self.token, body: body) { (data2, response2, error2) -> Void in
                                if let httpResponse2 = response2 as? HTTPURLResponse {
                                    if httpResponse2.statusCode == 200 {
                                        completion(JSON(data!))
                                    }
                                }
                            }
                        }
                    }
                } else if error == nil && data !=  nil {
                    completion(JSON(data!))
                }
            }
        }
    }
    

}
