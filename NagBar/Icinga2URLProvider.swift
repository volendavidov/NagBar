//
//  Icinga2URLProvider.swift
//  NagBar
//
//  Created by Volen Davidov on 02.07.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation

class Icinga2URLProvider : MonitoringProcessorBase, URLProvider {
    func create() -> Array<MonitoringURL> {
        
        var urls: Array<MonitoringURL> = []
        urls.append(MonitoringURL.init(urlType: MonitoringURLType.hosts, priority: 1, url: self.monitoringInstance!.url + "/objects/hosts?attrs=name&attrs=address&attrs=last_state_change&attrs=check_attempt&attrs=last_check_result&attrs=state&attrs=acknowledgement&attrs=downtime_depth&filter=" + Icinga2Settings().getHostStatusTypes() + Icinga2Settings().getHostProperties()))
        urls.append(MonitoringURL.init(urlType: MonitoringURLType.services, priority: 2, url: self.monitoringInstance!.url + "/objects/services?attrs=name&attrs=last_state_change&attrs=check_attempt&attrs=max_check_attempts&attrs=last_check_result&attrs=state&attrs=host_name&attrs=acknowledgement&attrs=downtime_depth&filter=" + Icinga2Settings().getServiceStatusTypes() + Icinga2Settings().getServiceProperties()))
        
        if Settings().boolForKey("skipServicesOfHostsWithScD") {
            urls.append(MonitoringURL.init(urlType: MonitoringURLType.hostScheduledDowntime, priority: 3, url: self.monitoringInstance!.url + "/objects/hosts?attrs=name&filter=host.last_in_downtime==true"))
        }
        
        return urls
    }
}
