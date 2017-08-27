//
//  SettingsTests.swift
//  NagBar
//
//  Created by Volen Davidov on 18.10.15.
//  Copyright (c) 2015 Volen Davidov. All rights reserved.
//

import Cocoa
import XCTest
import RealmSwift

class NagiosSettingsTests: XCTestCase {
    
    override func setUp() {
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        
        let settings = [
            "refreshInterval": "30",
            "monitoringInstance": "0",
            "status": "0",
            "lastCheck": "0",
            "duration": "0",
            "attempt": "0",
            "statusInformation": "0",
            "critical": "0",
            "warning": "0",
            "unknown": "1",
            "pending": "1",
            "down": "1",
            "unreachable": "0",
            "hostPending": "1",
            "sortColumn": "7",
            "sortOrder": "3",
            "statusInformationLength": "200",
            "ok": "0",
            "up": "0",
            "scheduledDowntime": "0",
            "acknowledged": "1",
            "flapping": "0",
            "checksDisabled": "0",
            "disabledNotifications": "0",
            "softState": "1",
            "skipServicesOfHostsWithScD": "0",
            "hostScheduledDowntime": "1",
            "hostAcknowledged": "0",
            "hostFlapping": "1",
            "hostDisabledNotifications": "1",
            "hostSoftState": "0",
            "hostChecksDisabled": "0",
            "showExtendedStatusInformation": "0",
            "flashStatusBar": "0",
            "flashStatusBarType": "0",
            "savePassword": "0",
            "acceptInvalidCertificates": "0",
            "enableAudibleAlarms": "0",
            "enableAudibleAlarmsCritical": "0",
            "enableAudibleAlarmsWarning": "0",
            "enableAudibleAlarmsDown": "0",
            "enableAudibleAlarmsUnreachable": "0",
            "enableAudibleAlarmsRecovery": "0",
            "audibleAlarmsCriticalSoundFile": "",
            "audibleAlarmsWarningSoundFile": "",
            "audibleAlarmsDownSoundFile": "",
            "audibleAlarmsUnreachableSoundFile": "",
            "audibleAlarmsRecoverySoundFile": "",
            "showDockIcon": "0",
            "useNotifications": "0",
            "newVersionCheck": "0",
            "acknowledgementDefaultComment": "",
            "scheduleDowntimeDefaultComment": ""
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
    
    func testGetHostProperties() {
        XCTAssertEqual(NagiosSettings().getHostProperties(), "10242");
    }
    
    func testGetHostStatusTypes() {
        XCTAssertEqual(NagiosSettings().getHostStatusTypes(), "5");
    }
    
    func testGetServiceStatusTypes() {
        XCTAssertEqual(NagiosSettings().getServiceStatusTypes(), "9");
    }
    
    func testgetServiceProperties() {
        XCTAssertEqual(NagiosSettings().getServiceProperties(), "262152");
    }
    
    func testGetSortOrder() {
        XCTAssertEqual(NagiosSettings().getSortOrder(), "3");
    }
    
    func testGetSortColumn() {
        XCTAssertEqual(NagiosSettings().getSortColumn(), "7");
    }
    
    func testSavePassword() {
        XCTAssertEqual(Settings().savePassword(), false);
    }
}
