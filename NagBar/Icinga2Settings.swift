//
//  Icinga2Settings.swift
//  NagBar
//
//  Created by Volen Davidov on 02.07.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation

class Icinga2Settings: MonitoringInstanceSettings {
    
    enum ItemType : String {
        case Host = "host"
        case Service = "service"
    }
    
    // There is no "PENDING" status in the Icinga2 API; it is displayed as "UNKNOWN" instead.
    // For hosts, it is displayed as "DOWN". Check https://github.com/Icinga/icinga2/blob/master/doc/3-monitoring-basics.md
    // for further info
    
    func getHostStatusTypes() -> String {
        
        let hostStatusTypes = ["up": "0.0", "down": "1.0", "unreachable": "2.0"]
        
        let hostStatusType = self.statusTypes(ItemType.Host, statusMappings: hostStatusTypes)
        
        return hostStatusType
    }
    
    func getServiceStatusTypes() -> String {
        
        let serviceStatusTypes = ["ok": "0.0", "warning": "1.0", "critical": "2.0", "unknown": "3.0"]
        
        let serviceStatusType = self.statusTypes(ItemType.Service, statusMappings: serviceStatusTypes)
        
        return serviceStatusType
    }
    
    private func statusTypes(_ itemType: ItemType, statusMappings: Dictionary<String, String>) -> String {
        var statusType = ""
        
        for (key, value) in statusMappings {
            if(Settings().boolForKey(key)) {
                if statusType == "" {
                    statusType += itemType.rawValue + ".state==" + value
                } else {
                    // %7C%7C are url encoded pipes - ||
                    statusType += "%7C%7C" + itemType.rawValue + ".state==" + value
                }
            }
        }
        
        statusType = "(" + statusType + ")"
        
        return statusType
    }
    
    func getHostProperties() -> String {
        
        let urlAnd = "%26%26"
        
        var hostProperties = ""
        
        if(Settings().boolForKey("hostScheduledDowntime")) {
            hostProperties += urlAnd + "host.downtime_depth==0.0"
        }
        
        if(Settings().boolForKey("hostAcknowledged")) {
            hostProperties += urlAnd + "host.acknowledgement==0.0"
        }
        
        if(Settings().boolForKey("hostChecksDisabled")) {
            hostProperties += urlAnd + "host.enable_active_checks==true"
        }
        
        // TODO: flapping detection does not work with host.flapping == false
        if(Settings().boolForKey("hostFlapping")) {
            hostProperties += ""
        }
        
        if(Settings().boolForKey("hostDisabledNotifications")) {
            hostProperties += urlAnd + "host.enable_notifications==true"
        }
        
        if(Settings().boolForKey("hostSoftState")) {
            hostProperties += urlAnd + "host.state_type==1"
        }
        
        return hostProperties
    }
    
    func getServiceProperties() -> String {
        
        var serviceProperties = ""
        
        let urlAnd = "%26%26"
        
        if(Settings().boolForKey("scheduledDowntime")) {
            serviceProperties += urlAnd + "service.downtime_depth==0.0"
        }
        
        if(Settings().boolForKey("acknowledged")) {
            serviceProperties += urlAnd + "service.acknowledgement==0.0"
        }
        
        if(Settings().boolForKey("checksDisabled")) {
            serviceProperties += urlAnd + "service.enable_active_checks==true"
        }
        
        // TODO: flapping detection does not work with service.flapping == false
        if(Settings().boolForKey("flapping")) {
            serviceProperties += ""
        }
        
        if(Settings().boolForKey("disabledNotifications")) {
            serviceProperties += urlAnd + "service.enable_notifications==true"
        }
        
        if(Settings().boolForKey("softState")) {
            serviceProperties += urlAnd + "service.state_type==1"
        }
        
        
        return serviceProperties
    }
    
    // Icinga2 API does not have ordering, so we just put placeholder functions here
    // and do the ordering from the parser instead
    func getSortOrder() -> String {
        return ""
    }
    
    func getSortColumn() -> String {
        return ""
    }
}
