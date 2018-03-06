//
//  ConnectionManager.swift
//  NagBar
//
//  Created by Volen Davidov on 26.08.17.
//  Copyright © 2017 Volen Davidov. All rights reserved.
//

import Foundation
import Alamofire

/**
 * Custom connection manager that allows us to ignore invalid SSL certificates
 */
class ConnectionManager {
    
    static let sharedInstance = ConnectionManager()
    
    let cookies = HTTPCookieStorage.shared
    
    var manager: Alamofire.SessionManager?
    
    init() {
        self.setManager()
    }
    
    func update() {
        self.setManager()
    }
    
    private func setManager() {
        if Settings().boolForKey("acceptInvalidCertificates") {
            self.manager = self.defaultManagerIgnoreSSL()
        } else {
            self.manager = self.defaultManager()
        }
    }
    
    private func defaultConfiguration() -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        
        
        configuration.httpCookieStorage = cookies
        configuration.httpCookieAcceptPolicy = HTTPCookie.AcceptPolicy.always
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        
        return configuration
    }
    
    private func defaultManager() -> Alamofire.SessionManager {
        return Alamofire.SessionManager(
            configuration: self.defaultConfiguration()
        )
    }
    
    private func defaultManagerIgnoreSSL() -> Alamofire.SessionManager {
        var serverTrustPolicies: [String: ServerTrustPolicy] = [:]
        
        let monitoringInstances = MonitoringInstances().getAll()
        
        for (_,value) in monitoringInstances {
            guard let host = URL(string: value.url) else {
                continue
            }
            serverTrustPolicies[host.host!] = .disableEvaluation
        }
        
        return Alamofire.SessionManager(
            configuration: self.defaultConfiguration(),
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
    }
}
