//
//  HTTPRequest.swift
//  stonks
//
//  Created by Samuel Hobel on 10/14/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import Foundation

class HTTPRequest {
    
    /* Takes query URL, sends HTTPRequest and calls completionHandler with the results */
    func sendQuery(queryURL: String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void){
        let sharedSession = URLSession.shared
        
        if let url = URL(string: queryURL) {
            let request = URLRequest(url: url)
            let dataTask = sharedSession.dataTask(with: request, completionHandler: completionHandler)
            dataTask.resume()
        }
    }
    
    func httpGetQuery(queryURL: String, token: String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void){
        let sharedSession = URLSession.shared
        
        if let url = URL(string: queryURL) {
            var request = URLRequest(url: url)
            request.addValue("\(token)", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let dataTask = sharedSession.dataTask(with: request, completionHandler: completionHandler)
            dataTask.resume()
        }
    }
    
    func httpPostQuery(queryURL: String, token: String, body: [String:Any], completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void){
        let sharedSession = URLSession.shared

        if let url = URL(string: queryURL) {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
            request.addValue("\(token)", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let dataTask = sharedSession.dataTask(with: request, completionHandler: completionHandler)
            dataTask.resume()
        }
    }
    
    /* Takes the base URL and a dict of params. Will build the query by appending the params in the form key=value to the base url */
    func buildQuery(url: String, params: [String:String]) -> String {
        var paramString = ""
        var counter = 0
        for (key, value) in params {
            if counter == 0 {
                paramString += "?" + key + "=" + value
            } else {
                paramString += "&" + key + "=" + value
            }
            counter+=1
        }
        return url + paramString
    }
}
