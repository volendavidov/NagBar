//
//  CheckMKURLProvider.swift
//  NagBar
//
//  Created by Volen Davidov on 09.07.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation

class CheckMKURLProvider: MonitoringProcessorBase, URLProvider {
    func create() -> Array<MonitoringURL> {
        
        var urls: Array<MonitoringURL> = []
        urls.append(MonitoringURL.init(urlType: MonitoringURLType.hosts, priority: 1, url: self.monitoringInstance!.url + "view.py?view_name=nagstamon_hosts&output_format=json&" + CheckMKSettings().getHostStatusTypes() + "&" + CheckMKSettings().getHostProperties()))
        urls.append(MonitoringURL.init(urlType: MonitoringURLType.services, priority: 2, url: self.monitoringInstance!.url + "view.py?view_name=nagstamon_svc&output_format=json&" + CheckMKSettings().getServiceStatusTypes() + "&" + CheckMKSettings().getServiceProperties()))
        
        // TODO:
            if Settings().boolForKey("skipServicesOfHostsWithScD") {
            //                urls.append(MonitoringURL.init(urlType: MonitoringURLType.HostScheduledDowntime, priority: 3, url: monitoringInstance.url + "/objects/hosts?attrs=name&filter=host.last_in_downtime==true"))
            }
            
        return urls
    }
}
