//
//  NagiosParserTests.swift
//  NagBar
//
//  Created by Volen Davidov on 03.01.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import XCTest

class NagiosParserTests: XCTestCase {
    
    func testGetHostMonitoringItems() {
        let filePath = Bundle(for: type(of: self)).path(forResource: "NagiosHostStatus", ofType: "html")
        XCTAssertNotNil(filePath)
        
        let data = try? Data(contentsOf: URL(fileURLWithPath: filePath!))
        
        let monitoringInstance = MonitoringInstance().initDefault(name: "test", url: "http://testmonitoring/nagios/cgi-bin/", type: .Nagios, username: "testuser", password: "testpass", enabled: 1)
        
        let parser = NagiosParser(monitoringInstance)
        
        let test = parser.parse(urlType: .hosts, data: data!)
        
        XCTAssertEqual(test.count, 48)
        
        XCTAssertEqual(test[0].monitoringInstance!.name, "test")
        XCTAssertEqual(test[0].host, "Firewall")
        XCTAssertEqual(test[0].status, "UP")
        XCTAssertEqual(test[0].lastCheck, "01-03-2016 19:16:38")
        XCTAssertEqual(test[0].duration, " 0d  0h 19m 36s+")
        XCTAssertEqual(test[0].statusInformation, "OK - 127.0.0.1: rta 0.025ms, lost 0% ")
        XCTAssertEqual(test[0].itemUrl, "http://testmonitoring/nagios/cgi-bin/extinfo.cgi?type=1&host=Firewall")
    }
    
    func testGetServiceMonitoringItems() {
        let filePath = Bundle(for: type(of: self)).path(forResource: "NagiosServiceStatus", ofType: "html")
        XCTAssertNotNil(filePath)
        
        let data = try? Data(contentsOf: URL(fileURLWithPath: filePath!))
        
        let monitoringInstance = MonitoringInstance().initDefault(name: "test", url: "http://testmonitoring/nagios/cgi-bin/", type: .Nagios, username: "testuser", password: "testpass", enabled: 1)
        
        let parserServices = NagiosParser(monitoringInstance)
        
        let test = parserServices.parse(urlType: .services, data: data!) as! Array<ServiceMonitoringItem>
        
        XCTAssertEqual(test.count, 100)
        
        XCTAssertEqual(test[0].monitoringInstance!.name, "test")
        XCTAssertEqual(test[0].host, "Log-Server.nagios.local")
        XCTAssertEqual(test[0].status, "OK")
        XCTAssertEqual(test[0].service, "/ Disk Usage")
        XCTAssertEqual(test[0].lastCheck, "12-04-2015 16:09:40")
        XCTAssertEqual(test[0].duration, "173d 15h 13m 53s")
        XCTAssertEqual(test[0].attempt, "1/1")
        XCTAssertEqual(test[0].statusInformation, "DISK OK - free space: / 4353 MB (26% inode=91%): ")
        XCTAssertEqual(test[0].itemUrl, "http://testmonitoring/nagios/cgi-bin/extinfo.cgi?type=2&host=Log-Server.nagios.local&service=%2F+Disk+Usage")
    }
}
