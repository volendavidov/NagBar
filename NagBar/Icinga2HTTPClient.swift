//
//  Icinga2HTTPClient.swift
//  NagBar
//
//  Created by Volen Davidov on 06.08.17.
//  Copyright © 2017 Volen Davidov. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire

class Icinga2HTTPClient : NagiosHTTPClient {

    override func post(_ url: String, postData: Dictionary<String, String>) -> Promise<Data> {
        
        let headers: HTTPHeaders = [
            "Accept": "application/json"
        ]
        
        return Promise{ seal in
            
            ConnectionManager.sharedInstance.manager!.request(url, method: .post, parameters: postData, encoding: JSONEncoding.default, headers: headers).authenticate(user: self.monitoringInstance!.username, password: self.monitoringInstance!.password).response { response in
                
                if response.error == nil {
                    // if the response is 401, then we have basic auth
                    // otherwise we have cookie auth enabled
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
