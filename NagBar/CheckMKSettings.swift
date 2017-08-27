//
//  CheckMKSettings.swift
//  NagBar
//
//  Created by Volen Davidov on 23.07.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation

class CheckMKSettings: MonitoringInstanceSettings {
    
    func getHostStatusTypes() -> String {
        let hostStatusTypes = ["up": "hst0", "down": "hst1", "unreachable": "hst2", "pending": "hstp"]
        
        let hostStatusType = self.statusTypes(hostStatusTypes)
        
        return hostStatusType
    }
    
    func getServiceStatusTypes() -> String {
        let serviceStatusTypes = ["ok": "st0", "warning": "st1", "critical": "st2", "unknown": "st3", "pending": "stp"]
        
        let serviceStatusType = self.statusTypes(serviceStatusTypes)
        
        return serviceStatusType
    }
    
    private func statusTypes(_ statusMappings: Dictionary<String, String>) -> String {
        var statusType = ""
        
        for (key, value) in statusMappings {
            statusType += value + "="
            if(Settings().boolForKey(key)) {
                statusType += "on"
            }
            statusType += "&"
        }
        
        return statusType
    }
    
    func getHostProperties() -> String {
        
        var hostProperties = ""
        
        if(Settings().boolForKey("hostScheduledDowntime")) {
            hostProperties += "is_host_scheduled_downtime_depth=0&"
        }
        
        if(Settings().boolForKey("hostAcknowledged")) {
            hostProperties += "is_host_acknowledged=0&"
        }
        
        if(Settings().boolForKey("hostChecksDisabled")) {
            hostProperties += "is_host_active_checks_enabled=1&"
        }
        
//        Check_MK hosts do not have flapping
//        if(Settings().boolForKey("hostFlapping")) {
//            
//        }
        
        if(Settings().boolForKey("hostDisabledNotifications")) {
            hostProperties += "is_host_notifications_enabled=1&"
        }

//        Check_MK hosts do not have state type
//        if(Settings().boolForKey("hostSoftState")) {
//            
//        }
        
        return hostProperties
    }
    
    func getServiceProperties() -> String {
        
        var serviceProperties = ""
        
        if(Settings().boolForKey("scheduledDowntime")) {
            serviceProperties += "is_in_downtime=0&"
        }
        
        if(Settings().boolForKey("acknowledged")) {
            serviceProperties += "is_service_acknowledged=0&"
        }
        
        if(Settings().boolForKey("checksDisabled")) {
            serviceProperties += "is_service_active_checks_enabled=1&"
        }
        
        if(Settings().boolForKey("flapping")) {
            serviceProperties += "is_service_is_flapping=0&"
        }
        
        if(Settings().boolForKey("disabledNotifications")) {
            serviceProperties += "is_service_in_notification_period=1&"
        }
        
        if(Settings().boolForKey("softState")) {
            serviceProperties += "is_service_state_type=1&"
        }
        
        return serviceProperties
    }
    
    func getSortOrder() -> String {
        return ""
    }
    
    func getSortColumn() -> String {
        return ""
    }
}
