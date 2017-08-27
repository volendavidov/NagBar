//
//  StatusPanelTableViewDatasource.swift
//  NagBar
//
//  Created by Volen Davidov on 01.03.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation
import Cocoa

class StatusPanelTableViewDatasource : NSObject, NSTableViewDataSource {
    
    private var results: Array<MonitoringItem>
    
    init(results: Array<MonitoringItem>) {
        self.results = results
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.results.count
    }
}
