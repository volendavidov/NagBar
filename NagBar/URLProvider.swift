//
//  URLProvider.swift
//  NagBar
//
//  Created by Volen Davidov on 09.06.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation

enum MonitoringURLType {
    case hosts
    case services
    case hostScheduledDowntime
}

struct MonitoringURL {
    var urlType: MonitoringURLType
    var priority: Int
    var url: String
}

protocol URLProvider {
    func create() -> Array<MonitoringURL>
}


