//
//  CheckMKParserTests.swift
//  NagBar
//
//  Created by Volen Davidov on 16.07.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import XCTest

class CheckMKParserTests: XCTestCase {
    
    func testGetHostMonitoringItems() {
        let filePath = Bundle(for: type(of: self)).path(forResource: "Check_MKHostStatus", ofType: "")
        XCTAssertNotNil(filePath)
        
        let data = try? Data(contentsOf: URL(fileURLWithPath: filePath!))
        
        let monitoringInstance = MonitoringInstance().initDefault(name: "test", url: "http://testmonitoring/test/check_mk", type: .Check_MK, username: "testuser", password: "testpass", enabled: 1)
        
        let parser = CheckMKParser(monitoringInstance)
        
        let test = parser.parse(urlType: .hosts, data: data!)
        
        XCTAssertEqual(test.count, 18)
        
        XCTAssertEqual(test[0].monitoringInstance!.name, "test")
        XCTAssertEqual(test[0].host, "Bienenstock-Waage")
        XCTAssertEqual(test[0].status, "UP")
        XCTAssertEqual(test[0].lastCheck, "0 sec")
        XCTAssertEqual(test[0].duration, "2015-11-23 00:00:05")
        XCTAssertEqual(test[0].statusInformation, "Packet received via smart PING")
        XCTAssertEqual(test[0].itemUrl, "http://testmonitoring/test/check_mk/view.py?host=Bienenstock-Waage&site=test&view_name=host")
    }
    
    func testGetServiceMonitoringItems() {
        let filePath = Bundle(for: type(of: self)).path(forResource: "Check_MKServiceStatus", ofType: "")
        XCTAssertNotNil(filePath)
        
        let data = try? Data(contentsOf: URL(fileURLWithPath: filePath!))
        
        let monitoringInstance = MonitoringInstance().initDefault(name: "test", url: "http://testmonitoring/test/check_mk", type: .Check_MK, username: "testuser", password: "testpass", enabled: 1)
        
        let parserServices = CheckMKParser(monitoringInstance)
        
        let test = parserServices.parse(urlType: .services, data: data!) as! Array<ServiceMonitoringItem>
        
        XCTAssertEqual(test.count, 12)
        
        XCTAssertEqual(test[0].monitoringInstance!.name, "test")
        XCTAssertEqual(test[0].host, "google.de")
        XCTAssertEqual(test[0].service, "PING")
        XCTAssertEqual(test[0].status, "CRITICAL")
        XCTAssertEqual(test[0].lastCheck, "52 sec")
        XCTAssertEqual(test[0].attempt, "1/1")
        XCTAssertEqual(test[0].duration, "2016-04-05 03:41:27")
        XCTAssertEqual(test[0].statusInformation, "CRITICAL - 173.194.112.120: rta nan, lost 100%")
        XCTAssertEqual(test[0].itemUrl, "http://testmonitoring/test/check_mk/view.py?host=google.de&service=PING&site=test&view_name=service")
    }
}
