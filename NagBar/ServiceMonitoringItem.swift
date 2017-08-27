//
//  ServiceMonitoringItem.swift
//  NagBar
//
//  Created by Volen Davidov on 10/25/15.
//  Copyright © 2015 Volen Davidov. All rights reserved.
//

import Foundation

class ServiceMonitoringItem: MonitoringItem {
    
    override init() {
        super.init()
        self.monitoringItemType = .service
    }
    
    override func uniqueIdentifier() -> String {
        return self.host + ":" + self.service + ":" + self.status
    }
}
