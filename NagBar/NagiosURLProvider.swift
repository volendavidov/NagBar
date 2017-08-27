//
//  NagiosURLProvider.swift
//  NagBar
//
//  Created by Volen Davidov on 02.07.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation

class NagiosURLProvider : MonitoringProcessorBase, URLProvider {
    
    let settings = NagiosSettings()
    
    var appendURL: String {
        get {
            return "&limit=0"
        }
    }
    
    func create() -> Array<MonitoringURL> {
        let appendedStatusCGI = self.appendStatusCgi(self.monitoringInstance!.url)
        
        var urls: Array<MonitoringURL> = Array<MonitoringURL>()
        urls.append(MonitoringURL.init(urlType: MonitoringURLType.hosts, priority: 1, url: self.buildHostUrl(appendedStatusCGI, type: self.monitoringInstance!.type)))
        urls.append(MonitoringURL.init(urlType: MonitoringURLType.services, priority: 2, url: self.buildServiceUrl(appendedStatusCGI, type: self.monitoringInstance!.type)))
        
        if Settings().boolForKey("skipServicesOfHostsWithScD") {
            urls.append(MonitoringURL.init(urlType: MonitoringURLType.hostScheduledDowntime, priority: 3, url: self.buildHostScheduledDowntimeUrl(appendedStatusCGI, type: self.monitoringInstance!.type)))
        }
        
        return urls
    }
    
    // append status.cgi to the URL in case it is missing
    private func appendStatusCgi(_ url: String) -> String {
        if url.range(of: "^.*status.cgi$", options: .regularExpression) != nil {
            return url
        } else {
            return url + "status.cgi"
        }
    }
    
    private func buildHostUrl(_ url: String, type: MonitoringInstanceType) -> String {
        return url + "?hostgroup=all&style=hostdetail&hoststatustypes=" + self.settings.getHostStatusTypes() + "&hostprops=" + self.settings.getHostProperties() + self.appendURL
    }
    
    private func buildServiceUrl(_ url: String, type: MonitoringInstanceType) -> String {
        return url + "?service=all&hoststatustypes=2&servicestatustypes=" + self.settings.getServiceStatusTypes() + "&sorttype=" + self.settings.getSortOrder() + "&sortoption=" + self.settings.getSortColumn() + "&serviceprops=" + self.settings.getServiceProperties() + self.appendURL
    }
    
    private func buildHostScheduledDowntimeUrl(_ url: String, type: MonitoringInstanceType) -> String {
        return url + "?hostgroup=all&style=hostdetail&hoststatustypes=15&hostprops=262145" + self.appendURL
    }
}
