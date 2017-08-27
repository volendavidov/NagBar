//
//  DataRefreshActionTests.swift
//  NagBar
//
//  Created by Volen Davidov on 30.04.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation
import XCTest

class NotificationDisplayTests: XCTestCase {
    func testProcess() {
        let notificationDisplay = NotificationCenter.sharedInstance
        
        let serviceMonitoringItem1 = ServiceMonitoringItem()
        serviceMonitoringItem1.host = "testhost"
        serviceMonitoringItem1.service = "testservice1"
        serviceMonitoringItem1.status = "CRITICAL"
        serviceMonitoringItem1.duration = "351d 0h 15m 23s"
        serviceMonitoringItem1.lastCheck = "04-17-2016 17:27:02"
        serviceMonitoringItem1.statusInformation = "CRITICAL - Packet loss = 100% "
        serviceMonitoringItem1.itemUrl = "http://192.168.1.106/nagios/cgi-bin/extinfo.cgi?type=1&host=192.168.1.107"
        
        let serviceMonitoringItem2 = ServiceMonitoringItem()
        serviceMonitoringItem2.host = "testhost"
        serviceMonitoringItem2.service = "testservice2"
        serviceMonitoringItem2.status = "CRITICAL"
        serviceMonitoringItem2.duration = "351d 0h 15m 23s"
        serviceMonitoringItem2.lastCheck = "04-17-2016 17:27:02"
        serviceMonitoringItem2.statusInformation = "CRITICAL - Packet loss = 100% "
        serviceMonitoringItem2.itemUrl = "http://192.168.1.106/nagios/cgi-bin/extinfo.cgi?type=1&host=192.168.1.107"
        
        let serviceMonitoringItem3 = ServiceMonitoringItem()
        serviceMonitoringItem3.host = "testhost"
        serviceMonitoringItem3.service = "testservice1"
        serviceMonitoringItem3.status = "WARNING"
        serviceMonitoringItem3.duration = "351d 0h 15m 23s"
        serviceMonitoringItem3.lastCheck = "04-17-2016 17:27:02"
        serviceMonitoringItem3.statusInformation = "CRITICAL - Packet loss = 100% "
        serviceMonitoringItem3.itemUrl = "http://192.168.1.106/nagios/cgi-bin/extinfo.cgi?type=1&host=192.168.1.107"
        
        notificationDisplay.process([serviceMonitoringItem1], newResults: [serviceMonitoringItem1, serviceMonitoringItem2])
        
    }
}
