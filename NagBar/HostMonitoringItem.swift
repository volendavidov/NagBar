//
//  MonitoringItem.swift
//  NagBar
//
//  Created by Volen Davidov on 10/25/15.
//  Copyright © 2015 Volen Davidov. All rights reserved.
//

import Foundation

enum MonitoringItemType {
    case host
    case service
}

class MonitoringItem {
    
    var host: String = ""
    var status: String = ""
    var lastCheck: String = ""
    var duration: String = ""
    var statusInformation: String = ""
    var monitoringInstance: MonitoringInstance?
    var itemUrl: String = ""
    var service: String = ""
    var attempt: String = ""
    var monitoringItemType: MonitoringItemType = .host
    
    func uniqueIdentifier() -> String {
        return self.host + ":" + self.service + ":" + self.status
    }
}

class HostMonitoringItem : MonitoringItem{
    
    override init() {
        super.init()
        self.monitoringItemType = .host
    }
    
    override var service: String {
        get {
            return ""
        }
        set {
        }
    }
    
    override var attempt: String {
        get {
            return ""
        }
        set {
        }
    }
    
    override func uniqueIdentifier() -> String {
        return self.host + ":" + self.status
    }
}
