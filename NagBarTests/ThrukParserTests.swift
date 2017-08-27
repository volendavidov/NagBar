//
//  ThrukParserTests.swift
//  NagBar
//
//  Created by Volen Davidov on 02.07.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import XCTest

class ThrukParserTests: XCTestCase {
    
    func testGetHostMonitoringItems() {
        let filePath = Bundle(for: type(of: self)).path(forResource: "ThrukHostStatus", ofType: "")
        XCTAssertNotNil(filePath)
        
        let data = try? Data(contentsOf: URL(fileURLWithPath: filePath!))
        
        let monitoringInstance = MonitoringInstance().initDefault(name: "test", url: "http://testmonitoring/cgi-bin/", type: .Nagios, username: "testuser", password: "testpass", enabled: 1)
        
        let parser = ThrukParser(monitoringInstance)
        
        let test = parser.parse(urlType: .hosts, data: data!)
        
        XCTAssertEqual(test.count, 3)
        
        XCTAssertEqual(test[0].monitoringInstance!.name, "test")
        XCTAssertEqual(test[0].host, "linksys-srw224p")
        XCTAssertEqual(test[0].status, "UNREACHABLE")
        XCTAssertEqual(test[0].lastCheck, "02-07-2016 09:37:39")
        XCTAssertEqual(test[0].duration, self.timeSinceSecondsToString(1467441467))
        XCTAssertEqual(test[0].statusInformation, "fsdf")
        XCTAssertEqual(test[0].itemUrl, "http://testmonitoring/thruk/cgi-bin/extinfo.cgi?type=1&host=linksys-srw224p")
    }
    
    func testGetServiceMonitoringItems() {
        let filePath = Bundle(for: type(of: self)).path(forResource: "ThrukServiceStatus", ofType: "")
        XCTAssertNotNil(filePath)
        
        let data = try? Data(contentsOf: URL(fileURLWithPath: filePath!))
        
        let monitoringInstance = MonitoringInstance().initDefault(name: "test", url: "http://testmonitoring/cgi-bin/", type: .Nagios, username: "testuser", password: "testpass", enabled: 1)
        
        let parserServices = ThrukParser(monitoringInstance)
        
        let test = parserServices.parse(urlType: .services, data: data!) as! Array<ServiceMonitoringItem>
        
        XCTAssertEqual(test.count, 9)
        
        XCTAssertEqual(test[1].monitoringInstance!.name, "test")
        XCTAssertEqual(test[1].host, "localhost")
        XCTAssertEqual(test[1].service, "Current Users")
        XCTAssertEqual(test[1].status, "UNKNOWN")
        XCTAssertEqual(test[1].lastCheck, "02-07-2016 11:23:18")
        XCTAssertEqual(test[1].attempt, "4/4 #1432")
        XCTAssertEqual(test[1].duration, self.timeSinceSecondsToString(1405166941))
        XCTAssertEqual(test[1].statusInformation, "(null)")
        XCTAssertEqual(test[1].itemUrl, "http://testmonitoring/thruk/cgi-bin/extinfo.cgi?type=2&host=localhost&service=Current Users")
    }
    
    private func timeSinceSecondsToString(_ timeLeftSeconds: Double?) -> String {
        
        guard let timeLeftSeconds = timeLeftSeconds else {
            return ""
        }
        
        if timeLeftSeconds == 0.0 {
            return "N/A"
        }
        
        let currentDate = Date().timeIntervalSince1970
        let diff = Int(currentDate - timeLeftSeconds)
        
        let secondsInMinute = 60
        let secondsInHour = 60 * secondsInMinute
        let secondsInDay = 24 * secondsInHour
        
        let days = diff / secondsInDay
        let hours = (diff - secondsInDay * days) / secondsInHour
        let minutes = (diff - secondsInDay * days - secondsInHour * hours) / secondsInMinute
        let seconds = (diff - secondsInDay * days - secondsInHour * hours - secondsInMinute * minutes)
        
        var timeLeftString: String?
        
        if days > 0 {
            timeLeftString = String.init(format: "%ud %uh %um %us", days, hours, minutes, seconds)
        } else if hours > 0 {
            timeLeftString = String.init(format: "%uh %um %us", hours, minutes, seconds)
        } else if minutes > 0 {
            timeLeftString = String.init(format: "%um %us", minutes, seconds)
        } else {
            timeLeftString = String.init(format: "%us", seconds)
        }
        
        return timeLeftString!
    }
}
