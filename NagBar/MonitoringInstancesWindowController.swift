//
//  MonitoringInstancesWindowController.swift
//  NagBar
//
//  Created by Volen Davidov on 31.01.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation
import Cocoa

class MonitoringInstancesWindowController: NSWindowController {
    @IBOutlet weak var monitoringInstancesTable: NSTableView!
    
    override func awakeFromNib() {
        Foundation.NotificationCenter.default.addObserver(self, selector: #selector(MonitoringInstancesWindowController.refreshTable), name: NSNotification.Name(rawValue: "MonitoringInstanceNameChanged"), object: nil)
    }
    
    @IBAction func segControlClicked(_ sender: NSSegmentedControl) {
        let selectedSegment = SegmentControl(rawValue: sender.selectedSegment)
        
        if selectedSegment == .add {
            if (MonitoringInstances().getByKey("New") != nil) {
                let messageText = NSLocalizedString("monitoringInstanceExistsMessage", comment: "")
                let informativeText = String(format: NSLocalizedString("monitoringInstanceExistsInformative", comment: ""), "New", "New")
                NagBarAlert().showWarningAlert(messageText, informativeText: informativeText)
            } else {
                let monitoringInstance = MonitoringInstance().initDefault(name: "New", url: "", type: MonitoringInstanceType.Nagios, username: "", password: "", enabled: 0)
                MonitoringInstances().insert(key: "New", value: monitoringInstance)
                refreshTable()
            }
        } else if selectedSegment == .delete {
            if monitoringInstancesTable.selectedRow != -1 {
                MonitoringInstances().removeById(monitoringInstancesTable.selectedRow)
                refreshTable()
            }
        }
    }
    
    func refreshTable() {
        self.monitoringInstancesTable.reloadData()
    }
    
    deinit {
        Foundation.NotificationCenter.default.removeObserver(self)
    }
}
