//
//  NagiosSettings.swift
//  NagBar
//
//  Created by Volen Davidov on 02.07.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation

class NagiosSettings: MonitoringInstanceSettings {
    let hostStatusTypes = ["hostPending": 1, "up": 2, "down": 4, "unreachable": 8]
    
    let hostProperties = ["hostScheduledDowntime": 2, "hostAcknowledged": 8, "hostChecksDisabled": 16, "hostFlapping": 2048, "hostDisabledNotifications": 8192, "hostSoftState": 262144]
    
    let serviceStatusTypes = ["pending": 1, "ok": 2, "warning": 4, "unknown": 8, "critical": 16]
    
    let serviceProperties = ["scheduledDowntime": 2, "acknowledged": 8, "checksDisabled": 16, "flapping": 2048, "disabledNotifications": 8192, "softState": 262144]
    
    func getHostStatusTypes() -> String {
        var hostStatusType = 0;
        
        for (key, value) in hostStatusTypes {
            if(Settings().boolForKey(key)) {
                hostStatusType += value
            }
        }
        
        return String(hostStatusType);
    }
    
    func getHostProperties() -> String {
        var propertyType = 0;
        
        for (key, value) in hostProperties {
            if(Settings().boolForKey(key)) {
                propertyType += value
            }
        }
        
        return String(propertyType)
    }
    
    func getServiceStatusTypes() -> String {
        var serviceStatusType = 0;
        
        for (key, value) in serviceStatusTypes {
            if(Settings().boolForKey(key)) {
                serviceStatusType += value
            }
        }
        
        return String(serviceStatusType)
    }
    
    func getServiceProperties() -> String {
        var serviceProperty = 0;
        
        for (key, value) in serviceProperties {
            if(Settings().boolForKey(key)) {
                serviceProperty += value
            }
        }
        
        return String(serviceProperty)
    }
    
    func getSortOrder() -> String {
        return Settings().stringForKey("sortOrder")!
    }
    
    func getSortColumn() -> String {
        return Settings().stringForKey("sortColumn")!
    }
}