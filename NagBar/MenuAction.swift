//
//  MenuAction.swift
//  NagBar
//
//  Created by Volen Davidov on 24.07.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation
import Cocoa

@objc protocol MenuAction {
    func action(_ sender: NSMenuItem)
}

class RecheckAction: NSObject, MenuAction {
    func action(_ sender: NSMenuItem) {
        let monitoringItems = sender.representedObject as! Array<MonitoringItem>
        
        let monitoringInstance = monitoringItems[0].monitoringInstance
        
        monitoringInstance!.monitoringProcessor().command().recheck(monitoringItems)
    }
}

class ScheduleDowntimeAction: NSObject, MenuAction {
    
    private var downtimeWindow: ScheduleDowntimeWindow?
    
    func action(_ sender: NSMenuItem) {
        if self.downtimeWindow == nil {
            self.downtimeWindow = ScheduleDowntimeWindow(windowNibName: "ScheduleDowntimeWindow")
        }
        
        self.downtimeWindow!.monitoringItems = sender.representedObject as! Array<MonitoringItem>
        
        self.downtimeWindow!.showWindow(self)
    }
}

class AcknowledgeAction: NSObject, MenuAction {
    
    private var downtimeWindow: AcknowledgeWindow?
    
    func action(_ sender: NSMenuItem) {
        
        if self.downtimeWindow == nil {
            self.downtimeWindow = AcknowledgeWindow(windowNibName: "AcknowledgeWindow")
        }
        
        self.downtimeWindow!.monitoringItems = sender.representedObject as! Array<MonitoringItem>
        
        self.downtimeWindow!.showWindow(self)
    }
}

class AddToFilterAction : NSObject, MenuAction {
    func action(_ sender: NSMenuItem) {
        
        let alert = NSAlert()
        alert.addButton(withTitle: NSLocalizedString("no", comment: ""))
        alert.addButton(withTitle: NSLocalizedString("yes", comment: ""))
        alert.messageText = NSLocalizedString("addToFilter", comment: "")
        alert.informativeText = NSLocalizedString("addToFilterConfirm", comment: "")
        alert.alertStyle = .warning
        if alert.runModal() == NSApplication.ModalResponse.alertSecondButtonReturn {
            let monitoringItems = sender.representedObject as! Array<MonitoringItem>
            self.addToFilter(monitoringItems)
        }
    }
    
    private func addToFilter(_ monitoringItems: Array<MonitoringItem>) {
        
        let filterItemServiceStatus = ["CRITICAL": 16, "UNKNOWN": 8, "WARNING": 4, "PENDING" : 1]
        let filterItemHostStatus = ["UNREACHABLE": 8, "DOWN": 4, "PENDING" : 1]
        
        for monitoringItem in monitoringItems {
            
            let key = FilterItems.generateKey(monitoringItem.host, service: monitoringItem.service)
            
            // this is the case where the monitoring item already has a filter, but it is
            // for a different status
            if let filterItem = FilterItems().getByKey(key) {
                if monitoringItem.monitoringItemType == .service {
                    // There is no need to use bitwise operations, as if the value already exists, it won't be displayed in the table view at first place. But bitwise is the proper way to do it.
                    FilterItems().updateStatus(filterItem: filterItem, status: filterItem.status | filterItemServiceStatus[monitoringItem.status]!)
                } else {
                    FilterItems().updateStatus(filterItem: filterItem, status: filterItem.status | filterItemHostStatus[monitoringItem.status]!)
                }
                
            } else {
                var statusCode = 0
                
                if monitoringItem.monitoringItemType == .service {
                    statusCode = filterItemServiceStatus[monitoringItem.status]!
                } else {
                    statusCode = filterItemHostStatus[monitoringItem.status]!
                }
                
                let filterItem = FilterItem().initDefault(host: monitoringItem.host, service: monitoringItem.service, status: statusCode)
                
                FilterItems().insert(key: key, value: filterItem)
            }
        }
    }
}
