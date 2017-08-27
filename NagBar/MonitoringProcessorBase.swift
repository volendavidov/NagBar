//
//  MonitoringProcessorBase.swift
//  NagBar
//
//  Created by Volen Davidov on 29.01.17.
//  Copyright © 2017 Volen Davidov. All rights reserved.
//

import Foundation

class MonitoringProcessorBase {
    
    var monitoringInstance: MonitoringInstance?
    
    init(_ monitoringInstance: MonitoringInstance) {
        self.monitoringInstance = monitoringInstance
    }
}
