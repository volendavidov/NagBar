//
//  InitConfig.swift
//  NagBar
//
//  Created by Volen Davidov on 10.01.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation
import RealmSwift

class InitConfig {
    
    func initConfig() {
        
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 1,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 1) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
        })
        
        Realm.Configuration.defaultConfiguration = config
        
        let settings = [
            "refreshInterval": "30",
            "monitoringInstance": "1",
            "status": "1",
            "lastCheck": "1",
            "duration": "1",
            "attempt": "1",
            "statusInformation": "1",
            "critical": "1",
            "warning": "1",
            "unknown": "1",
            "pending": "1",
            "down": "1",
            "unreachable": "1",
            "hostPending": "1",
            "sortColumn": "1",
            "sortOrder": "1",
            "statusInformationLength": "200",
            "ok": "0",
            "up": "0",
            "scheduledDowntime": "0",
            "acknowledged": "0",
            "flapping": "0",
            "checksDisabled": "0",
            "disabledNotifications": "0",
            "softState": "0",
            "skipServicesOfHostsWithScD": "0",
            "hostScheduledDowntime": "0",
            "hostAcknowledged": "0",
            "hostFlapping": "0",
            "hostDisabledNotifications": "0",
            "hostSoftState": "0",
            "hostChecksDisabled": "0",
            "showExtendedStatusInformation": "1",
            "flashStatusBar": "1",
            "flashStatusBarType": "2",
            "savePassword": "1",
            "acceptInvalidCertificates": "0",
            "enableAudibleAlarms": "1",
            "enableAudibleAlarmsCritical": "1",
            "enableAudibleAlarmsWarning": "1",
            "enableAudibleAlarmsDown": "1",
            "enableAudibleAlarmsUnreachable": "1",
            "enableAudibleAlarmsRecovery": "1",
            "audibleAlarmsCriticalSoundFile": "",
            "audibleAlarmsWarningSoundFile": "",
            "audibleAlarmsDownSoundFile": "",
            "audibleAlarmsUnreachableSoundFile": "",
            "audibleAlarmsRecoverySoundFile": "",
            "showDockIcon": "1",
            "useNotifications": "0",
            "newVersionCheck": "1",
            "acknowledgementDefaultComment": "",
            "scheduleDowntimeDefaultComment": "",
            "criticalColor": "1.0,0.804,0.804,1.0",
            "warningColor": "1.0,1.0,0.745,1.0",
            "unknownColor": "1.0,0.921,0.616,1.0",
            "pendingColor": "0.921,0.921,0.921,1.0",
            "downColor": "1.0,0.580,0.580,1.0",
            "unreachableColor": "1.0,0.886,0.384,1.0",
            "upColor": "0.588,0.886,0.502,1.0",
            "okColor": "0.588,0.886,0.502,1.0"
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
        
        if Settings().stringForKey("flashStatusBarType") == "1" {
            Settings().setString("2", forKey: "flashStatusBarType")
        }
    }
}
