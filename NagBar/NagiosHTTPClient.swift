//
//  NagiosHTTPClient.swift
//  NagBar
//
//  Created by Volen Davidov on 02.07.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation
import PromiseKit

class NagiosHTTPClient : MonitoringProcessorBase, HTTPClient {
    
    func get(_ url: String) -> Promise<Data> {
        
        return Promise{ fulfill, reject in
            
            ConnectionManager.sharedInstance.manager!.request(url).authenticate(user: self.monitoringInstance!.username, password: self.monitoringInstance!.password).response { response in
                
                if response.error == nil {
                    // if the response is 401, then we have basic auth
                    // otherwise we have cookie auth enabled
                    if response.response!.statusCode == 401 {
                        reject(NSError(domain: "", code: -999, userInfo: nil))
                    } else {
                        fulfill(response.data!)
                    }
                } else {
                    reject(response.error!)
                }
            }
        }
    }
    
    func checkConnection() -> Promise<Bool> {
        
        return Promise{ fulfill, reject in
            
            ConnectionManager.sharedInstance.manager!.request(self.monitoringInstance!.url, method: .head).authenticate(user: self.monitoringInstance!.username, password: self.monitoringInstance!.password).response { response in
                
                if response.error == nil {
                    // if the response is 401, then we have basic auth
                    // otherwise we have cookie auth enabled
                    if response.response!.statusCode == 401 {
                        fulfill(false)
                    } else {
                        fulfill(true)
                    }
                } else {
                    fulfill(false)
                }
            }
        }
    }
    
    func post(_ url: String, postData: Dictionary<String, String>) -> Promise<Data> {
        
        return Promise{ fulfill, reject in
            
            ConnectionManager.sharedInstance.manager!.request(url, method: .post, parameters: postData).authenticate(user: self.monitoringInstance!.username, password: self.monitoringInstance!.password).response { response in
                
                if response.error == nil {
                    // if the response is 401, then we have basic auth
                    // otherwise we have cookie auth enabled
                    if response.response!.statusCode == 401 {
                        reject(NSError(domain: "", code: -999, userInfo: nil))
                    } else {
                        fulfill(response.data!)
                    }
                } else {
                    reject(response.error!)
                }
            }
        }
    }
}
