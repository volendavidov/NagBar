//
//  FilterTableViewDatasource.swift
//  NagBar
//
//  Created by Volen Davidov on 15.01.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation
import Cocoa

class FilterTableViewDatasource : NSObject, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return FilterItems().count()
    }
}
