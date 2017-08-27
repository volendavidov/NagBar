//
//  DataRefreshAction.swift
//  NagBar
//
//  Created by Volen Davidov on 23.04.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation
import Cocoa


protocol DataRefreshAction {
    func process(_ oldResults: Array<MonitoringItem>, newResults: Array<MonitoringItem>)
}

class NotificationCenter {
    static var sharedInstance = NotificationDisplay()
}

class NotificationDisplay : NSObject, NSUserNotificationCenterDelegate, DataRefreshAction {
    
    func process(_ oldResults: Array<MonitoringItem>, newResults: Array<MonitoringItem>) {
        let resultsDiff = self.resultsDiff(oldResults, newResults: newResults)
        
        for i in resultsDiff {
            let notification = NSUserNotification()
            notification.userInfo = ["monitoringItemUrl": i.itemUrl]
            notification.title = i.host
            notification.subtitle = i.service + " " + i.status
            notification.informativeText = i.statusInformation
            
            NSUserNotificationCenter.default.delegate = self
            NSUserNotificationCenter.default.deliver(notification)
            
            NotificationCenter.sharedInstance = self
        }
    }
    
    private func resultsDiff(_ oldResults: Array<MonitoringItem>, newResults: Array<MonitoringItem>) -> Array<MonitoringItem> {
        
        var notificationArray: Array<MonitoringItem> = Array<MonitoringItem>()
        
        for i in newResults {
            
            var objectInNewStatus = false
            
            for j in oldResults {
                if i.uniqueIdentifier() == j.uniqueIdentifier() {
                    objectInNewStatus = true
                }
            }
            
            if !objectInNewStatus {
                notificationArray.append(i)
            }
        }
        
        return notificationArray
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        
        guard let userInfo = notification.userInfo else {
            return
        }
        
        let monitoringItemUrl = userInfo["monitoringItemUrl"]
        
        if let monitoringItemUrl = monitoringItemUrl {
            let url = URL(string: monitoringItemUrl as! String)
            NSWorkspace.shared().open(url!)
        } else {
            print("URL not found")
        }
    }
}


class PlaySoundAlarm : DataRefreshAction {
    
    enum State {
        case recovery
        case failure
        case none
    }
    
    func process(_ oldResults: Array<MonitoringItem>, newResults: Array<MonitoringItem>) {
        
        switch self.evaluateRecoveryFailure(oldResults, newResults: newResults) {
        case let (state, _) where state == .recovery:
            self.recoveryAction()
            break
        case let (state, alertType) where state == .failure:
            self.failureAction(alertType!)
            break
        case let (state, _) where state == .none:
            break
        default:
            break
        }
    }
    
    private func recoveryAction() {
        // We do not really use chaining here and we just want to play the recovery alarm
        let recoveryAlarm = RecoveryAlarmProcessor()
        recoveryAlarm.process()
    }
    
    private func failureAction(_ alertType: Array<String>) {
        // Chain here the alarms; the first alarm that is enabled in the settings and with highest
        // priority is the only one that fires. Examples:
        // 1. We have one down and one critical alarm. Only the down alarm will be played.
        // 2. We have one down and one critical alarm, but alarms for down are disabled (from Preferences > Audible alarms > Down checkbox). In this case only the critical alarm will be played
        let downAlarm = DownAlarmProcessor()
        let unreachableAlarm = UnreachableAlarmProcessor()
        let criticalAlarm = CriticalAlarmProcessor()
        let warningAlarm = WarningAlarmProcessor()
        
        downAlarm.setNextProcessor(unreachableAlarm)
        unreachableAlarm.setNextProcessor(criticalAlarm)
        criticalAlarm.setNextProcessor(warningAlarm)
        
        downAlarm.process(alertType)
    }
    
    /**
     * Get the type of alerts
     */
    private func evaluateRecoveryFailure(_ oldResults: Array<MonitoringItem>, newResults: Array<MonitoringItem>) -> (State, Array<String>?) {
        
        let oldStatusDict = self.populateStatusDictionary(oldResults)
        let newStatusDict = self.populateStatusDictionary(newResults)
        
        var recovery = false
        var failure = false
        
        // in this array we will keep all alert changes; e.g. ["CRITICAL", "DOWN", "OK"]
        var alertType: Array<String> = []
        
        for (key, value) in newStatusDict {
            
            // exclude "OK", "UP", "PENDING" and "UNKNOWN" from the evaluation
            if key == "OK" || key == "UP" || key == "PENDING" || key == "UNKNOWN" {
                continue
            }
 
            if let oldStatusDictKey = oldStatusDict[key] {
                // and the new status items, then we get the number of occurences of that key.
                // If the number is higher in the new status items, then we have to raise a failure.
                // Otherwise we have a recovery.
                if oldStatusDictKey < value {
                    failure = true
                    alertType.append(key)
                } else if oldStatusDictKey > value {
                    recovery = true
                } else {
                    // This will be the case where the number of old status items for a status
                    // is equal to the number of new status items for a status.
                    // In this case, do not do anything.
                }
            } else {
                // if there is no such key in the old status, then we have a failure
                failure = true
                alertType.append(key)
            }
        }

        // this covers the case where all alarms of a certain type (e.g. CRITICAL)
        // have disappeared
        for (key, _) in oldStatusDict {
            if newStatusDict[key] == nil {
                recovery = true
            }
        }
        
        // we check that both recovery is true and failure is false, because we do not want to play the recovery sound together with the failure sound
        
        if recovery == true && failure == false {
            return (.recovery, nil)
        }
        
        if failure == true {
            return (.failure, alertType)
        }
        
        return (.none, nil)
    }
    
    
    /**
     Create a dictionary that contains the list of all statuses and their counts; e.g. "CRITICAL": 5,
     "WARNING": 3, "OK": 10 and etc.
     */
    private func populateStatusDictionary(_ results: Array<MonitoringItem>) -> Dictionary<String, Int> {
        
        var statusDict: Dictionary<String, Int> = [:]
        
        for i in results {
            var value = 0
            
            if let val = statusDict[i.status] {
                value = val
            }
            
            statusDict[i.status] = value + 1
        }
        
        return statusDict
    }
}

class AlarmProcessor {
    
    var alertType: String {
        return ""
    }
    
    var alertKeyEnabled: String {
        return ""
    }
    
    var alertKeyFilePath: String {
        return ""
    }
    
    var defaultSound: String {
        return ""
    }
    
    var nextProcessor: AlarmProcessor?
    
    func setNextProcessor(_ nextProcessor: AlarmProcessor) {
        self.nextProcessor = nextProcessor
    }
    
    func process(_ processorRequest: Array<String>? = nil) {
        
        // trigger alarm only if it is enabled in the settings
        if !Settings().boolForKey(self.alertKeyEnabled) {
            if let nextProcessor = self.nextProcessor {
                nextProcessor.process(processorRequest)
            }
            return
        }
        
        guard let processorRequest = processorRequest else {
            // if we do not have processorRequest, just play the alarm
            self.selectSound(self.defaultSound, soundFile: self.alertKeyFilePath)
            return
        }
        
        // if the alarm is enabled, we have to check if it exists in our list
        // with the alert changes (e.g. ["CRITICAL", "DOWN", "OK"]). If it exists, play it.
        // If not, proceed to the next processor.
        if processorRequest.contains(self.alertType) {
            self.selectSound(self.defaultSound, soundFile: self.alertKeyFilePath)
        } else {
            if let nextProcessor = self.nextProcessor {
                nextProcessor.process(processorRequest)
            }
        }
    }
    
    private func selectSound(_ defaultSound: String, soundFile: String) {
        let filePath = Settings().stringForKey(soundFile)
        if filePath == "" {
            playDefaultSound(defaultSound)
        } else {
            playCustomSound(filePath!)
        }
    }
    
    private func playDefaultSound(_ filePath: String) {
        let systemSound = NSSound.init(contentsOfFile: Bundle.main.path(forSoundResource: filePath)!, byReference: true)
        if let systemSound = systemSound {
            systemSound.play()
        }
    }
    
    private func playCustomSound(_ filePath: String) {
        let soundfileURL = URL(fileURLWithPath: filePath)
        let systemSound = NSSound.init(contentsOf: soundfileURL, byReference: true)
        
        if let systemSound = systemSound {
            systemSound.play()
        }
    }
}

class DownAlarmProcessor : AlarmProcessor {
    override var alertType: String {
        return "DOWN"
    }
    
    override var alertKeyEnabled: String {
        return "enableAudibleAlarmsDown"
    }
    
    override var alertKeyFilePath: String {
        return "audibleAlarmsDownSoundFile"
    }
    
    override var defaultSound: String {
        return "siren-horn"
    }
}

class UnreachableAlarmProcessor : AlarmProcessor {
    override var alertType: String {
        return "UNREACHABLE"
    }
    
    override var alertKeyEnabled: String {
        return "enableAudibleAlarmsUnreachable"
    }
    
    override var alertKeyFilePath: String {
        return "audibleAlarmsUnreachableSoundFile"
    }
    
    override var defaultSound: String {
        return "siren-horn"
    }
}

class CriticalAlarmProcessor : AlarmProcessor {
    override var alertType: String {
        return "CRITICAL"
    }
    
    override var alertKeyEnabled: String {
        return "enableAudibleAlarmsCritical"
    }
    
    override var alertKeyFilePath: String {
        return "audibleAlarmsCriticalSoundFile"
    }
    
    override var defaultSound: String {
        return "critical"
    }
}

class WarningAlarmProcessor : AlarmProcessor {
    override var alertType: String {
        return "WARNING"
    }
    
    override var alertKeyEnabled: String {
        return "enableAudibleAlarmsWarning"
    }
    
    override var alertKeyFilePath: String {
        return "audibleAlarmsWarningSoundFile"
    }
    
    override var defaultSound: String {
        return "warning"
    }
}

class RecoveryAlarmProcessor : AlarmProcessor {
    
    override var alertKeyEnabled: String {
        return "enableAudibleAlarmsRecovery"
    }
    
    override var alertKeyFilePath: String {
        return "audibleAlarmsRecoverySoundFile"
    }
    
    override var defaultSound: String {
        return "ok"
    }
}
