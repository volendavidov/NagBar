//
//  ThrukParser.swift
//  NagBar
//
//  Created by Volen Davidov on 02.07.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation
import SwiftyJSON

// Icinga2 and Thruk JSON formats are very simillar with some exceptions. Time and status formats are the same.
// The Icinga2 JSON parser can be used as a generic JSON parser for other monitoring systems as well.

class ThrukParser : Icinga2Parser {
    
    override func getHostForHost(_ json: JSON) -> String {
        return json["display_name"].string ?? ""
    }
    
    override func getHostForService(_ json: JSON) -> String {
        return json["host_name"].string ?? ""
    }
    
    override func getService(_ json: JSON) -> String {
        return json["description"].string ?? ""
    }
    
    override func getAttempt(_ json: JSON) -> String {
        let attempt = json["current_attempt"].int != nil ? String(json["current_attempt"].int!) : ""
        let maxCheckAttempts = json["max_check_attempts"].int != nil ? String(json["max_check_attempts"].int!) : ""
        // we also want to add the current_notification_number which is a feature supported by Thruk
        let currentNotificationNumber = json["current_notification_number"].int != nil ? String(json["current_notification_number"].int!) : ""
        let attemptString = attempt + "/" + maxCheckAttempts + " #" + currentNotificationNumber
        
        return attemptString
    }
    
    
    override func getStatusForHost(_ json: JSON) -> String {
        let status = self.hostStatusTranslate(Float(json["state"].int!))
        return self.getStatus(json, status: status)
    }
    
    override func getStatusForService(_ json: JSON) -> String {
        let status = self.serviceStatusTranslate(Float(json["state"].int!))
        return self.getStatus(json, status: status)
    }
    
    override func getLastCheckForHost(_ json: JSON) -> String {
        var lastCheck = self.unixToTimestamp(json["last_check"].double)
        
        // If the host is pending, it will have value 0 for "state" which does not make sense and it will look as the host is OK. However, the value of "last_check" is 0, so we use it instead; this block must be after the block setting item.status. The same workaround is applied for services.
        if json["last_check"].double == 0 {
            lastCheck = "N/A"
        }
        
        return lastCheck
    }
    
    override func getLastCheckForService(_ json: JSON) -> String {
        return self.getLastCheckForHost(json)
    }
    
    override func getDurationForHost(_ json: JSON) -> String {
        return self.timeSinceSecondsToString(json["last_state_change"].double)
    }
    
    override func getDurationForService(_ json: JSON) -> String {
        return self.getDurationForHost(json)
    }
    
    override func getItemURLForService(_ json: JSON) -> String {
        let monitoringHost = URL(string: self.monitoringInstance!.url)!.scheme! + "://" + URL(string: self.monitoringInstance!.url)!.host! + "/thruk/cgi-bin/"
        return String(format: monitoringHost + "extinfo.cgi?type=2&host=%@&service=%@", self.getHostForService(json), self.getService(json))
    }
    
    override func getItemURLForHost(_ json: JSON) -> String {
        let monitoringHost = URL(string: self.monitoringInstance!.url)!.scheme! + "://" + URL(string: self.monitoringInstance!.url)!.host! + "/thruk/cgi-bin/"
        return String(format: monitoringHost + "extinfo.cgi?type=1&host=%@", self.getHostForHost(json))
    }
    
    override func getStatusInformationForHost(_ json: JSON) -> String {
        return json["plugin_output"].string ?? ""
    }
    
    override func getStatusInformationForService(_ json: JSON) -> String {
        return self.getStatusInformationForHost(json)
    }
    
    override func getAcknowledgementForHost(_ json: JSON) -> Bool {
        return json["acknowledged"].boolValue
    }
    
    override func getAcknowledgementForService(_ json: JSON) -> Bool {
        return json["acknowledged"].boolValue
    }
    
    override func getDowntimeForHost(_ json: JSON) -> Bool {
        return json["scheduled_downtime_depth"].boolValue
    }
    
    override func getDowntimeForService(_ json: JSON) -> Bool {
        return json["scheduled_downtime_depth"].boolValue
    }
    
    override func getJSON(_ data: NSData) -> [JSON]? {
        guard let json = try? JSON(data: data as Data) else {
            return nil
        }
        
        guard let jsonResults = json.array else {
            return nil
        }
        
        return jsonResults
    }
    
    override func postProcessHosts(_ results: Array<HostMonitoringItem>) -> Array<HostMonitoringItem> {
        return results
    }
    
    override func postProcessServices(_ results: Array<ServiceMonitoringItem>) -> Array<ServiceMonitoringItem> {
        return results
    }
    
    private func getStatus(_ json: JSON, status: String) -> String {
        // If the host is pending, it will have value 0 for "state" which does not make sense and it will look as the host is OK. However, the value of "last_check" is 0, so we use it instead; this block must be after the block setting item.status. The same workaround is applied for services.
        if json["last_check"].double == 0 {
            return "N/A"
        } else {
            return status
        }
    }
}
