//
//  MonitoringInstancesTableDatasource.swift
//  NagBar
//
//  Created by Volen Davidov on 31.01.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation
import Cocoa

class MonitoringInstancesTableDatasource: NSObject, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return MonitoringInstances().count()
    }
}
