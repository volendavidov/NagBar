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
            "flashStatusBarType": "1",
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
}
