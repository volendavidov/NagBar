//
//  Icinga2ParserTests.swift
//  NagBar
//
//  Created by Volen Davidov on 09.07.17.
//  Copyright © 2017 Volen Davidov. All rights reserved.
//

import XCTest
import RealmSwift

class Icinga2ParserTests: XCTestCase {
    
    override func setUp() {
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        
        let settings = [
            "sortColumn": "1",
            "sortOrder": "2",
        ]
        
        let realm = try! Realm()
        
        for (key, value) in settings {
            if realm.objects(Setting.self).filter("key == %@", key).first != nil {
                continue
            }
            
            let setting = Setting()
            setting.key = key
            setting.value = value
            try! realm.write {
                realm.add(setting)
            }
        }
    }
    
    func testGetHostMonitoringItems() {
        let filePath = Bundle(for: type(of: self)).path(forResource: "Icinga2HostStatus", ofType: "json")
        XCTAssertNotNil(filePath)
        
        let data = try? Data(contentsOf: URL(fileURLWithPath: filePath!))
        
        let monitoringInstance = MonitoringInstance().initDefault(name: "test", url: "https://testmonitoring:5665/v1", type: .Icinga2, username: "testuser", password: "testpass", enabled: 1)
        
        let parser = Icinga2Parser(monitoringInstance)
        
        let test = parser.parse(urlType: .hosts, data: data!)
        
        XCTAssertEqual(test.count, 2)
        
        XCTAssertEqual(test[0].monitoringInstance!.name, "test")
        XCTAssertEqual(test[0].host, "c2-web-1")
        XCTAssertEqual(test[0].status, "DOWN")
        XCTAssertEqual(test[0].lastCheck, "09-07-2017 14:36:43")
        XCTAssertEqual(test[0].duration, self.timeSinceSecondsToString(1494759783))
        XCTAssertEqual(test[0].statusInformation, "PING CRITICAL - Packet loss = 100%")
        XCTAssertEqual(test[0].itemUrl, "https://testmonitoring/icingaweb2/monitoring/host/show?host=c2-web-1")
    }
    
    func testGetServiceMonitoringItems() {
        let filePath = Bundle(for: type(of: self)).path(forResource: "Icinga2ServiceStatus", ofType: "json")
        XCTAssertNotNil(filePath)
        
        let data = try? Data(contentsOf: URL(fileURLWithPath: filePath!))
        
        let monitoringInstance = MonitoringInstance().initDefault(name: "test", url: "https://testmonitoring:5665/v1", type: .Icinga2, username: "testuser", password: "testpass", enabled: 1)
        
        let parserServices = Icinga2Parser(monitoringInstance)
        
        let test = parserServices.parse(urlType: .services, data: data!) as! Array<ServiceMonitoringItem>
        
        XCTAssertEqual(test.count, 47)
        
        XCTAssertEqual(test[7].monitoringInstance!.name, "test")
        XCTAssertEqual(test[7].host, "icinga2")
        XCTAssertEqual(test[7].status, "CRITICAL")
        XCTAssertEqual(test[7].service, "disk")
        XCTAssertEqual(test[7].lastCheck, "09-07-2017 14:36:48")
        XCTAssertEqual(test[7].duration, self.timeSinceSecondsToString(1494759844))
        XCTAssertEqual(test[7].attempt, "1/5")
        XCTAssertEqual(test[7].statusInformation, "DISK CRITICAL - free space: / 48157 MB (94% inode=99%); /boot 314 MB (63% inode=99%); /home 186600 MB (99% inode=99%); /vagrant 4223 MB (7% inode=100%); /tmp/vagrant-puppet/modules-d9eafae9c04b462999be5fe46dd5a1e9 4223 MB (7% inode=100%); /tmp/vagrant-puppet/manifests-a11d1078b1b1f2e3bdea27312f6ba513 4223 MB (7% inode=100%);")
        XCTAssertEqual(test[7].itemUrl, "https://testmonitoring/icingaweb2/monitoring/service/show?host=icinga2&service=disk")
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
