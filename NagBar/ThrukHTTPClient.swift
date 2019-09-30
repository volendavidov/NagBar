//
//  ThrukHTTPClient.swift
//  NagBar
//
//  Created by Volen Davidov on 28.09.19.
//  Copyright © 2019 Volen Davidov. All rights reserved.
//

//  Thruk uses cookie authentication by default. We can force
//  basic auth as well but we have to send the Authorization header
//  before receiving a challenge. The .authenticate() method in
//  Alamofire does not do this, so we use a workaround - manually sending
//  the Authorization header (https://github.com/Alamofire/Alamofire/issues/32).
//  Also, we have to fake the user agent as curl for this to work.

import Alamofire
import Foundation
import PromiseKit

class ThrukHTTPClient : MonitoringProcessorBase, HTTPClient {
    
    func get(_ url: String) -> Promise<Data> {
        
        return Promise{ seal in
           
            let authTuple: (key: String, value: String)? = Request.authorizationHeader(user: self.monitoringInstance!.username, password: self.monitoringInstance!.password)
            let userAgent: (key: String, value: String)? = ("User-agent", "curl")

            ConnectionManager.sharedInstance.manager!.request(url, method: .get, parameters: nil, encoding: Alamofire.JSONEncoding.default, headers: [authTuple!.key : authTuple!.value, userAgent!.key : userAgent!.value]).response { response in

                if response.error == nil {
                    if response.response!.statusCode == 401 {
                        seal.reject(NSError(domain: "", code: -999, userInfo: nil))
                    } else {
                        seal.fulfill(response.data!)
                    }
                } else {
                    seal.reject(response.error!)
                }
            }
        }
    }
    
    func checkConnection() -> Promise<Bool> {
        
        return Promise{ seal in
            
            let authTuple: (key: String, value: String)? = Request.authorizationHeader(user: self.monitoringInstance!.username, password: self.monitoringInstance!.password)
            let userAgent: (key: String, value: String)? = ("User-agent", "curl")
            
            ConnectionManager.sharedInstance.manager!.request(self.monitoringInstance!.url, method: .get, parameters: nil, encoding: Alamofire.JSONEncoding.default, headers: [authTuple!.key : authTuple!.value, userAgent!.key : userAgent!.value]).response { response in
                
                if response.error == nil {
                    if response.response!.statusCode == 401 {
                        seal.fulfill(false)
                    } else {
                        seal.fulfill(true)
                    }
                } else {
                    seal.fulfill(false)
                }
            }
        }
    }
    
    func post(_ url: String, postData: Dictionary<String, String>) -> Promise<Data> {
        
        return Promise{ seal in
            
            let authTuple: (key: String, value: String)? = Request.authorizationHeader(user: self.monitoringInstance!.username, password: self.monitoringInstance!.password)
            let userAgent: (key: String, value: String)? = ("User-agent", "curl")
            
            ConnectionManager.sharedInstance.manager!.request(url, method: .post, parameters: postData, encoding: Alamofire.URLEncoding.default, headers: [authTuple!.key : authTuple!.value, userAgent!.key : userAgent!.value]).response { response in

                if response.error == nil {
                    if response.response!.statusCode == 401 {
                        seal.reject(NSError(domain: "", code: -999, userInfo: nil))
                    } else {
                        seal.fulfill(response.data!)
                    }
                } else {
                    seal.reject(response.error!)
                }
            }
        }
    }
}
