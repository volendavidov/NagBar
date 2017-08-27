//
//  DataProcessorTests.swift
//  NagBar
//
//  Created by Volen Davidov on 17.04.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import XCTest
import RealmSwift

class AdditionProcessorTests: XCTestCase {
    
    func testProcess() {
        let monitoringInstance = MonitoringInstance().initDefault(name: "test", url: "test", type: .Nagios, username: "test", password: "test", enabled: 1)
        let hostMonitoringItem1 = HostMonitoringItem()
        hostMonitoringItem1.monitoringInstance = monitoringInstance
        hostMonitoringItem1.host = "host1"
        hostMonitoringItem1.status = "DOWN"
        hostMonitoringItem1.duration = "351d 0h 15m 23s"
        hostMonitoringItem1.lastCheck = "04-17-2016 17:27:02"
        hostMonitoringItem1.statusInformation = "PING CRITICAL - Packet loss = 100% "
        hostMonitoringItem1.itemUrl = "http://192.168.1.106/nagios/cgi-bin/extinfo.cgi?type=1&host=192.168.1.107"
        
        let hostMonitoringItem2 = HostMonitoringItem()
        hostMonitoringItem2.monitoringInstance = monitoringInstance
        hostMonitoringItem2.host = "host2"
        hostMonitoringItem2.status = "UP"
        hostMonitoringItem2.duration = "351d 0h 15m 23s"
        hostMonitoringItem2.lastCheck = "04-17-2016 17:27:02"
        hostMonitoringItem2.statusInformation = "PING CRITICAL - Packet loss = 100% "
        hostMonitoringItem2.itemUrl = "http://192.168.1.106/nagios/cgi-bin/extinfo.cgi?type=1&host=192.168.1.107"
        
        let currentItems: Array<HostMonitoringItem> = [hostMonitoringItem2]
        let allItems: Array<HostMonitoringItem> = [hostMonitoringItem1]
        let urlType: MonitoringURLType = .hosts
        
        let processorRequest = ProcessorRequest(currentItems: currentItems, allItems: allItems, urlType: urlType)
        
        let additionProcessor = AdditionProcessor()
        additionProcessor.process(processorRequest)
        let results = additionProcessor.get()
        
        XCTAssertEqual(results.count, 2)
        XCTAssertTrue(results[0] === hostMonitoringItem1)
        XCTAssertTrue(results[1] === hostMonitoringItem2)
    }
}

class FilterScheduledDowntimeProcessorTests: XCTestCase {
    func testProcess() {
        let monitoringInstance = MonitoringInstance().initDefault(name: "test", url: "test", type: .Nagios, username: "test", password: "test", enabled: 1)
        let hostMonitoringItem1 = ServiceMonitoringItem()
        hostMonitoringItem1.monitoringInstance = monitoringInstance
        hostMonitoringItem1.host = "host1"
        hostMonitoringItem1.status = "UP"
        hostMonitoringItem1.duration = "351d 0h 15m 23s"
        hostMonitoringItem1.lastCheck = "04-17-2016 17:27:02"
        hostMonitoringItem1.statusInformation = "PING OK - Packet loss = 0%, RTA = 0.31 ms"
        hostMonitoringItem1.itemUrl = "http://192.168.1.106/nagios/cgi-bin/extinfo.cgi?type=1&host=192.168.1.107"
        
        let serviceMonitoringItem1 = ServiceMonitoringItem()
        serviceMonitoringItem1.monitoringInstance = monitoringInstance
        serviceMonitoringItem1.host = "host1"
        serviceMonitoringItem1.service = "test service"
        serviceMonitoringItem1.status = "CRITICAL"
        serviceMonitoringItem1.duration = "351d 0h 15m 23s"
        serviceMonitoringItem1.lastCheck = "04-17-2016 17:27:02"
        serviceMonitoringItem1.statusInformation = "CRITICAL - Packet loss = 100% "
        serviceMonitoringItem1.itemUrl = "http://192.168.1.106/nagios/cgi-bin/extinfo.cgi?type=1&host=192.168.1.107"
        
        let serviceMonitoringItem2 = ServiceMonitoringItem()
        serviceMonitoringItem2.monitoringInstance = monitoringInstance
        serviceMonitoringItem2.host = "host2"
        serviceMonitoringItem2.service = "test service2"
        serviceMonitoringItem2.status = "CRITICAL"
        serviceMonitoringItem2.duration = "351d 0h 15m 23s"
        serviceMonitoringItem2.lastCheck = "04-17-2016 17:27:02"
        serviceMonitoringItem2.statusInformation = "CRITICAL - Packet loss = 100% "
        serviceMonitoringItem2.itemUrl = "http://192.168.1.106/nagios/cgi-bin/extinfo.cgi?type=1&host=192.168.1.107"
        
        let currentItems: Array<MonitoringItem> = [hostMonitoringItem1]
        let allItems: Array<MonitoringItem> = [serviceMonitoringItem1, serviceMonitoringItem2]
        var urlType: MonitoringURLType = .hostScheduledDowntime
        
        var processorRequest = ProcessorRequest(currentItems: currentItems, allItems: allItems, urlType: urlType)
        
        var filterDowntimeProcessor = FilterScheduledDowntimeProcessor()
        filterDowntimeProcessor.process(processorRequest)
        var results = filterDowntimeProcessor.get()
        
        XCTAssertEqual(results.count, 1)
        XCTAssertTrue(results[0] === serviceMonitoringItem2)
        
        
        urlType = .hosts
        processorRequest = ProcessorRequest(currentItems: currentItems, allItems: allItems, urlType: urlType)
        filterDowntimeProcessor = FilterScheduledDowntimeProcessor()
        filterDowntimeProcessor.process(processorRequest)
        results = filterDowntimeProcessor.get()
        
        XCTAssertEqual(results.count, 2)
        XCTAssertTrue(results[0] === serviceMonitoringItem1)
        XCTAssertTrue(results[1] === serviceMonitoringItem2)
        
        
        urlType = .services
        processorRequest = ProcessorRequest(currentItems: currentItems, allItems: allItems, urlType: urlType)
        filterDowntimeProcessor = FilterScheduledDowntimeProcessor()
        filterDowntimeProcessor.process(processorRequest)
        results = filterDowntimeProcessor.get()
        
        XCTAssertEqual(results.count, 2)
        XCTAssertTrue(results[0] === serviceMonitoringItem1)
        XCTAssertTrue(results[1] === serviceMonitoringItem2)
    }
}

class FilterItemsProcessorTests: XCTestCase {
    
    override func setUp() {
        
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        
        let filterItem = FilterItem()
        filterItem.host = "testhost"
        filterItem.service = "testservice1"
        filterItem.status = 24
        
        let realm = try! Realm()
        
        try! realm.write {
            realm.add(filterItem)
        }
    }
    
    func testProcess() {
        
        let monitoringInstance = MonitoringInstance().initDefault(name: "test", url: "test", type: .Nagios, username: "test", password: "test", enabled: 1)
        
        let serviceMonitoringItem1 = ServiceMonitoringItem()
        serviceMonitoringItem1.monitoringInstance = monitoringInstance
        serviceMonitoringItem1.host = "testhost"
        serviceMonitoringItem1.service = "testservice1"
        serviceMonitoringItem1.status = "CRITICAL"
        serviceMonitoringItem1.duration = "351d 0h 15m 23s"
        serviceMonitoringItem1.lastCheck = "04-17-2016 17:27:02"
        serviceMonitoringItem1.statusInformation = "CRITICAL - Packet loss = 100% "
        serviceMonitoringItem1.itemUrl = "http://192.168.1.106/nagios/cgi-bin/extinfo.cgi?type=1&host=192.168.1.107"
        
        let serviceMonitoringItem2 = ServiceMonitoringItem()
        serviceMonitoringItem2.monitoringInstance = monitoringInstance
        serviceMonitoringItem2.host = "testhost"
        serviceMonitoringItem2.service = "testservice2"
        serviceMonitoringItem2.status = "CRITICAL"
        serviceMonitoringItem2.duration = "351d 0h 15m 23s"
        serviceMonitoringItem2.lastCheck = "04-17-2016 17:27:02"
        serviceMonitoringItem2.statusInformation = "CRITICAL - Packet loss = 100% "
        serviceMonitoringItem2.itemUrl = "http://192.168.1.106/nagios/cgi-bin/extinfo.cgi?type=1&host=192.168.1.107"
        
        let serviceMonitoringItem3 = ServiceMonitoringItem()
        serviceMonitoringItem3.monitoringInstance = monitoringInstance
        serviceMonitoringItem3.host = "testhost"
        serviceMonitoringItem3.service = "testservice1"
        serviceMonitoringItem3.status = "WARNING"
        serviceMonitoringItem3.duration = "351d 0h 15m 23s"
        serviceMonitoringItem3.lastCheck = "04-17-2016 17:27:02"
        serviceMonitoringItem3.statusInformation = "CRITICAL - Packet loss = 100% "
        serviceMonitoringItem3.itemUrl = "http://192.168.1.106/nagios/cgi-bin/extinfo.cgi?type=1&host=192.168.1.107"
        
        let currentItems: Array<MonitoringItem> = [serviceMonitoringItem1, serviceMonitoringItem2, serviceMonitoringItem3]
        let urlType: MonitoringURLType = .hostScheduledDowntime
        let allItems: Array<MonitoringItem> = [serviceMonitoringItem1, serviceMonitoringItem2, serviceMonitoringItem3]
        
        let processorRequest = ProcessorRequest(currentItems: currentItems, allItems: allItems, urlType: urlType)
        
        let filterItemsProcessor = FilterItemsProcessor()
        filterItemsProcessor.process(processorRequest)
        var results = filterItemsProcessor.get()
        
        XCTAssertEqual(results.count, 2)
        XCTAssertTrue(results[0] === serviceMonitoringItem2)
        XCTAssertTrue(results[1] === serviceMonitoringItem3)
    }
}
