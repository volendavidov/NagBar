//
//  PreferencesWindowController.swift
//  NagBar
//
//  Created by Volen Davidov on 10.01.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation
import Cocoa

class PreferencesWindowController: NSWindowController {
    
    var monitoringInstancesWindow: MonitoringInstancesWindowController?
    
    @IBAction func openDataFeed(_ sender: AnyObject) {
        monitoringInstancesWindow = nil
        monitoringInstancesWindow = MonitoringInstancesWindowController(windowNibName: "MonitoringInstancesWindow")
        monitoringInstancesWindow!.showWindow(self)
    }
}
