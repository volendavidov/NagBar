//
//  CheckMKHTTPClient.swift
//  NagBar
//
//  Created by Volen Davidov on 03.07.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation
import PromiseKit

class CheckMKHTTPClient : MonitoringProcessorBase, HTTPClient {
    func get(_ url: String) -> Promise<Data> {
        
        return Promise{ seal in
            
            var promise: Promise<Void> = Promise<Void>.value(Void())
            
            promise = promise
                .then { _ -> Promise<Bool> in
                    // check if Check_MK is set to use basic auth or cookie auth
                    return self.checkBasicAuth(self.monitoringInstance!.url)
                }
                .then { basicAuth -> Promise<Bool> in
                    // if Check_MK is not using basic auth, then we have to log in
                    if !basicAuth {
                        if ConnectionManager.sharedInstance.cookies.cookies!.isEmpty {
                            // try to log in and return the result of the login
                            return self.login(self.monitoringInstance!)
                        } else {
                            return Promise<Bool>.value(true)
                        }
                    } else {
                        return Promise<Bool>.value(true)
                    }
                }
                .then { shouldProceed -> Promise<Data> in
                    // if the login was successfull, proceeed;
                    // otherwise reject the Promise with error for wrong password
                    if shouldProceed {
                        return self.getBasicAuth(url, monitoringInstance: self.monitoringInstance!)
                    } else {
                        return Promise<Data>.value(Data())
                    }
                }
                .done { data -> Void in
                    if data == Data() {
                        seal.reject(NSError(domain: "", code: -999, userInfo: nil))
                    } else {
                        seal.fulfill(data)
                    }
                }
        }
    }
    
    private func login(_ monitoringInstance: MonitoringInstance) -> Promise<Bool> {
        return Promise{ seal in
            
            let params = ["_username": monitoringInstance.username,
                "_password": monitoringInstance.password,
                "_login": "1"]
            
            ConnectionManager.sharedInstance.manager!.request(monitoringInstance.url + "login.py", method: .post, parameters: params).response { response in
                
                if response.error != nil {
                    seal.reject(response.error!)
                }
                
                var failed: Bool = true
                
                // if there are cookies, we check if one of them contains the domain for our monitoring instance
                for cookie in ConnectionManager.sharedInstance.cookies.cookies! {
                    
                    if monitoringInstance.url.range(of: cookie.domain) != nil {
                        failed = false
                    }
                }
                
                if failed == false {
                    seal.fulfill(true)
                } else {
                    seal.fulfill(false)
                }
            }

        }
    }
    
    private func checkBasicAuth(_ url: String) -> Promise<Bool> {
        
        return Promise{ seal in
            
            ConnectionManager.sharedInstance.manager!.request(url, method: .head).response { response in
                
                if response.error != nil {
                    seal.reject(response.error!)
                }
                
                // if the response is 401, then we have basic auth
                // otherwise we have cookie auth enabled
                if response.response!.statusCode == 401 {
                    seal.fulfill(true)
                } else {
                    seal.fulfill(false)
                }
            }
        }
    }
    
    func getBasicAuth(_ url: String, monitoringInstance: MonitoringInstance) -> Promise<Data> {
        
        return Promise{ seal in
            
            ConnectionManager.sharedInstance.manager!.request(url).authenticate(user: monitoringInstance.username, password: monitoringInstance.password).response { response in
                
                // if the response is 401, then we have basic auth
                // otherwise we have cookie auth enabled
                if response.response!.statusCode == 401 {
                    seal.fulfill(Data())
                }
                
                if response.error == nil {
                    seal.fulfill(response.data!)
                } else {
                    seal.reject(response.error!)
                }
            }
        }
    }
    
    // TODO: complete this
    func checkConnection() -> Promise<Bool> {
        return Promise{ seal in
            
            ConnectionManager.sharedInstance.manager!.request(self.monitoringInstance!.url).authenticate(user: self.monitoringInstance!.username, password: self.monitoringInstance!.password).response { response in
                
                seal.fulfill(true)
            }
        }
    }
    
    // TODO: implement Check_MK commands
    func post(_ url: String, postData: Dictionary<String, String>) -> Promise<Data> {
        return Promise { seal in
            seal.fulfill(Data())
        }
    }
}

