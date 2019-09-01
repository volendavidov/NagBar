//
//  Icinga2Parser.swift
//  NagBar
//
//  Created by Volen Davidov on 21.05.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation
import SwiftyJSON

class Icinga2Parser : MonitoringProcessorBase, ParserInterface {
    
    func parse(urlType: MonitoringURLType, data: Data) -> Array<MonitoringItem> {
        
        switch urlType {
        case .hosts:
            return self.getHostMonitoringItems(data)
        case .services:
            return self.getServiceMonitoringItems(data)
        case .hostScheduledDowntime:
            return self.getHostMonitoringItems(data)
        }
    }
    
    private func getHostMonitoringItems(_ data: Data) -> Array<HostMonitoringItem> {
        
        var results: Array<HostMonitoringItem> = []
        
        guard let jsonResults = self.getJSON(data as NSData) else {
            return results
        }
        
        for jsonHost in jsonResults {
            let monitoringItem = HostMonitoringItem()
            monitoringItem.monitoringInstance = self.getMonitoringInstanceForHost()
            monitoringItem.host = self.getHostForHost(jsonHost)
            monitoringItem.status = self.getStatusForHost(jsonHost)
            monitoringItem.lastCheck = self.getLastCheckForHost(jsonHost)
            monitoringItem.duration = self.getDurationForHost(jsonHost)
            monitoringItem.itemUrl = self.getItemURLForHost(jsonHost)
            monitoringItem.statusInformation = self.getStatusInformationForHost(jsonHost)
            monitoringItem.acknowledged = self.getAcknowledgementForHost(jsonHost)
            monitoringItem.downtime = self.getDowntimeForHost(jsonHost)
            
            results.append(monitoringItem)
        }
        
        // after we have
        results = self.postProcessHosts(results)
        
        return results
    }
    
    private func getServiceMonitoringItems(_ data: Data) -> Array<ServiceMonitoringItem> {
        var results: Array<ServiceMonitoringItem> = []
        
        guard let jsonResults = self.getJSON(data as NSData) else {
            return results
        }
        
        for jsonHost in jsonResults {
            let monitoringItem = ServiceMonitoringItem()
            monitoringItem.monitoringInstance = self.getMonitoringInstanceForService()
            monitoringItem.host = self.getHostForService(jsonHost)
            monitoringItem.service = self.getService(jsonHost)
            monitoringItem.attempt = self.getAttempt(jsonHost)
            monitoringItem.status = self.getStatusForService(jsonHost)
            monitoringItem.lastCheck = self.getLastCheckForService(jsonHost)
            monitoringItem.duration = self.getDurationForService(jsonHost)
            monitoringItem.itemUrl = self.getItemURLForService(jsonHost)
            monitoringItem.statusInformation = self.getStatusInformationForService(jsonHost)
            monitoringItem.acknowledged = self.getAcknowledgementForService(jsonHost)
            monitoringItem.downtime = self.getDowntimeForService(jsonHost)
            results.append(monitoringItem)
        }
        
        results = self.postProcessServices(results)
        
        return results
    }
    
    func getMonitoringInstanceForHost() -> MonitoringInstance {
        return self.monitoringInstance!
    }

    func getMonitoringInstanceForService() -> MonitoringInstance {
        return getMonitoringInstanceForHost()
    }
    
    func getHostForHost(_ json: JSON) -> String {
        return json["name"].string ?? ""
    }
    
    func getHostForService(_ json: JSON) -> String {
        return json["attrs"]["host_name"].string ?? ""
    }
    
    func getService(_ json: JSON) -> String {
        return json["attrs"]["name"].string ?? ""
    }
    
    func getAttempt(_ json: JSON) -> String {
        return String(format:"%.0f", json["attrs"]["check_attempt"].double ?? 0.0) + "/" + String(format:"%.0f", json["attrs"]["max_check_attempts"].double ?? 0.0)
    }
    
    func getStatusForHost(_ json: JSON) -> String {
        return self.hostStatusTranslate(json["attrs"]["state"].float)
    }
    
    func getStatusForService(_ json: JSON) -> String {
        return self.serviceStatusTranslate(json["attrs"]["state"].float!)
    }
    
    func getLastCheckForHost(_ json: JSON) -> String {
        return self.unixToTimestamp(json["attrs"]["last_check_result"]["schedule_end"].double)
    }
    
    func getLastCheckForService(_ json: JSON) -> String {
        return self.getLastCheckForHost(json)
    }
    
    func getDurationForHost(_ json: JSON) -> String {
        return self.timeSinceSecondsToString(json["attrs"]["last_state_change"].double!)
    }
    
    func getDurationForService(_ json: JSON) -> String {
        return self.getDurationForHost(json)
    }
    
    func getItemURLForService(_ json: JSON) -> String {
        let monitoringHost = URL(string: self.monitoringInstance!.url)!.scheme! + "://" + URL(string: self.monitoringInstance!.url)!.host!
        let url = String(format: monitoringHost + "/icingaweb2/monitoring/service/show?host=%@", self.getHostForService(json)) + "&service=" + self.getService(json)
        return url
    }
    
    func getItemURLForHost(_ json: JSON) -> String {
        let monitoringHost = URL(string: self.monitoringInstance!.url)!.scheme! + "://" + URL(string: self.monitoringInstance!.url)!.host!
        return String(format: monitoringHost + "/icingaweb2/monitoring/host/show?host=%@", self.getHostForHost(json))
    }
    
    func getStatusInformationForHost(_ json: JSON) -> String {
        return json["attrs"]["last_check_result"]["output"].string ?? ""
    }
    
    func getStatusInformationForService(_ json: JSON) -> String {
        return json["attrs"]["last_check_result"]["output"].string ?? ""
    }
    
    func getAcknowledgementForHost(_ json: JSON) -> Bool {
        return json["attrs"]["acknowledgement"].boolValue
    }
    
    func getAcknowledgementForService(_ json: JSON) -> Bool {
        return json["attrs"]["acknowledgement"].boolValue
    }
    
    func getDowntimeForHost(_ json: JSON) -> Bool {
        return json["attrs"]["downtime_depth"].boolValue
    }
    
    func getDowntimeForService(_ json: JSON) -> Bool {
        return json["attrs"]["downtime_depth"].boolValue
    }
    
    func getJSON(_ data: NSData) -> [JSON]? {
        guard let json = try? JSON(data: data as Data) else {
            return nil
        }
        
        guard let jsonResults = json["results"].array else {
            return nil
        }
        
        return jsonResults
    }
    
    func hostStatusTranslate(_ state: Float?) -> String {
        guard let state = state else {
            return ""
        }
        
        switch state {
        case 0.0:
            return "UP"
        case 1.0:
            return "DOWN"
        case 2.0:
            return "UNREACHABLE"
        default:
            return ""
        }
    }
    
    func serviceStatusTranslate(_ state: Float) -> String {
        switch state {
        case 0.0:
            return "OK"
        case 1.0:
            return "WARNING"
        case 2.0:
            return "CRITICAL"
        case 3.0:
            return "UNKNOWN"
        default:
            return ""
        }
    }
    
    func timeSinceSecondsToString(_ timeLeftSeconds: Double?) -> String {
        
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
    
    func unixToTimestamp(_ unixTimestamp: Double?) -> String {
        guard let unixTimestamp = unixTimestamp else {
            return ""
        }
        
        let date = Date.init(timeIntervalSince1970: unixTimestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-YYYY HH:mm:ss"
        let dateString = dateFormatter.string(from: date)
        
        return dateString
    }
    
    func postProcessHosts(_ results: Array<HostMonitoringItem>) -> Array<HostMonitoringItem> {
        return MonitoringItemSorter().sortHosts(results)
    }
    
    func postProcessServices(_ results: Array<ServiceMonitoringItem>) -> Array<ServiceMonitoringItem> {
        return MonitoringItemSorter().sortServices(results)
    }
}
