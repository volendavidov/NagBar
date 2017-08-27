//
//  IcingaParserTests.swift
//  NagBar
//
//  Created by Volen Davidov on 11.02.17.
//  Copyright © 2017 Volen Davidov. All rights reserved.
//

import XCTest

class IcingaParserTests: XCTestCase {
    
    func testGetHostMonitoringItems() {
     let filePath = Bundle(for: type(of: self)).path(forResource: "IcingaHostStatus", ofType: "htm")
     XCTAssertNotNil(filePath)
     
     let data = try? Data(contentsOf: URL(fileURLWithPath: filePath!))
     
     let monitoringInstance = MonitoringInstance().initDefault(name: "test", url: "http://testmonitoring/icinga/cgi-bin/", type: .Icinga, username: "testuser", password: "testpass", enabled: 1)
     
     let parser = IcingaParser(monitoringInstance)
     
     let test = parser.parse(urlType: .hosts, data: data!)
     
     XCTAssertEqual(test.count, 3)
     
     XCTAssertEqual(test[0].monitoringInstance!.name, "test")
     XCTAssertEqual(test[0].host, "hplj2605dn")
     XCTAssertEqual(test[0].status, "DOWN")
     XCTAssertEqual(test[0].lastCheck, "02-11-2017 19:58:45")
     XCTAssertEqual(test[0].duration, "0d  0h 33m 25s")
     XCTAssertEqual(test[0].statusInformation, "CRITICAL - Network Unreachable (192.168.1.30)")
     XCTAssertEqual(test[0].itemUrl, "http://testmonitoring/icinga/cgi-bin/extinfo.cgi?type=1&host=hplj2605dn")
     }
    
    func testGetServiceMonitoringItems() {
        let filePath = Bundle(for: type(of: self)).path(forResource: "IcingaServiceStatus", ofType: "htm")
        XCTAssertNotNil(filePath)
        
        let data = try? Data(contentsOf: URL(fileURLWithPath: filePath!))
        
        let monitoringInstance = MonitoringInstance().initDefault(name: "test", url: "http://testmonitoring/icinga/cgi-bin/", type: .Icinga, username: "testuser", password: "testpass", enabled: 1)
        
        let parserServices = IcingaParser(monitoringInstance)
        
        let test = parserServices.parse(urlType: .services, data: data!) as! Array<ServiceMonitoringItem>
        
        XCTAssertEqual(test.count, 15)
        
        XCTAssertEqual(test[14].monitoringInstance!.name, "test")
        XCTAssertEqual(test[14].host, "localhost")
        XCTAssertEqual(test[14].status, "WARNING")
        XCTAssertEqual(test[14].service, "Total Processes")
        XCTAssertEqual(test[14].lastCheck, "02-11-2017 19:18:16")
        XCTAssertEqual(test[14].duration, "0d  0h  6m 50s")
        XCTAssertEqual(test[14].attempt, "4/4 ")
        XCTAssertEqual(test[14].statusInformation, "PROCS WARNING: 97 processes with STATE = RSZDT")
        XCTAssertEqual(test[14].itemUrl, "http://testmonitoring/icinga/cgi-bin/extinfo.cgi?type=2&host=localhost&service=Total+Processes")
    }
}
